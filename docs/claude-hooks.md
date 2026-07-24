# Claude Code Hooks — Enhanced Experience

This document describes the Claude Code hooks that provide real-time context preservation, decision logging, and process enforcement during development sessions. These hooks are **Claude Code specific** — they enhance the developer experience but are not required for process compliance (platform-level gates in CI and branch protection handle that for all tools).

## Architecture

```
Layer 1: Platform (ALL developers)        ← Branch protection, CI gates, PR template
Layer 2: Claude Code hooks (THIS)          ← Session-aware, real-time, proactive
Layer 3: IDE automation (Copilot/other)    ← File watchers, tasks, linters
```

Hooks live in `.claude/hooks/` and are configured in `.claude/settings.json`. They are committed to the repo so every team member using Claude Code gets the same enforcement.

## Hook Inventory

| Hook | Event | Purpose | Blocking? |
|---|---|---|---|
| `pre-compact-archive.sh` | PreCompact | Archive critical context before window summarization | No |
| `post-write-capture.sh` | PostToolUse (Write/Edit) | Log architecture and domain decisions | No (async) |
| `post-bash-audit.sh` | PostToolUse (Bash) | Audit trail of significant commands | No (async) |
| `pre-bash-guard.sh` | PreToolUse (Bash) | Block destructive ops, enforce commit messages | **Yes** |
| `stop-session-handoff.sh` | Stop | Generate handoff doc for next session | No |
| `prompt-inject-context.sh` | UserPromptSubmit | Surface assumptions, gaps, and handoff state | No |
| `notification-forward.sh` | Notification | Route alerts to Slack/Teams/local | No (async) |

## What Each Hook Does

### Pre-Compact Archive (`PreCompact`)

**Problem solved:** Long sessions compact (summarize) to fit the context window. Design decisions, stated assumptions, and refinement outcomes compress into lossy summaries. The next message after compaction has less context than the one before.

**What it does:**
1. Reads the session transcript
2. Extracts decisions, assumptions, loop transitions
3. Captures current git state (branch, uncommitted work)
4. Lists unvalidated assumptions from engagement docs
5. Writes everything to `docs/session-archive/<timestamp>.md`

**Output location:** `docs/session-archive/`

### Post-Write Capture (`PostToolUse` — Write|Edit)

**Problem solved:** Architecture decisions are made implicitly when writing domain models, events, API contracts, or infrastructure code. Without explicit capture, the *why* behind these decisions is lost when the session ends.

**What it does:**
1. Checks if the written/edited file is in a decision-significant path
2. If yes, appends a timestamped entry to the decision log
3. Captures: timestamp, branch, file path, action type, content preview

**Decision-significant paths:**
- `src/domain/`, `src/model/`, `src/models/` → domain-model
- `src/event/`, `src/events/` → event-definition
- `src/api/`, `src/controller/`, `src/routes/` → api-contract
- `infra/`, `infrastructure/`, `cdk/`, `terraform/` → infrastructure
- `features/`, `*.feature` → behavior-specification
- `docs/engagement/` → engagement-context
- `backlog/` → backlog-change

**Output location:** `docs/decisions/session-decisions.md`

### Post-Bash Audit (`PostToolUse` — Bash)

**Problem solved:** When debugging failures, reproducing environments, or demonstrating compliance, teams need a record of what was executed. Without this, you rely on scrolling through session history — which may not exist after compaction.

**What it does:**
1. Categorizes the command (test, build, infrastructure, source-control, etc.)
2. Records timestamp, branch, command, success/failure, output preview
3. Writes to a JSONL file for easy querying

**Ignored:** trivial commands (ls, cat, echo, pwd, etc.)

**Output location:** `docs/audit/command-log.jsonl`

### Pre-Bash Guard (`PreToolUse` — Bash)

**Problem solved:** Two things:
1. Destructive operations (force push to main, rm -rf, drop database) can cause irreversible damage
2. Commit messages that don't follow the traceability convention break the scenario→test→code chain

**What it does:**
1. Checks the command against a blocklist of destructive patterns
2. If it's a `git commit`, validates the message follows `<type>(<scope>): <description>`
3. Blocks with exit code 2 if either check fails — Claude gets the reason and can retry with a corrected message

**Blocked patterns:**
- `git push --force` to main
- `rm -rf /` or `rm -rf .`
- `DROP DATABASE`, `TRUNCATE TABLE`
- `git branch -D main`
- `git reset --hard origin/main`

