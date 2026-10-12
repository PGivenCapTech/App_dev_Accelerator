---
name: plan-sprint
description: Sprint planning — select stories from backlog, assess complexity, check token budget, commit to scope. Gates what enters /refine.
allowed-tools: [Read, Write, Edit, Bash]
user-invocable: true
---

# /plan-sprint — Sprint Planning

The **Plan Sprint** skill selects what goes into the next sprint. It produces a scope commitment that gates what enters `/refine`. Run this BEFORE refinement — it's the bridge between the backlog and the iteration.

## Inputs

| Source | What It Provides |
|--------|-----------------|
| `backlog/backlog.md` | Prioritized work items |
| `docs/retros/iteration-N.md` | Calibration notes, velocity data, token burn |
| `docs/engagement/codebase-patterns.md` | Sprint sizing rule, complexity indicators |
| Previous sprint's DoR | Unfinished work, dependencies identified |

## The Process

### 1. Review Velocity & Calibration

Read the most recent retro's calibration notes and velocity table. Identify:
- Stories/session trend
- Token burn pattern (which sprints fit, which didn't)
- Complexity indicators that drove burn

Present to User:
```
"Last sprint: [N] stories, [tests] tests, [context windows] context windows.
Calibration says: [key insight from retro]."
```

### 2. Pull Candidates from Backlog

List the next prioritized items from the backlog. For each candidate:

| # | Story | Epic | Complexity | Indicators |
|---|-------|------|------------|------------|
| 1 | ... | ... | Simple/Complex | [list any: new pattern, outbound HTTP, multi-mode, spike needed] |

**Complexity heuristics:**
- **Simple:** follows an established pattern (CRUD, sealed result → error code, repeated endpoint)
- **Complex:** new architectural pattern, outbound calls, multi-mode engine, needs spike, cross-cutting concern

### 3. Apply Sizing Rule

Default cap: **5 stories**. Adjust based on complexity:

| Mix | Effective Cap |
|-----|--------------|
| All simple (repetitive pattern) | Up to 9 |
| Mixed simple + complex | 5 |
| All complex (new patterns, spikes) | 3-4 |

Present recommendation:
```
"I recommend [N] stories for this sprint: [list].
Reasoning: [complexity assessment].
This leaves [remaining] in the backlog for the following sprint."
```

### 4. Check Dependencies

For the proposed scope:
- Does any story depend on an unfinished story from a prior sprint?
- Does any story need a spike that hasn't run yet?
- Are there external blockers (docs not fetched, decisions not made)?

If dependencies exist, flag them:
```
"Blocker: Story X needs [dependency]. Options:
  A) Include a spike for [dependency] in this sprint (reduces story capacity by 1)
  B) Defer Story X to next sprint
  C) Resolve [dependency] before starting"
```

### 5. Token Budget Estimate

Based on complexity mix, estimate whether this sprint fits in one context window:

| Complexity Profile | Expected Fit |
|-------------------|--------------|
| 3-4 simple stories | Comfortable — room for debug cycles |
| 5 simple stories | Tight but fits — minimal debug tolerance |
| 3-4 complex stories | Tight — expect to use full window |
| 5+ complex stories | Will NOT fit — reduce scope |

Present:
```
"Token budget estimate: [Comfortable / Tight / At risk].
[If at risk]: Recommend dropping [story] to ensure retro fits in same session."
```

### 6. Scope Commitment

After User approves, write the sprint plan:

**File:** `backlog/active/sprint-N.md`

```markdown
# Sprint [N] Plan

Date: [date]
Stories: [count]
Estimated fit: [Comfortable / Tight]

## Committed Scope

| # | Story | Issue | Complexity | Dependencies |
|---|-------|-------|------------|--------------|
| 1 | ... | #NN | Simple/Complex | None / [dep] |

## Ordering (proposed — confirmed during /refine)

1. [Story] — [why first]
2. [Story] — [builds on #1]
...

## Deferred (next sprint)

- [Story] — [reason deferred]

## Risks & Notes

- [Any spike needed]
- [Any external dependency]
- [Any token budget concern]
```

### 7. Transition to /refine

After scope is committed:
```
"Sprint [N] scope committed ([N] stories). Ready to refine.
Run /refine to start the Three Amigos workshop for these stories."
```

## Rules

- **Planning is NOT refinement** — don't write acceptance scenarios here. Just select and scope.
- **User commits** — SM proposes, User approves. No unilateral scope decisions.
- **Deferred is not deleted** — stories that don't fit go back to backlog with "deferred" note, not dropped.
- **Spikes count against capacity** — a spike in the sprint reduces story count by 1.
- **Retro data is authoritative** — if retro says "tight fit" for a pattern, trust it over optimistic estimates.

## Invocation

```bash
/plan-sprint                         — Plan next sprint from backlog
/plan-sprint --stories 3             — Override cap (e.g., all complex work)
/plan-sprint --include #27,#28       — Pre-select specific issues
/plan-sprint --continue              — Resume planning (after resolving a blocker)
```
