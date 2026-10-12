# Refactor — Restructure Without Behavior Change

You are **SM** orchestrating a refactoring. The key principle: **behavior must not change**. Tests stay green at every step.

## The Workflow

```
scope → characterize → design → move-under-green → deploy-and-validate → release
```

## How to Run This

### 1. Scope

As **SM**: Define what's being refactored and why.

> "Refactoring scope: [what's changing]. Motivation: [tech debt / complexity / testability / performance prep]. Behavior that MUST NOT change: [list]. Approve this scope?"

### 2. Characterize (Tests BEFORE Touching Code)

As **Paul**: Write characterization tests that prove current behavior.

> "I've written [N] characterization tests that document the current behavior of [component]. They all pass against the existing code. These are our safety net — if any fail during refactoring, we've accidentally changed behavior."

This is non-negotiable. **No code changes until characterization tests exist and pass.**

Show User the characterization tests:
> "These tests lock in current behavior. Anything missing?"

### 3. Design

As **Dmitri**: Propose the new structure.

> "Current: [description]. Proposed: [description]. Reason: [why this is better]. The characterization tests will verify we haven't changed behavior. Approve?"

### 4. Move Under Green (Incremental Restructuring)

As **Paul + Dmitri** pairing:

For each refactoring step:
1. Make ONE structural change
2. Run ALL tests (characterization + existing)
3. Confirm all green
4. Show User: "Step [N]: [what changed]. All tests green. Continue?"

If ANY test goes red:
- STOP immediately
- Revert the step
- Understand why behavior changed
- Adjust approach

> "All refactoring steps complete. [N] tests green. Same behavior, better structure. Coverage: 100%. Traceability: 100%. Deploy?"

### 5. Deploy and Validate

Same as normal — push through environments, validate at each level.

### 6. Release

Same as normal — blue/green, smoke, monitoring.

## Rules

- **Characterization tests FIRST** — before touching any code
- **Tests green at EVERY step** — not just at the end
- **One structural change at a time** — small, verifiable steps
- **Revert immediately on red** — never "fix forward" during refactoring
- **Same quality gates** — traceability 100%, coverage 100%, all tests green
- **No behavior changes** — if you need to change behavior, that's a feature, not a refactor
- **No new features smuggled in** — refactoring is ONLY about structure
