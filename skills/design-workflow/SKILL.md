---
name: design-workflow
description: Design durable, long-running workflows (Temporal, Step Functions, Camunda) — state machines, sagas, human signals, compensation, and versioning. Produces workflow definitions with replay-safe tests.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /design-workflow — Durable Workflow Design Loop

The **Design Workflow** loop produces workflow definitions for long-running, durable orchestration. These are fundamentally different from normal application code — they run for minutes to months, must be deterministic under replay, handle human-in-the-loop signals, need versioning for safe updates, and require saga patterns for compensation on failure.

Use this loop when the system needs orchestration that outlives a single request: multi-step processes with human approvals, distributed sagas with compensation, scheduled recurring work, or state machines that run for days/weeks/months.

## Context Check (Before Starting)

Before starting, verify:
- `docs/engagement/codebase-patterns.md` — Workflow engine chosen (Temporal, Step Functions, Camunda, etc.)
- `docs/engagement/environments.md` — Workflow server deployment topology (cloud managed, self-hosted, test server available)
- `docs/engagement/team.md` — Who are the human participants in workflows? (approvers, escalation targets)

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

**Critical prerequisite:** The workflow engine must be selected before this loop runs. If undecided, run `/spike` first to evaluate engine options.

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Architect** | Archie | Workflow boundaries, state model, failure modes, versioning strategy |
| **Scenario writer** | Igor | Gherkin scenarios covering happy path, failures, timeouts, version migration |
| **Validator** | Paul | Determinism review, replay safety, compensation completeness, edge cases |
| **Implementer** | Dmitri | Workflow code, activities, replay tests, integration tests |
| **Navigator** | User | Approves state model, confirms human touchpoints, validates business intent |

## Workflow Contract (Entry Criteria)

Every workflow design starts with:

```
Name:           [Descriptive name — verb-noun: "complete-task-cascade", "sync-template-version"]
Trigger:        [What starts it — event, signal, schedule, API call, child spawn]
States:         [High-level state machine — initial → ... → terminal]
Human touches:  [Where humans interact — approvals, signals, escalation targets]
Duration:       [Expected lifetime — seconds | minutes | hours | days | weeks | months]
Failure modes:  [What can fail mid-flight — downstream services, timeouts, invalid state]
Compensation:   [What needs to be undone if the workflow fails partway through]
```

## The Loop

```
┌─────────────────────────────────────────────────────────────┐
│  1. Archie models the workflow                              │
│     - State diagram (states + transitions + guards)         │
│     - Trigger and terminal conditions                       │
│     - Human signal points (with timeouts + escalation)      │
│     - Activity boundaries (what's an activity vs. workflow) │
│     - Failure + compensation strategy                       │
│     User approves: "This matches the business process"      │
│                                                             │
│  2. Igor writes workflow scenarios (Gherkin)                 │
│     - Happy path (all steps succeed, all humans respond)    │
│     - Partial failure + compensation                        │
│     - Human timeout + escalation                            │
│     - Concurrent signals (signal arrives in unexpected state)│
│     - Version migration (in-flight workflow, code updated)  │
│     Paul validates: "These cover the edge cases"            │
│                                                             │
│  3. Paul validates determinism + safety                     │
│     - No side effects in workflow code (only in activities) │
│     - Replay safe (same input → same decisions on replay)   │
│     - Compensation complete (every action has a reverse)    │
│     - Idempotent activities (safe to retry)                 │
│     - Signal handling in every possible state               │
│     - Timer behavior under replay                           │
│     User approves: "Risk profile acceptable"                │
│                                                             │
│  4. Dmitri implements                                       │
│     - Workflow definition (orchestration only — no I/O)     │
│     - Activity definitions (the actual work — I/O lives here)│
│     - Replay tests (workflow replays correctly from history) │
│     - Integration tests (with workflow test server)         │
│     - Versioning setup (how to update without breaking      │
│       in-flight executions)                                 │
│     Paul reviews: "Tests prove replay safety"               │
│                                                             │
│  5. User validates end-to-end                               │
│     - State model matches business intent                   │
│     - Human touchpoints are correct (right people, right    │
│       timeout, right escalation)                            │
│     - Failure handling matches risk tolerance               │
│     □ Approved → integrate into system                      │
│     □ Adjust → loop back to step 1 or 2                    │
│     □ Kill → this process doesn't need durable workflow     │
└─────────────────────────────────────────────────────────────┘
```

