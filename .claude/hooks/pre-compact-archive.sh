#!/bin/bash
# Pre-Compact: Archive critical session state before context window summarization.
#
# When a long session compacts, design decisions, assumption context, and
# refinement outcomes would otherwise compress into a lossy summary. This hook
# extracts and preserves the high-signal content so it survives compaction
# and is available to subsequent sessions.

set -euo pipefail

INPUT=$(cat)

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
fi

ARCHIVE_DIR="$PROJECT_DIR/docs/session-archive"
mkdir -p "$ARCHIVE_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_SLUG=$(date -u +"%Y%m%d-%H%M%S")
ARCHIVE_FILE="$ARCHIVE_DIR/${DATE_SLUG}-${SESSION_ID:0:8}.md"

# Extract key context from the transcript if available
DECISIONS=""
ASSUMPTIONS=""
ACTIVE_LOOP=""

if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
  # Extract lines mentioning decisions, assumptions, or loop transitions
  DECISIONS=$(grep -i "decision\|decided\|chose\|selected\|approved" "$TRANSCRIPT_PATH" 2>/dev/null | tail -20 || true)
  ASSUMPTIONS=$(grep -i "ASSUMED\|assumption\|skip.*default\|stated assumption" "$TRANSCRIPT_PATH" 2>/dev/null | tail -10 || true)
  ACTIVE_LOOP=$(grep -i "/refine\|/design\|/test-and-develop\|/deploy\|/release\|/spike" "$TRANSCRIPT_PATH" 2>/dev/null | tail -5 || true)
fi

# Check for in-progress work
UNCOMMITTED=$(cd "$PROJECT_DIR" && git status --porcelain 2>/dev/null | head -20 || true)
CURRENT_BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")

# Check for unvalidated assumptions
ASSUMPTION_FILES=""
if [[ -d "$PROJECT_DIR/docs/engagement" ]]; then
  ASSUMPTION_FILES=$(grep -rl "ASSUMED" "$PROJECT_DIR/docs/engagement/" 2>/dev/null || true)
fi

cat > "$ARCHIVE_FILE" << EOF
---
session_id: ${SESSION_ID}
archived_at: ${TIMESTAMP}
branch: ${CURRENT_BRANCH}
reason: pre-compaction
---

# Session Archive — ${TIMESTAMP}

## Active State at Compaction

**Branch:** ${CURRENT_BRANCH}
**Session:** ${SESSION_ID:0:8}

## Uncommitted Work

\`\`\`
${UNCOMMITTED:-"(clean working tree)"}
\`\`\`

## Recent Decisions (from transcript)

${DECISIONS:-"(no explicit decisions captured)"}

## Active Assumptions

${ASSUMPTIONS:-"(no assumptions found)"}

## Loop Activity

${ACTIVE_LOOP:-"(no loop transitions found)"}

## Unvalidated Assumptions in Engagement Context

${ASSUMPTION_FILES:-"(none)"}

---
*This archive was auto-generated before context compaction. Review on session resume.*
EOF

# Output: inject a system message so Claude knows the archive exists
jq -n --arg file "$ARCHIVE_FILE" '{
  "systemMessage": "Session context archived to " + $file + " before compaction. Key decisions and assumptions preserved."
}'
