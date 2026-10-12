---
name: sync
description: Sync loop — fetch remote changes, rebase, resolve conflicts, and re-validate before committing or pushing. Prevents merge surprises and keeps the branch current with collaborators.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /sync — Coordination & Version Control Loop

The **Sync** loop keeps the working branch current with the remote repository. It prevents merge surprises by fetching, rebasing, resolving conflicts, and re-validating before any commit or push. This is a discipline step embedded in other workflows, not typically run standalone.

## When to Run

| Trigger | Who Initiates |
|---|---|
| Before committing work | Dmitri (automatic step in workflows) |
| Before pushing to remote | Dmitri (automatic step in workflows) |
| After a push is rejected | Dmitri (recovery) |
| When User says "pull down changes" | SM directs Dmitri |
| Periodically during long development sessions | SM reminds Dmitri |

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Executor** | Dmitri | Runs git operations, resolves conflicts |
| **Validator** | Paul | Re-runs test suite after merge/rebase |
| **Navigator** | User | Approves conflict resolutions, decides on divergence |

## The Loop

```
┌──────────────────────────────────────────────────────────────┐
│  /sync                                                       │
│                                                              │
│  1. FETCH (Dmitri)                                           │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ git fetch origin                                     │ │
│     │ git status — check local vs remote                   │ │
│     │                                                      │ │
│     │ If up to date:                                       │ │
│     │   → "Branch is current with remote. No sync needed." │ │
│     │   → Exit                                             │ │
│     │                                                      │ │
│     │ If behind remote:                                    │ │
│     │   → "Remote has [N] new commit(s). Rebasing."        │ │
│     │   → Continue to step 2                               │ │
│     │                                                      │ │
│     │ If diverged:                                         │ │
│     │   → "Branch has diverged: [N] local, [M] remote.    │ │
│     │     Rebasing local changes on top of remote."        │ │
│     │   → Continue to step 2                               │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  2. REBASE (Dmitri)                                          │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ git pull --rebase origin [branch]                    │ │
│     │                                                      │ │
│     │ If clean rebase:                                     │ │
│     │   → Continue to step 4 (validate)                    │ │
│     │                                                      │ │
│     │ If conflicts:                                        │ │
│     │   → Continue to step 3                               │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  3. RESOLVE CONFLICTS (Dmitri → User approves)               │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ For each conflicting file:                           │ │
│     │   Dmitri: Read both sides of the conflict            │ │
│     │   Dmitri: Assess intent of both changes              │ │
│     │   Dmitri: Propose resolution                         │ │
│     │                                                      │ │
│     │   → User: "Conflict in [file]: our change does [X],  │ │
│     │     remote change does [Y]. Proposed resolution:     │ │
│     │     [description]. Approve?"                         │ │
│     │   → User approves / adjusts                          │ │
│     │                                                      │ │
│     │ After all conflicts resolved:                        │ │
│     │   git add [resolved files]                           │ │
│     │   git rebase --continue                              │ │
│     │                                                      │ │
│     │ If rebase continues with more conflicts:             │ │
│     │   → Loop back to resolve                             │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  4. VALIDATE (Paul)                                          │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ Run full test suite                                  │ │
│     │ Run type check                                       │ │
│     │                                                      │ │
│     │ If green:                                            │ │
│     │   → "Sync complete. [N] tests pass. Type check       │ │
│     │     clean. Safe to commit/push."                     │ │
│     │                                                      │ │
│     │ If failures:                                         │ │
│     │   → "Sync introduced [N] test failures:              │ │
│     │     [summary]. These came from the remote changes."  │ │
│     │   → Dmitri: diagnose and fix                         │ │
│     │   → Paul: re-validate                                │ │
│     │   → Loop until green                                 │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Remote Introduced Breakage

When the remote changes break tests or introduce syntax errors (as happened with the ClaimsList.tsx parse error), the sync loop catches and fixes them:

1. Dmitri identifies the breakage source (our code vs. remote code)
2. If remote introduced the error: fix it, commit the fix separately with a clear message
3. If our code conflicts with valid remote changes: adapt our code
4. Paul re-validates after every fix

## Integration Points

The `/sync` step is embedded in these workflows:

### In `/test-and-develop` — Before Commit
```
  9. SM verifies gates (existing step)

  10. SYNC (NEW — before commit)
      Dmitri: /sync
      → Fetch, rebase, resolve, re-validate
      → All tests still green after sync

  11. Commit and push
```

### In `/refactor` — Before Commit
```
  4. MOVE UNDER GREEN (existing step)

  5. SYNC (NEW — before commit)
      Dmitri: /sync
      → Fetch, rebase, resolve, re-validate
      → All tests still green after sync

  6. Commit and push
```

### In `/code-review` — Before Push
```
  5. FIX CYCLE (existing step)

      After all fixes complete:
        Dmitri: /sync
        Dmitri: commit and push
```

## Invocation

```bash
/sync                    — Full sync (fetch, rebase, resolve, validate)
/sync --check            — Check only (fetch + status, no rebase)
/sync --status           — Show local vs remote divergence
```