## Workflow Patterns

### Saga (Sequential with Compensation)
Each step has a corresponding undo. If step N fails, compensate steps N-1 through 1 in reverse order.

```
Step 1: Reserve inventory    → Compensate: Release inventory
Step 2: Charge payment       → Compensate: Refund payment
Step 3: Ship order           → Compensate: Cancel shipment
```

Use when: multi-step process where partial completion leaves the system in an inconsistent state.

### Scatter-Gather (Fan-Out + Collect)
Spawn N child workflows or activities in parallel, collect results, continue when all (or sufficient) complete.

```
Fan out: Start review for each affected project
Gather:  Wait for all reviews (with timeout per reviewer)
Continue: Apply approved changes, flag timed-out reviews for escalation
```

Use when: the same operation needs to happen across many entities independently.

### Human-in-the-Loop (Signal + Timeout)
Workflow pauses and waits for a human signal. If no signal within timeout, escalate or auto-decide.

```
Request approval → Wait for signal (max 3 days)
  → Signal "approved": continue
  → Signal "rejected": compensate + terminate
  → Timeout: escalate to manager, wait 1 more day
    → Still no response: auto-reject + notify
```

Use when: business process requires human judgment that can't be automated.

### Scheduled (Recurring)
Workflow that runs on a schedule (cron-like). Each execution is independent.

```
Every Monday 9am: Check SLA compliance for all active projects
  → For each violation: create escalation task + notify owner
```

Use when: periodic checks, maintenance tasks, report generation.

### Long-Running State Machine
Workflow that lives for weeks/months, transitioning between states based on external events.

```
States: Draft → Active → Paused → Completing → Closed
Transitions driven by: signals, timers, child workflow completion
Lifetime: months (entire project lifecycle)
```

Use when: the workflow IS the entity lifecycle (project, case, claim, onboarding).

## Rules (Non-Negotiable)

| Rule | Why |
|---|---|
| **Activities do the work, workflows do the orchestration** | Workflow code replays on recovery — side effects in workflow code execute twice |
| **Never put I/O in workflow code** | Network calls, DB writes, file operations = non-deterministic under replay |
| **Always handle timeout on human signals** | Humans forget, go on vacation, leave the company. Workflow must not hang forever |
| **Version workflows before updating in-flight logic** | Changing workflow code while executions are running can corrupt state |
| **Activities must be idempotent** | Retries happen. An activity that charges a credit card must handle being called twice |
| **Compensation must be defined BEFORE implementation** | Afterthought compensation has gaps. Design it first |
| **Log decisions, not data** | Workflow history grows unbounded — log state transitions, not payload contents |
| **Test with replay, not just execution** | A workflow that works on first run but fails on replay has a latent bug |

## Determinism Checklist (Paul Validates)

The following are FORBIDDEN in workflow code (allowed only in activities):

- [ ] `Date.now()` / `new Date()` — use workflow clock
- [ ] `Math.random()` — use deterministic seed from workflow input
- [ ] Network calls (HTTP, gRPC, DB queries) — wrap in activity
- [ ] File system access — wrap in activity
- [ ] Global mutable state — workflow state only
- [ ] Non-deterministic iteration order (object keys, Set, Map without sort)
- [ ] Conditional logic based on external state — only on workflow state + signals
- [ ] `setTimeout` / `setInterval` — use workflow timer primitives
- [ ] Logging that includes timestamps — use workflow-provided logger

## Outputs

```
backlog/active/<feature-slug>/workflows/
  <workflow-name>/
    design.md           — State diagram, trigger, states, compensation strategy
    scenarios.feature   — Gherkin scenarios (happy, failure, timeout, version)
    activities.ts       — Activity interfaces (contracts before implementation)
    workflow.ts         — Workflow implementation
    workflow.test.ts    — Replay tests + integration tests
    versioning.md       — Strategy for updating this workflow safely
```

## Invocation

```bash
# Design a new workflow
/design-workflow "Task completion cascade — when a task completes, unblock successors and notify"

# Design with explicit pattern
/design-workflow --saga "Template sync — apply version update to in-flight projects with rollback"
/design-workflow --human-in-loop "Design approval — route to reviewer, escalate on timeout"
/design-workflow --scheduled "SLA monitor — check deadlines daily, escalate violations"

# List active workflow designs
/design-workflow --list

# Resume a workflow design
/design-workflow --continue <slug>
```
