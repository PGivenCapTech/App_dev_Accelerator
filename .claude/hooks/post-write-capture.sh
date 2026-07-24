#!/bin/bash
# Post-Write Capture: Auto-document architecture and domain decisions.
#
# When the team writes or edits files in key directories (domain models, events,
# API contracts, infrastructure, feature files), this hook appends a timestamped
# entry to the decision log. This ensures design decisions survive session
# boundaries and are available for traceability audits.
#
# Only triggers for files in decision-significant paths — ignores routine edits
# to docs, tests, or config files (those are tracked by git history).

set -euo pipefail

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "Write"')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
fi

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only capture decisions for architecturally significant paths
SIGNIFICANT=false
case "$FILE_PATH" in
  */src/domain/*|*/src/model/*|*/src/models/*)
    CATEGORY="domain-model"
    SIGNIFICANT=true
    ;;
  */src/event/*|*/src/events/*)
    CATEGORY="event-definition"
    SIGNIFICANT=true
    ;;
  */src/api/*|*/src/controller/*|*/src/routes/*)
    CATEGORY="api-contract"
    SIGNIFICANT=true
    ;;
  */infra/*|*/infrastructure/*|*/cdk/*|*/terraform/*)
    CATEGORY="infrastructure"
    SIGNIFICANT=true
    ;;
  */features/*|*.feature)
    CATEGORY="behavior-specification"
    SIGNIFICANT=true
    ;;
  */docs/engagement/*)
    CATEGORY="engagement-context"
    SIGNIFICANT=true
    ;;
  */backlog/*)
    CATEGORY="backlog-change"
    SIGNIFICANT=true
    ;;
  *)
    SIGNIFICANT=false
    ;;
esac

if [[ "$SIGNIFICANT" != "true" ]]; then
  exit 0
fi

# Extract what changed
RELATIVE_PATH="${FILE_PATH#$PROJECT_DIR/}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")

# Decision log location
DECISION_LOG="$PROJECT_DIR/docs/decisions/session-decisions.md"
mkdir -p "$(dirname "$DECISION_LOG")"

# Get a brief summary of what was written (first meaningful lines)
if [[ "$TOOL_NAME" == "Write" ]]; then
  CONTENT_PREVIEW=$(echo "$INPUT" | jq -r '.tool_input.content // empty' | head -5 | sed 's/^/  /')
elif [[ "$TOOL_NAME" == "Edit" ]]; then
  OLD=$(echo "$INPUT" | jq -r '.tool_input.old_string // empty' | head -3)
  NEW=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty' | head -3)
  CONTENT_PREVIEW="  - → ${NEW}"
else
  CONTENT_PREVIEW="  (content not captured)"
fi

# Append to decision log
cat >> "$DECISION_LOG" << EOF

### ${TIMESTAMP} | ${CATEGORY} | \`${RELATIVE_PATH}\`

**Branch:** ${BRANCH}
**Action:** ${TOOL_NAME}
**Preview:**
${CONTENT_PREVIEW}

---
EOF

# Return minimal output — don't clutter the session
jq -n --arg cat "$CATEGORY" --arg path "$RELATIVE_PATH" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Decision logged: " + $cat + " — " + $path
  }
}'
