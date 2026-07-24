# Branch Strategy — Accelerator Repository

## Branch Model

```
main (tool-agnostic)
  │
  ├── All processes, skills, agents, documentation
  ├── Platform-level gates (CI, branch protection, PR template)
  ├── Works with Claude Code, Copilot, and manual developers
  │
  └── claude-hooks (enhanced experience)
       │
       ├── Everything from main PLUS:
       ├── .claude/settings.json — hook configuration
       ├── .claude/hooks/ — hook scripts
       ├── docs/claude-hooks.md — hook documentation
       └── Hook-generated artifact directories
```

## Sync Protocol

**Direction:** `main` → `claude-hooks` (one-way merge)

```bash
# When main gets new features, sync to claude-hooks:
git checkout claude-hooks
git merge main
git push
```

**Never merge claude-hooks → main.** The hooks are Claude Code specific and don't belong in the tool-agnostic branch.

## When to Use Which Branch

| Scenario | Branch |
|---|---|
| Team uses Claude Code exclusively | `claude-hooks` |
| Team uses Copilot exclusively | `main` |
| Mixed team (some Claude Code, some Copilot) | `main` (hooks don't break Copilot, but add noise) |
| Submodule reference for team repos | Either — depends on team's tool choice |

## What Lives Where

| Content | `main` | `claude-hooks` |
|---|---|---|
| Skills (`.claude/skills/`) | ✅ | ✅ (inherited) |
| Agents (`.claude/agents/`) | ✅ | ✅ (inherited) |
| Copilot prompts (`.github/prompts/`) | ✅ | ✅ (inherited) |
| Copilot instructions (`.github/copilot-instructions.md`) | ✅ | ✅ (inherited) |
| CLAUDE.md | ✅ | ✅ (inherited) |
| Docs (DoR, DoD, SDLC, governance, etc.) | ✅ | ✅ (inherited) |
| Hook settings (`.claude/settings.json`) | ❌ | ✅ |
| Hook scripts (`.claude/hooks/*.sh`) | ❌ | ✅ |
| Hook docs (`docs/claude-hooks.md`) | ❌ | ✅ |
| Hook artifact dirs (`docs/handoff/`, etc.) | ❌ | ✅ |

## Submodule Reference

When a team repo uses this accelerator as a submodule (via `/bootstrap`):

```bash
# For Claude Code teams:
git submodule add -b claude-hooks https://github.com/ORG/App_dev_Accelerator.git .accelerator

# For Copilot or mixed teams:
git submodule add -b main https://github.com/ORG/App_dev_Accelerator.git .accelerator
```

## Making Changes

| Change Type | Where to Commit | Sync |
|---|---|---|
| New skill or agent | `main` | Merge main → claude-hooks |
| Update to DoR/DoD/SDLC | `main` | Merge main → claude-hooks |
| New or modified hook | `claude-hooks` | No sync needed |
| Copilot prompt update | `main` | Merge main → claude-hooks |
| CLAUDE.md update | `main` | Merge main → claude-hooks |
| Hook documentation | `claude-hooks` | No sync needed |

## CI Consideration

Both branches should pass CI independently. The `claude-hooks` branch adds:
- Hook script linting (shellcheck)
- Hook script tests (if applicable)
- Validation that `.claude/settings.json` is valid JSON
