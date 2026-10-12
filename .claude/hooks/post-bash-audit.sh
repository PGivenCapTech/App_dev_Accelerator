#!/bin/bash
# Post-Bash Audit: Log significant commands for traceability and debugging.
#
# Records test runs, deployments, build commands, and git operations to an
# audit trail. This creates a forensic record of what was executed during
# development — invaluable for debugging failures, reproducing environments,
# and demonstrating compliance.
#
# Ignores trivial commands (ls, cat, echo, pwd) to avoid noise.

set -euo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // empty' | head -c 1000)
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
fi

if [[ -z "$CMD" ]]; then
  exit 0
fi

# Skip trivial commands — only log significant operations
case "$CMD" in
  ls*|cat*|echo*|pwd|cd*|head*|tail*|wc*|which*|type*|file*)
    exit 0
    ;;
esac

# Categorize the command
CATEGORY="general"
case "$CMD" in
  *test*|*jest*|*pytest*|*mocha*|*cucumber*|*vitest*)
    CATEGORY="test-execution"
    ;;
  *build*|*compile*|*tsc*|*webpack*|*gradle*|*maven*|*make*)
    CATEGORY="build"
    ;;
  *deploy*|*cdk*|*terraform*|*docker*|*kubectl*)
    CATEGORY="infrastructure"
    ;;
  git\ commit*|git\ push*|git\ merge*|git\ tag*)
    CATEGORY="source-control"
    ;;
  *npm\ install*|*pip\ install*|*yarn\ add*|*gradle\ dep*)
    CATEGORY="dependency"
    ;;
  *lint*|*format*|*prettier*|*eslint*|*black*)
    CATEGORY="quality"
    ;;
  *coverage*|*nyc*|*istanbul*|*jacoco*)
    CATEGORY="coverage"
    ;;
  *scan*|*snyk*|*sonar*|*trivy*|*grype*)
    CATEGORY="security"
    ;;
  gh\ *|git\ *)
    CATEGORY="source-control"
    ;;
esac

# Only log categorized commands (skip "general" unless it looks important)
if [[ "$CATEGORY" == "general" ]]; then
  # Still log if it's long or contains pipes (likely significant)
  if [[ ${#CMD} -lt 30 && "$CMD" != *"|"* && "$CMD" != *"&&"* ]]; then
    exit 0
  fi
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(cd "$PROJECT_DIR" && git branch --show-current 2>/dev/null || echo "unknown")

# Audit log location
AUDIT_LOG="$PROJECT_DIR/docs/audit/command-log.jsonl"
mkdir -p "$(dirname "$AUDIT_LOG")"

# Determine success/failure from output
SUCCESS="true"
if echo "$OUTPUT" | grep -qi "error\|failed\|FAIL\|exception\|Exit code: [1-9]"; then
  SUCCESS="false"
fi

# Append JSONL entry
jq -n \
  --arg ts "$TIMESTAMP" \
  --arg cat "$CATEGORY" \
  --arg cmd "$CMD" \
  --arg branch "$BRANCH" \
  --arg success "$SUCCESS" \
  --arg output "${OUTPUT:0:500}" \
  '{
    timestamp: $ts,
    category: $cat,
    command: $cmd,
    branch: $branch,
    success: ($success == "true"),
    output_preview: $output
  }' >> "$AUDIT_LOG"

exit 0