**Commit format enforced:** `<type>(<scope>): <description>`
- Types: feat, fix, refactor, test, infra, docs, retro, chore
- Scope: scenario slug or recognized area name

### Stop Session Handoff (`Stop`)

**Problem solved:** When a developer stops working (end of day, context exhaustion, session crash), the next session starts cold. Without a handoff, it has to re-derive: what was I working on, what decisions were made, what's left, what assumptions are active.

**What it does:**
1. Captures current branch, uncommitted changes, staged files
2. Lists recent commits (last 10)
3. Checks for in-progress backlog items
4. Lists unvalidated assumptions
5. Shows recent test results
6. Writes a structured handoff to `docs/handoff/latest.md`
7. Archives the handoff with timestamp (keeps last 20)

**Output location:** `docs/handoff/latest.md` (+ dated archive)

### Prompt Inject Context (`UserPromptSubmit`)

**Problem solved:** The User starts a new prompt without realizing there are unvalidated assumptions, test failures from the last session, or context gaps that need filling. The team proceeds on stale or incomplete information.

**What it does:**
1. Checks for a handoff document from a previous session (>1 hour old)
2. Counts unvalidated assumptions in engagement docs
3. Scans for TODO/MISSING/TBD markers in context docs
4. Checks for recent test failures in the audit log
5. Injects a summary as `additionalContext` so Claude surfaces it naturally

**When it fires:** Every user prompt. Exits immediately if nothing to inject.

### Notification Forward (`Notification`)

**Problem solved:** When the team hits an approval gate or encounters a blocking error, the User may not be watching the terminal. Without forwarding, the team sits idle until the User checks back.

**What it does:**
1. Logs every notification to `docs/audit/notifications.jsonl`
2. If `CLAUDE_NOTIFY_WEBHOOK` is set (or found in team.md), posts to Slack/Teams
3. On macOS, fires a native notification via osascript

**Configuration:**
- Set `CLAUDE_NOTIFY_WEBHOOK` environment variable to a Slack incoming webhook URL
- Or add the webhook URL to `docs/engagement/team.md` (picked up automatically)

## Generated Artifacts

These directories are created by hooks and should be gitignored (session-specific, not shared):

```
docs/
  session-archive/     ← PreCompact archives (per-session)
  decisions/           ← Architecture decision log (cumulative)
  audit/               ← Command log + notifications (per-session)
  handoff/             ← Session handoff documents (rolling)
```

**What to gitignore vs. commit:**

| Directory | Gitignore? | Reason |
|---|---|---|
| `docs/session-archive/` | Yes | Session-specific, large, not useful to other developers |
| `docs/decisions/` | **No — commit this** | Decisions are team knowledge, valuable across sessions |
| `docs/audit/` | Yes | Forensic detail, too granular for git history |
| `docs/handoff/` | Partial | `latest.md` can be useful; dated archives can be gitignored |

## Adapting Hooks for Your Project

### Changing decision-significant paths

Edit `post-write-capture.sh` — add/remove case patterns in the `SIGNIFICANT` section.

### Adding blocked operations

Edit `pre-bash-guard.sh` — add patterns to the `BLOCKED_PATTERNS` array.

### Adjusting commit message format

Edit `pre-bash-guard.sh` — modify the `VALID_PATTERN` regex. The current pattern is:
```
^(feat|fix|refactor|test|infra|docs|retro|chore)\([a-z0-9/_-]+\): .+
```

### Configuring notifications

Set the `CLAUDE_NOTIFY_WEBHOOK` environment variable:
```bash
export CLAUDE_NOTIFY_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

Or add to `docs/engagement/team.md`:
```markdown
## Notification Webhook
- Deploy notifications: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

## Relationship to Platform Layer

These hooks provide **earlier, richer feedback** than the platform layer:

| What | Hook (immediate) | Platform (PR/merge time) |
|---|---|---|
| Commit message format | Pre-commit: blocks bad message | CI: commitlint check on PR |
| Test coverage | Logged in audit trail | CI: coverage-gate blocks merge |
| Destructive ops | Blocked before execution | Branch protection prevents damage to main |
| Decision capture | Logged as decisions happen | N/A — platform can't see this |
| Context preservation | Archived before compaction | N/A — platform can't see this |

Both layers are needed: hooks catch issues in real-time, platform catches anything that slips through (different tool, disabled hooks, etc.).
