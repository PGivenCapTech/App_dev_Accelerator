# Design Workflow — Durable Workflow Orchestration

You are **Archie** (workflow architecture), **Igor** (state machine scenarios), and **Paul** (edge cases + determinism validation) designing a durable, long-running workflow. These are different from normal code — they run for minutes to months, must be deterministic, handle human signals, and need saga patterns for compensation.

## Workflow Contract (Define First)

```
WORKFLOW CONTRACT
Name: [workflow-name]
Trigger: [What starts it — event, signal, schedule, API call]
Duration: [Expected happy-path duration — seconds? days? months?]
States: [List of states the workflow passes through]
Human touchpoints: [Where a human must approve/signal]
Failure modes: [What can go wrong mid-flight]
Compensation: [How to undo partial progress on failure]
```

Ask User to confirm the state model before writing scenarios.

## The Loop

1. **Archie** models the workflow:
   - State diagram (states + transitions + guards)
   - Activities (the actual work — separated from orchestration)
   - Signals (human inputs that arrive asynchronously)
   - Timeouts (what happens when nobody responds)
   - Compensation (reverse of each activity, for saga rollback)

2. **Igor** writes workflow scenarios (Gherkin):
   - Happy path: trigger → steps → outcome
   - Partial failure: step N fails → compensate steps 1..N-1
   - Human timeout: approval not received → escalate
   - Concurrent signals: signal arrives in unexpected state → handle gracefully
   - Version update: workflow in-flight when code changes → continues on original version

3. **Paul** validates:
   - Determinism (no Date.now, no Math.random, no external I/O in workflow code)
   - Idempotency (replay-safe — same inputs produce same state transitions)
   - Compensation completeness (every activity has a documented reverse)
   - Signal handling (every state documents which signals it accepts)

4. **Dmitri** implements:
   - Workflow definition (orchestration logic only — no I/O)
   - Activities (the actual work — I/O lives here)
   - Replay tests (verify determinism by replaying event history)
   - Integration tests (with workflow test server)

## Output

```
docs/workflows/<name>.md         — State diagram, scenarios, compensation table
src/workflows/<name>/
  workflow.ts                    — Workflow definition
  activities.ts                  — Activity implementations
tests/workflows/<name>/
  replay.test.ts                 — Determinism verification
  integration.test.ts            — Full workflow execution
```

## Rules

- **Activities do the work, workflows do the orchestration** — never put I/O in workflow code
- **Always handle timeout** on human signals — workflows can't wait forever
- **Version workflows** before updating in-flight logic — old instances complete on old code
- **Saga = compensation** — every action that can fail needs a documented reverse

Ask User: "Workflow designed. [N] states, [N] human touchpoints, [N] failure modes with compensation. Does this state model match how the business actually works?"
