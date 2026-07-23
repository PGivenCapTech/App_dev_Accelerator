---
name: test-and-develop
description: Test & Develop loop — XP-style pairing (Paul + Dmitri + User as navigator). Ping-pong TDD, BDD outside-in, continuous integration. User approves every test/impl pair.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /test-and-develop — Test & Develop Loop (XP Pairing + BDD Outside-In)

The **Test & Develop** loop is where code gets written. Paul and Dmitri work as a **pair** with the User as navigator — tight ping-pong TDD cycles, outside-in from BDD scenarios, every test/implementation pair presented to the User for approval.

## Participants (Pair + Navigator)

| Role | Agent | Contribution |
|---|---|---|
| **Test driver** | Paul | Writes failing tests (the contract) |
| **Implementation driver** | Dmitri | Makes tests pass (the solution) |
| **Navigator** | User | Approves each cycle, steers direction, catches misunderstandings early |
| **On-call** | Igor | Clarifies behavior if scenarios are ambiguous |

## Entry Criteria

- Feature has passed /design
- `backlog/ready/<slug>/design.md` exists
- `backlog/ready/<slug>/feature.md` has approved scenarios
- No open spikes blocking this feature

## The Pairing Loop (Ping-Pong TDD)

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  OUTER LOOP: Per Scenario (BDD Outside-In)              │
│  ┌────────────────────────────────────────────────────┐  │
│  │                                                    │  │
│  │  1. Paul writes ACCEPTANCE test (failing)          │  │
│  │     - Step definition for one scenario             │  │
│  │     - Integration test skeleton                    │  │
│  │     → Presents to User: "This is the contract.    │  │
│  │       Does this test the right behavior?"          │  │
│  │     → User approves / adjusts                     │  │
│  │                                                    │  │
│  │  INNER LOOP: Per Unit (TDD Red-Green-Refactor)    │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │                                              │ │  │
│  │  │  2. Paul writes UNIT test (failing) — RED    │ │  │
│  │  │     → Shows User: "Testing [specific unit]"  │ │  │
│  │  │     → User: "Go ahead" / "Not quite"        │ │  │
│  │  │                                              │ │  │
│  │  │  3. Dmitri implements MINIMUM code — GREEN   │ │  │
│  │  │     → Shows User: "This makes it pass"      │ │  │
│  │  │     → User: "Looks right" / "Concern"       │ │  │
│  │  │                                              │ │  │
│  │  │  4. Dmitri refactors — REFACTOR              │ │  │
│  │  │     → Shows User: "Cleaned up, still green" │ │  │
│  │  │     → User: "Clean" / "I'd prefer..."       │ │  │
│  │  │                                              │ │  │
│  │  │  5. Still failing at acceptance level?       │ │  │
│  │  │     □ Yes → loop (next unit test)           │ │  │
│  │  │     □ No → acceptance test passes! ✅        │ │  │
│  │  │                                              │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                    │  │
│  │  6. Acceptance test GREEN ✅                       │  │
│  │     → Present to User: "Scenario [X] passes.     │  │
│  │       Here's what we built. Next scenario?"       │  │
│  │     → User approves                              │  │
│  │                                                    │  │
│  │  7. More scenarios?                               │  │
│  │     □ Yes → next scenario (outer loop)           │  │
│  │     □ No → all scenarios pass → exit             │  │
│  │                                                    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  8. NFR scenarios (same ping-pong pattern)              │
│     Paul writes perf/security/resilience tests          │
│     Dmitri implements to meet thresholds                │
│     User approves each                                  │
│                                                          │
│  9. SM verifies gates:                                  │
│     □ All scenarios green                               │
│     □ Traceability 100%                                 │
│     □ Coverage 100%                                     │
│     □ No orphan code                                    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## XP Practices Embedded

| XP Practice | How It Works Here |
|---|---|
| **Pair programming** | Paul + Dmitri alternate driving, User navigates |
| **TDD** | Red → Green → Refactor on every unit |
| **Continuous integration** | Build + all tests run after every green cycle |
| **Small releases** | Each scenario is a releasable increment |
| **Collective ownership** | Paul can suggest impl changes, Dmitri can suggest test changes |
| **Simple design** | Dmitri implements MINIMUM to pass — no speculative code |
| **Refactoring** | Explicit step after every green — User sees it happen |
| **Sustainable pace** | One scenario at a time, no batch accumulation |

## BDD Outside-In Flow

The development proceeds outside-in:

```
Acceptance test (Paul)          → Defines external behavior
  ↓ drives
Integration test (Paul)         → Defines API contract
  ↓ drives
Unit test (Paul)                → Defines component interface
  ↓ drives
Implementation (Dmitri)         → Satisfies unit test
  ↑ bubbles up
Integration passes              → API works
  ↑ bubbles up
Acceptance passes               → Behavior correct ✅
```

## User Checkpoints (Every Cycle)

The User sees and approves at EACH of these points:

1. **Before test**: "Paul is about to test [X]. Is this the right thing to test?"
2. **After test written**: "Here's the failing test. Does it capture the right expectation?"
3. **After implementation**: "Dmitri made it pass with [approach]. Look right?"
4. **After refactor**: "Cleaned up. Still green. Acceptable?"
5. **After scenario complete**: "Full scenario passes. Ready for next?"

If the User says "not quite" at ANY point → loop addresses their concern before continuing.

## Coverage and Traceability (Maintained Live)

As each test/impl pair lands:
- Traceability matrix updates immediately (scenario → test → code)
- Coverage report updates (must stay at 100% — no untested code)
- Event flow mapping updates if new events introduced

SM verifies after each scenario (not just at the end):
- "Scenario 3 of 7 complete. Traceability: 100%. Coverage: 100%. Continue?"

## Outputs

After the loop completes (all scenarios green):

```
src/test/                       — Complete test suite (Paul)
  features/                     — Step definitions wired to scenarios
  unit/                         — Unit tests (100% coverage)
  integration/                  — API + database tests
  nfr/                          — Performance, security, resilience tests
src/main/                       — Production code (Dmitri)
backlog/active/<slug>/
  traceability.md              — 100% complete
  status.md                    — "developed — all scenarios green"
```

## Invocation

```bash
/test-and-develop                    — Start for current designed feature
/test-and-develop <feature-slug>     — Start for specific feature
/test-and-develop --status           — Show progress (scenarios green/total, coverage %)
/test-and-develop --resume           — Resume from last approved scenario
```
