#!/bin/bash
# Pre-Bash Guard: Enforce commit message traceability and block destructive operations.
#
# Two responsibilities:
# 1. Validate git commit messages follow convention: <type>(<scope>): <description>
#    where scope must reference a scenario slug or recognized area.
# 2. Block destructive operations that bypass the team's safety model
#    (force push to main, drop database, rm -rf on project paths, etc.)

set -euo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$CMD" ]]; then
  exit 0
fi

# --- 1. Block destructive operations ---

BLOCKED_PATTERNS=(
  "git push --force.*main"
  "git push -f.*main"
  "git reset --hard.*origin/main"
  "rm -rf /"
  "rm -rf \."
  "drop database"
  "DROP DATABASE"
  "truncate table"
  "TRUNCATE TABLE"
  "git branch -D main"
  "git checkout.*--.*\."
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$CMD" | grep -qE "$pattern"; then
    jq -n --arg cmd "$CMD" --arg pattern "$pattern" '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Blocked: destructive operation matching [\($pattern)]. Use a safer alternative or get explicit User approval first."
      }
    }'
    exit 2
  fi
done

# --- 2. Enforce commit message convention ---

# Only check actual git commit commands
if echo "$CMD" | grep -qE "^git commit"; then

  # Extract commit message from -m flag
  # Handle both single and double quotes, and heredoc style
  MSG=""
  if echo "$CMD" | grep -qE '\-m "'; then
    MSG=$(echo "$CMD" | grep -oP '(?<=-m ")[^"]+' | head -1)
  elif echo "$CMD" | grep -qE "\-m '"; then
    MSG=$(echo "$CMD" | grep -oP "(?<=-m ')[^']+" | head -1)
  elif echo "$CMD" | grep -qP '\-m "\$\(cat'; then
    # Heredoc style — extract the first line after EOF
    MSG=$(echo "$CMD" | grep -oP '(?<=EOF\n).*' | head -1)
  fi

  # If we extracted a message, validate it
  if [[ -n "$MSG" ]]; then
    # Convention: <type>(<scope>): <description>
    # Types: feat, fix, refactor, test, infra, docs, retro
    # Scope: scenario slug, area name, or "general" for meta-changes
    VALID_PATTERN="^(feat|fix|refactor|test|infra|docs|retro|chore)\([a-z0-9/_-]+\): .+"

    if ! echo "$MSG" | grep -qE "$VALID_PATTERN"; then
      # Allow Co-Authored-By commits (like this one) and merge commits
      if echo "$MSG" | grep -qi "^Merge\|Co-Authored-By\|^Initial\|^Add repository\|^Update"; then
        exit 0
      fi

      jq -n --arg msg "$MSG" '{
        "hookSpecificOutput": {
          "hookEventName": "PreToolUse",
          "permissionDecision": "deny",
          "permissionDecisionReason": "Commit message does not follow convention.\n\nExpected: <type>(<scope>): <description>\nTypes: feat, fix, refactor, test, infra, docs, retro\nScope: scenario slug or area name\n\nGot: \"\($msg)\"\n\nExample: feat(user-onboarding): add email validation step"
        }
      }'
      exit 2
    fi
  fi
fi

# Passed all checks
exit 0
