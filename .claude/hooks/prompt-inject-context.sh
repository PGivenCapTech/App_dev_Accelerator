#!/bin/bash
# Prompt Inject Context: Surface relevant context when the User submits a prompt.
#
# Before Claude processes the User's message, this hook injects:
# - Active assumptions that need validation
# - Known context gaps for the current loop
# - Session handoff state (if resuming)
# - Any blocking items from the last session
#
# This prevents the team from proceeding on stale assumptions or missing context
# that was identified in a previous session but never resolved.

set -euo pipefail

INPUT=$(cat)

PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
fi

CONTEXT_PARTS=()

# --- 1. Check for session handoff (resuming work) ---
HANDOFF_FILE="$PROJECT_DIR/docs/handoff/latest.md"
if [[ -f "$HANDOFF_FILE" ]]; then
  # Only inject if handoff is from a different session (less than 1 hour old = same session)
  HANDOFF_AGE=$(( $(date +%s) - $(stat -f %m "$HANDOFF_FILE" 2>/dev/null || stat -c %Y "$HANDOFF_FILE" 2>/dev/null || echo 0) ))

  if [[ $HANDOFF_AGE -gt 3600 ]]; then
    BRANCH=$(grep "^branch:" "$HANDOFF_FILE" 2>/dev/null | head -1 | sed 's/branch: //')
    UNCOMMITTED=$(sed -n '/^### Uncommitted Changes/,/^###/{/^```/,/^```/p}' "$HANDOFF_FILE" 2>/dev/null | grep -v '^```' | head -5)

    if [[ -n "$UNCOMMITTED" && "$UNCOMMITTED" != "(clean working tree — all work committed)" ]]; then
      CONTEXT_PARTS+=("RESUMING SESSION: Previous session left uncommitted work on branch '$BRANCH'. Check docs/handoff/latest.md for full state.")
    fi
  fi
fi

# --- 2. Check for unvalidated assumptions ---
ASSUMPTIONS=""
if [[ -d "$PROJECT_DIR/docs/engagement" ]]; then
  ASSUMPTIONS=$(grep -rn "ASSUMED" "$PROJECT_DIR/docs/engagement/" 2>/dev/null | head -5 || true)
fi

if [[ -n "$ASSUMPTIONS" ]]; then
  COUNT=$(echo "$ASSUMPTIONS" | wc -l | tr -d ' ')
  CONTEXT_PARTS+=("ACTIVE ASSUMPTIONS ($COUNT unvalidated): These need validation before /release. Run '/initiate --assumptions' to review.")
fi

# --- 3. Check for known context gaps ---
# Look for TODO or MISSING markers in engagement docs
GAPS=""
if [[ -d "$PROJECT_DIR/docs/engagement" ]]; then
  GAPS=$(grep -rn "TODO\|MISSING\|NEEDED\|TBD" "$PROJECT_DIR/docs/engagement/" 2>/dev/null | grep -v "Binary file" | head -5 || true)
fi

if [[ -n "$GAPS" ]]; then
  COUNT=$(echo "$GAPS" | wc -l | tr -d ' ')
  CONTEXT_PARTS+=("CONTEXT GAPS ($COUNT items): Some engagement context is incomplete. Check docs/engagement/ for TODO markers.")
fi

# --- 4. Check for recent test failures ---
if [[ -f "$PROJECT_DIR/docs/audit/command-log.jsonl" ]]; then
  RECENT_FAILURES=$(tail -50 "$PROJECT_DIR/docs/audit/command-log.jsonl" 2>/dev/null | jq -r 'select(.category == "test-execution" and .success == false) | .command' 2>/dev/null | tail -3 || true)

  if [[ -n "$RECENT_FAILURES" ]]; then
    CONTEXT_PARTS+=("RECENT TEST FAILURES: Some tests failed in the last session. Verify green state before proceeding.")
  fi
fi

# --- Build output ---
if [[ ${#CONTEXT_PARTS[@]} -eq 0 ]]; then
  # Nothing to inject
  exit 0
fi

# Join context parts with newlines
CONTEXT=$(printf '%s\n' "${CONTEXT_PARTS[@]}")

jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": $ctx
  }
}'
