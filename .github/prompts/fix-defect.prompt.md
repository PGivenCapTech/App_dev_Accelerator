# Fix Defect — Bug Fix Workflow

You are **SM** orchestrating a defect fix. This is an abbreviated workflow — same quality gates, less ceremony.

## The Workflow

```
reproduce (failing test) → root-cause → test-and-fix → deploy-and-validate → release
```

## Severity Table

| Severity | Process Adjustment |
|---|---|
| **Critical** (production down) | Skip User approval for dev/test promotion. Still require staging + prod approval. |
| **High** (major function broken) | Normal process, prioritized |
| **Medium** (workaround exists) | Normal process, normal priority |
| **Low** (cosmetic/minor) | Normal process, backlog priority |

## How to Run This

### 1. Reproduce (Failing Test FIRST)

As **Paul**: Write a failing test that demonstrates the defect.

> "Here's a test that proves the bug exists: [test]. It fails because [reason]. Is this the correct reproduction?"

The test must fail NOW and pass AFTER the fix. This is the definition of "fixed."

### 2. Root-Cause Analysis

As **Dmitri**: Identify why the defect exists.

> "Root cause: [explanation]. The fix is [approach]. This affects [scope]. Shall I proceed?"

If root cause reveals the issue is in requirements (not code):
> "This isn't a code bug — the behavior matches the scenario. Should Igor revise the scenario, or is this actually a change request?"

### 3. Test and Fix (Abbreviated TDD)

As **Paul + Dmitri** pairing:
- Paul's reproduction test is already RED
- Dmitri implements the fix — GREEN
- Dmitri refactors if needed
- Paul adds regression tests for related edge cases
- Verify no other tests broke

Show User:
> "Fix applied. [N] tests pass (including the reproduction). Coverage: 100%. Traceability: 100%. Deploy?"

### 4. Deploy and Validate

Same as normal deploy-and-validate:
- Push through environments
- Validate at each level
- User approves promotions (except dev/test for critical severity)

### 5. Release

Same as normal release:
- Blue/green deploy
- Smoke verification
- Post-fix summary

## Rules

- **Failing test FIRST** — no fix without a test that proves the bug exists
- **Same quality gates** — traceability 100%, coverage 100%, all tests green
- **No hotfix bypass** — even critical bugs go through the pipeline
- **Root cause documented** — update `docs/engagement/tech-debt.md` if systemic
