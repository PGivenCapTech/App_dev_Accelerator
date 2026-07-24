#!/bin/bash
# Notification Forward: Route Claude Code notifications to external channels.
#
# When the team hits an approval gate, encounters an error, or needs User input,
# this hook forwards the notification to the configured channel (Slack, Teams,
# or a local log file as fallback).
#
# Configuration: Set CLAUDE_NOTIFY_WEBHOOK in your environment or
# docs/engagement/team.md to enable external forwarding.
# Without a webhook configured, notifications are logged locally for review.

set -euo pipefail

INPUT=$(cat)

MESSAGE=$(echo "$INPUT" | jq -r '.message // "No message"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "info"')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")

# --- Local log (always) ---
NOTIFY_LOG="$PROJECT_DIR/docs/audit/notifications.jsonl"
mkdir -p "$(dirname "$NOTIFY_LOG")"

jq -n \
  --arg ts "$TIMESTAMP" \
  --arg type "$NOTIFICATION_TYPE" \
  --arg title "$TITLE" \
  --arg msg "$MESSAGE" \
  --arg branch "$BRANCH" \
  '{
    timestamp: $ts,
    type: $type,
    title: $title,
    message: $msg,
    branch: $branch
  }' >> "$NOTIFY_LOG"

# --- External webhook (if configured) ---
WEBHOOK_URL="${CLAUDE_NOTIFY_WEBHOOK:-}"

# Try to read webhook from engagement config if not in env
if [[ -z "$WEBHOOK_URL" && -f "$PROJECT_DIR/docs/engagement/team.md" ]]; then
  WEBHOOK_URL=$(grep -i "webhook.*http" "$PROJECT_DIR/docs/engagement/team.md" 2>/dev/null | grep -oP 'https?://[^\s]+' | head -1 || true)
fi

if [[ -n "$WEBHOOK_URL" ]]; then
  # Map notification type to urgency
  URGENCY="low"
  case "$NOTIFICATION_TYPE" in
    permission_prompt|error|failure)
      URGENCY="high"
      ;;
    idle_prompt|warning)
      URGENCY="medium"
      ;;
  esac

  # Send to webhook (Slack-compatible format)
  curl -s -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg title "$TITLE" \
      --arg msg "$MESSAGE" \
      --arg branch "$BRANCH" \
      --arg urgency "$URGENCY" \
      '{
        text: "[\($urgency)] \($title)",
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: "*\($title)*\n\($msg)\n_Branch: \($branch)_"
            }
          }
        ]
      }')" >/dev/null 2>&1 || true
fi

# --- macOS notification (local development) ---
if command -v osascript &>/dev/null; then
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null || true
fi

exit 0
