---
name: release
description: Release loop — production deployment with blue/green, smoke verification, monitoring, rollback readiness, and post-release feedback. Closes the iteration.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /release — Release Loop (Production + Feedback)

The **Release** loop handles the final step — deploying to production with full safety, verifying health, and collecting post-iteration feedback to feed the next cycle. This closes the iteration.

## Context Check (Before Starting)

Before starting release, verify:
- `docs/engagement/sdlc-controls.md` — Change management (CAB, lead time, emergency process)
- `docs/engagement/environments.md` — Production access, deploy mechanism
- `docs/engagement/observability.md` — Production monitoring, alerting, rollback triggers
- `docs/engagement/team.md` — Release authority (who approves prod), incident response contacts

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).
**Release CANNOT proceed with assumptions on change management or prod access — these must be confirmed.**

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Deploy** | Dmitri | Blue/green production deploy, monitoring, rollback |
| **Verify** | Paul | Production smoke tests, synthetic monitoring |
| **Orchestrate** | SM | Release readiness, user gates, feedback collection |
| **Navigator** | User | Final approval, post-release feedback |

## Entry Criteria

- Feature validated through staging (/deploy-and-validate complete)
- All quality gates pass (traceability 100%, coverage 100%, all tests green)
- Staging smoke tests pass
- User approved staging promotion

## The Loop

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. SM presents release readiness                       │
│     - Quality summary (trace, coverage, tests)         │
│     - What's in this release                           │
│     - Rollback plan                                    │
│     → User: "Approve production release?"              │
│                                                         │
│  2. Dmitri executes blue/green deploy                   │
│     - Deploy to green (blue stays live)                │
│     - Health check on green                            │
│     → User: "Green deployed, health: ✅. Run smoke?"   │
│                                                         │
│  3. Paul runs production smoke                          │
│     - Critical path verification on green              │
│     - Event flow verification                          │
│     → User: "Smoke results: [pass/fail]. Swap traffic?"│
│                                                         │
│  4. Swap traffic?                                       │
│     □ Smoke passes → Dmitri swaps traffic to green     │
│     □ Smoke fails → User decides:                      │
│       - Fix and retry (loop back to step 2)           │
│       - Abort release (no traffic swap, green torn down)│
│                                                         │
│  5. Post-swap monitoring (5-10 minutes)                 │
│     - Dmitri watches: error rate, latency, resources   │
│     - Paul runs: synthetic checks every minute         │
│     → User: "Monitoring healthy / Issue detected"      │
│                                                         │
│  6. Healthy?                                            │
│     □ Yes → Release confirmed ✅                        │
│     □ No → Auto-rollback (swap back to blue)          │
│       → User: "Rolled back. Investigate and retry?"   │
│       → Loop back to /test-and-develop if code fix needed│
│                                                         │
│  7. Post-Release Feedback (iteration closure)           │
│     SM presents:                                       │
│     - What shipped, for whom                           │
│     - Quality metrics                                  │
│     - What was learned                                 │
│     - Demo of working feature                          │
│     - Next iteration candidates                        │
│     → User: "Feedback? Adjust priorities? Ready for    │
│       next /refine?"                                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Rollback Strategy

```
Triggers (automated):
  - Error rate > 5% sustained 5 minutes → auto-rollback
  - P99 latency > 3x baseline sustained 5 minutes → alert User
  - Health check failures > 3 consecutive → auto-rollback

Mechanism:
  - Blue/green swap (instant, < 30s)
  - Database: migration must be forward-compatible (old code works with new schema)
  - Feature flags: kill switch for new behavior without redeploy

Recovery path:
  - Rollback → diagnose → fix in /test-and-develop → re-enter /deploy-and-validate
```

## Post-Release Feedback (Closes Iteration)

SM presents iteration summary:

```
ITERATION COMPLETE

Features released:
  - [Feature]: [what, for whom, outcome]

Quality:
  - Traceability: 100%
  - Coverage: 100%
  - Scenarios: N (X functional + Y NFR)

Learnings:
  - [Discoveries, challenges raised, assumptions validated]

Demo:
  - [How to exercise the feature]

Backlog impact:
  - [New items surfaced during development]
  - [Items reprioritized based on learnings]
  - [Challenges sent to Discovery]

Next candidates:
  1. [Feature A] — ready for /design
  2. [Feature B] — needs /refine
  3. [Feature C] — needs /spike first
```

**User provides feedback** → SM incorporates into backlog priorities before next iteration.

## Outputs

```
backlog/done/<slug>/
  feature.md            — Requirements (preserved)
  design.md             — Technical design (preserved)
  traceability.md       — Complete trace matrix (preserved)
  release-notes.md      — What shipped, feedback received
  status.md             — "released to production on <date>"

monitoring/
  prod-baseline.md      — Updated performance baseline
```

## Invocation

```bash
/release                   — Release current staging-verified feature to production
/release --dry-run         — Readiness check only (no deploy)
/release --rollback        — Rollback production
/release --status          — Current production health
```
