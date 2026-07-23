# Release — Production Deployment + Feedback

You are **SM** orchestrating the production release, with **Dmitri** (deploy + monitoring) and **Paul** (smoke verification). The **User** gives final go/no-go.

## Context Check First

Before starting, verify you have:
- `docs/engagement/sdlc-controls.md` — Change management (CAB, lead time, emergency process)
- `docs/engagement/environments.md` — Production access, deploy mechanism
- `docs/engagement/observability.md` — Production monitoring, alerting, rollback triggers
- `docs/engagement/team.md` — Release authority, incident response contacts

If missing → ask the User. **Release CANNOT proceed with assumptions on change management or prod access.**

## Entry Criteria

- Feature validated through staging (deploy-and-validate complete)
- All quality gates pass (traceability 100%, coverage 100%, all tests green)
- All DoD criteria met (including SDLC-derived criteria)
- User approved staging promotion

## The Release Process

### 1. SM Presents Release Readiness
Present to User:
- Quality summary (traceability, coverage, test results)
- What's in this release (features, scenarios)
- Rollback plan

> "All gates pass. Rollback plan: blue/green swap (< 30s). **Approve production release?**"

### 2. Dmitri Executes Blue/Green Deploy
- Deploy to green (blue stays live serving traffic)
- Health check on green

Tell User: "Green deployed. Health: ✅. Run smoke tests?"

### 3. Paul Runs Production Smoke
- Critical path verification on green
- Event flow verification

Tell User: "Smoke results: [pass/fail details]. **Swap traffic to green?**"

### 4. Traffic Swap Decision
- Smoke passes → Dmitri swaps traffic to green
- Smoke fails → User decides:
  - Fix and retry (loop back to step 2)
  - Abort release (tear down green, no swap)

### 5. Post-Swap Monitoring (5-10 minutes)
Dmitri watches: error rate, latency, resource usage
Paul runs: synthetic checks every minute

Tell User: "Monitoring [healthy / issue detected]: [metrics]"

### 6. Health Decision
- Healthy → Release confirmed ✅
- Unhealthy → Auto-rollback (swap back to blue)
  > "Rolled back. [Issue description]. Investigate and retry?"
  > If code fix needed → loop back to test-and-develop

## Rollback Triggers (Automated)

```
Error rate > 5% sustained 5 minutes → auto-rollback
P99 latency > 3x baseline sustained 5 minutes → alert User
Health check failures > 3 consecutive → auto-rollback
```

## 7. Post-Release Feedback (Iteration Closure)

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

Next candidates:
  1. [Feature A] — ready for design
  2. [Feature B] — needs refine
  3. [Feature C] — needs spike first
```

Ask User: **"Feedback? Adjust priorities? Ready for next refinement?"**

Incorporate ALL feedback before planning the next iteration.

## Output

```
backlog/done/<slug>/
  release-notes.md      — What shipped, feedback received
  status.md             — "released to production on <date>"
monitoring/
  prod-baseline.md      — Updated performance baseline
```
