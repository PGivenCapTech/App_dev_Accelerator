---
name: refactor
description: Refactor workflow — restructure code without changing behavior. Tests prove behavior is preserved. Full design loop for the new structure, then move code under green tests.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /refactor — Refactor Workflow

The **Refactor** workflow restructures code without changing external behavior. The key principle: **existing tests prove behavior is preserved** — they must stay green throughout. A full /design loop produces the target structure, then code moves under the safety net of passing tests.

## Loop Composition

```
/refine (light) → /spike (if approach uncertain) → /design (full) → /test-and-develop (behavior-preserving) → /deploy-and-validate → /release
```

## What Makes Refactoring Different

| Aspect | New Feature | Refactor |
|---|---|---|
| New behavior | Yes | **No** — behavior unchanged |
| New tests | Yes (define new behavior) | **Characterization tests** (capture existing behavior) |
| Design | New components | **New structure** for existing components |
| TDD cycle | Red → Green → Refactor | **Green → Refactor → Still Green** |
| Risk | Wrong behavior | **Broken behavior** (regression) |
| NFRs | New targets | **Maintained or improved** (never degraded) |

## The Workflow

```
┌────────────────────────────────────────────────────────────┐
│  /refactor                                                 │
│                                                            │
│  1. SCOPE (Light /refine)                                  │
│     ┌────────────────────────────────────────────────┐     │
│     │ Igor: What's the goal? (readability, perf,     │     │
│     │   modularity, testability, tech debt)          │     │
│     │ Dmitri: What code is affected? Blast radius?   │     │
│     │ Paul: What tests currently cover this area?    │     │
│     │                                                │     │
│     │ → User: "Refactoring [scope] to achieve       │     │
│     │   [goal]. Blast radius: [files/components].    │     │
│     │   Test coverage on affected area: [%].         │     │
│     │   Approve scope?"                              │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  2. CHARACTERIZE (Paul leads)                              │
│     ┌────────────────────────────────────────────────┐     │
│     │ Before ANY code moves:                         │     │
│     │                                                │     │
│     │ Paul: Write characterization tests for any     │     │
│     │   behavior NOT already covered by tests.       │     │
│     │   These capture CURRENT behavior (even if      │     │
│     │   ugly) so we can prove it's preserved.        │     │
│     │                                                │     │
│     │ Goal: 100% coverage on affected code BEFORE    │     │
│     │   refactoring starts.                          │     │
│     │                                                │     │
│     │ → User: "Characterization tests written.      │     │
│     │   All green. Coverage on affected area: 100%.  │     │
│     │   Safe to proceed with restructuring?"         │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  3. /design (Target Structure)                             │
│     ┌────────────────────────────────────────────────┐     │
│     │ Dmitri: Propose the target structure           │     │
│     │ - New component boundaries                    │     │
│     │ - New interfaces / contracts                  │     │
│     │ - Migration path (how to get there safely)    │     │
│     │                                                │     │
│     │ Paul: "I need [X] to keep testing this"       │     │
│     │ Igor: "This doesn't change behavior for [Y]?" │     │
│     │                                                │     │
│     │ → User: "Target structure: [diagram].         │     │
│     │   Migration approach: [strategy]. Approve?"    │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  4. MOVE UNDER GREEN (Dmitri + Paul pair, User navigates)  │
│     ┌────────────────────────────────────────────────┐     │
│     │ XP Refactoring discipline:                     │     │
│     │                                                │     │
│     │ For each refactoring step:                    │     │
│     │   a. All tests GREEN (precondition)           │     │
│     │   b. Dmitri makes ONE structural change       │     │
│     │   c. Run ALL tests                            │     │
│     │   d. Still GREEN? → continue                  │     │
│     │   e. RED? → revert immediately, smaller step  │     │
│     │                                                │     │
│     │ → User sees each step:                        │     │
│     │   "Step N: [what moved]. Tests: still green.  │     │
│     │   Continue?"                                   │     │
│     │                                                │     │
│     │ Paul: Update test structure to match new code  │     │
│     │   organization (tests move too, but behavior   │     │
│     │   assertions unchanged)                        │     │
│     │                                                │     │
│     │ SM: Traceability updated (code moved → traces  │     │
│     │   update to point to new locations)            │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  5. VERIFY NFRs (Paul)                                     │
│     ┌────────────────────────────────────────────────┐     │
│     │ Run NFR test suite:                            │     │
│     │ - Performance: no regression (same or better)  │     │
│     │ - Security: same protection                   │     │
│     │ - Resilience: same failure handling            │     │
│     │                                                │     │
│     │ → User: "NFRs verified. No regression.        │     │
│     │   [Improvements if any]. Ready to deploy?"     │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  6. /deploy-and-validate (full)                            │
│     dev → test → staging (User approves)                   │
│                                                            │
│  7. /release (full)                                        │
│     Production + smoke + feedback                          │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Safety Rules

- **Never refactor and change behavior at the same time** — one or the other per commit
- **Tests stay green at every step** — if red, revert and take smaller steps
- **Characterize before touching** — untested code gets characterization tests FIRST
- **Coverage cannot drop** — refactoring often reveals dead code; remove it (with traceability update)
- **Traceability updates** — when code moves, trace matrix updates to new locations
- **Small steps** — each commit is a single refactoring move that keeps tests green

## Common Refactoring Motivations

| Motivation | Design Focus | Key Risk |
|---|---|---|
| Extract service/module | New boundaries, interfaces | Breaking hidden dependencies |
| Replace inheritance with composition | New contracts | Behavioral subtlety in overrides |
| Consolidate duplicates | Shared abstraction | Slight behavioral differences between copies |
| Improve performance | New data structures/algorithms | Different behavior under edge cases |
| Improve testability | Dependency injection, interfaces | Accidental behavior change in seams |
| Tech debt paydown | Clearer structure | Everything above |

## Outputs

```
backlog/done/<refactor-slug>/
  scope.md              — What was refactored and why
  design.md             — Target structure
  characterization.md   — Tests added before refactoring
  traceability.md       — Updated traces (new code locations)
  status.md             — "refactored and released on <date>"
```

## Invocation

```bash
/refactor "Extract payment processing into its own service"
/refactor --scope "src/services/monolith.ts"    — Scope to specific files
/refactor --status                              — Show progress
```
