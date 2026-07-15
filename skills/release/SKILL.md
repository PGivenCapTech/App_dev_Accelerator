---
name: release
description: Team skill — Production release with user approval, blue/green deploy, smoke verification, and post-release feedback loop. Final gate before done.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /release — Production Release (Team Skill)

The **Release** skill is the final step — deploying to production with full safety: user approval, blue/green strategy, smoke verification, monitoring, and rollback readiness. After successful release, SM collects user feedback and closes the iteration.

## Who Participates

| Agent | Role in Release |
|---|---|
| **Dmitri** | Executes: production deploy (blue/green), monitoring, rollback |
| **Paul** | Verifies: production smoke tests, synthetic monitoring, health |
| **SM** | Gates: user approval, post-release feedback collection |
| **User** | Approves: production deploy; provides post-iteration feedback |

## Prerequisites

- `/deploy` completed through staging
- Staging smoke tests pass
- Staging performance within baseline
- All quality gates (traceability 100%, coverage 100%) confirmed
- User approved staging in `/deploy` Gate 4b

## The Process

### Step 1: Release Readiness Check

SM presents release summary to user:

```
RELEASE READINESS: <Feature Name>

Traceability:     100% ✅ (N scenarios → M tests → K source files)
Coverage:         100% ✅ (line + branch)
BDD Scenarios:    N/N pass ✅
Integration:      M/M pass ✅
NFR:              All within thresholds ✅
Staging Smoke:    Pass ✅
Regression:       No regressions ✅

Changes in this release:
- [Feature A]: <summary>
- [Feature B]: <summary> (if multiple features)

Rollback plan:
- Blue/green swap (< 30s)
- DB migration reversible: Yes/No
- Feature flags: [list if applicable]
```

**>>> GATE: User approves production release <<<**

Prompt: "Release is ready. [Summary above]. **Approve production deploy?**"

### Step 2: Production Deploy (After User Approves)

**Dmitri executes:**
1. Deploy new version to green environment (blue stays live)
2. Run health checks on green
3. Paul runs smoke tests against green (not yet receiving traffic)
4. If smoke passes → swap traffic to green (blue becomes standby)
5. Monitor: error rate, latency, health for 5-10 minutes
6. If healthy → mark release successful
7. If unhealthy → auto-rollback (swap back to blue)

**Paul verifies:**
- Production smoke test suite (critical paths only — fast)
- Health endpoint verification
- Domain event flow verification (events publishing correctly)
- Synthetic user journey (if applicable)

### Step 3: Post-Release Monitoring

**Dmitri monitors (first 30 minutes):**
- Error rate vs. baseline (alert if > 2x)
- P50/P95/P99 latency (alert if regression)
- Resource utilization (CPU, memory, connections)
- Domain event processing lag

**Paul runs:**
- Continuous synthetic checks (every 1 minute for 30 minutes)
- Report any degradation immediately

**Rollback triggers (automated):**
- Error rate > 5% for 5 minutes → auto-rollback
- Health check failures > 3 → auto-rollback
- P99 > 3x baseline for 5 minutes → alert SM for decision

### Step 4: Post-Iteration Feedback

After successful production release, SM presents iteration summary to user:

**>>> GATE: Post-iteration feedback <<<**

```
ITERATION COMPLETE: <Iteration N>

Features delivered:
- [Feature A]: <what it does, for whom>
- [Feature B]: <what it does, for whom>

Metrics:
- Traceability: 100%
- Coverage: 100%
- Scenarios: N total (X new this iteration)
- Environments: all healthy

What we learned:
- [Discovery challenge items raised, if any]
- [Technical surprises]
- [Scope adjustments made]

Demo:
- [How to exercise the feature — URL, commands, or walkthrough]

Next iteration candidates (from backlog):
1. [Feature C] — priority: high, effort: M
2. [Feature D] — priority: high, effort: S
3. [Feature E] — priority: medium, effort: L
```

Prompt: "Iteration N is complete and in production. [Summary above]. **Your feedback? Anything to adjust? Ready to /plan the next iteration?**"

### Step 5: Close Iteration

After user provides feedback:
- SM incorporates feedback into backlog priorities
- Move feature from `backlog/active/` to `backlog/done/`
- Preserve full traceability matrix in `backlog/done/<slug>/`
- Update `backlog/backlog.md` with completion notes
- If user raised concerns → create `/challenge` items or adjust upcoming plans
- If user is satisfied → ready for next `/plan`

## Outputs

After `/release` completes:

```
backlog/done/<slug>/
  requirement.md      — Feature file (preserved)
  tests.md            — Test plan (preserved)
  implementation.md   — Dev notes (preserved)
  traceability.md     — Complete trace matrix (preserved)
  status.md           — "released to production on <date>"
  release-notes.md    — What shipped, for whom, user feedback

monitoring/
  prod-baseline.md    — Updated performance baseline post-release
```

## Invocation

```
/release                   — Release current staging-verified iteration to production
/release --dry-run         — Show what would be released (readiness check only)
/release --rollback        — Rollback production to previous version
/release --status          — Show current production state + health
```
