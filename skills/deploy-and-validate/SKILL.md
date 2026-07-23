---
name: deploy-and-validate
description: Deploy & Validate loop — push through environments (dev → test → staging), validate at each level, loop back if validation fails. User approves promotions.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /deploy-and-validate — Deploy & Validate Loop

The **Deploy & Validate** loop pushes code through environments and validates at each level. If validation fails at any environment, the loop cycles back — fix, re-validate, then promote. User approves each promotion.

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Infrastructure** | Dmitri | IaC, deploy scripts, monitoring, rollback |
| **Validation** | Paul | Environment-specific test suites, quality gates |
| **Navigator** | User | Approves each promotion, decides on failures |

## Entry Criteria

- Feature completed /test-and-develop (all scenarios green)
- Traceability = 100%
- Coverage = 100%
- SM confirms readiness

## The Loop (Per Environment)

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  For each environment: dev → test → staging             │
│  ┌───────────────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  1. Dmitri deploys to [environment]               │  │
│  │     - Update IaC (CDK deploy)                    │  │
│  │     - Deploy application artifact                │  │
│  │     - Verify health checks                       │  │
│  │     → User: "Deployed to [env]. Health: ✅"      │  │
│  │                                                   │  │
│  │  2. Paul validates in [environment]               │  │
│  │     - Run environment-specific test suite        │  │
│  │     - Check quality gates for this level         │  │
│  │     → User: "Validation results: [summary]"     │  │
│  │                                                   │  │
│  │  3. Validation passed?                            │  │
│  │     □ Yes → User approves promotion              │  │
│  │       → User: "All gates pass. Promote to        │  │
│  │         [next env]? Approve / Hold / Investigate" │  │
│  │     □ No → diagnose and fix                      │  │
│  │       → User: "[N] failures: [summary].          │  │
│  │         Fix and re-validate? Or rollback?"       │  │
│  │       → Fix loop:                                │  │
│  │         Paul diagnoses failure                   │  │
│  │         Dmitri fixes                             │  │
│  │         Redeploy to same environment             │  │
│  │         Re-validate (loop back to step 2)       │  │
│  │                                                   │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Environment Validation Suites

### Dev Environment
```
Dmitri deploys: auto on green build
Paul validates:
  □ Application starts successfully
  □ Health endpoint responds
  □ Smoke tests pass (critical paths)
  □ Domain events publishing correctly
  □ Database migrations applied cleanly
```

### Test Environment
```
Dmitri deploys: after dev validation passes
Paul validates:
  □ ALL BDD scenarios pass (full regression)
  □ ALL integration tests pass
  □ ALL unit tests pass (in CI, confirms no env-specific issues)
  □ Coverage verified = 100%
  □ Traceability verified = 100%
  □ SAST security scan clean
  □ NFR tests pass:
    - Performance within thresholds
    - Security scenarios pass
    - Resilience scenarios pass
```

### Staging Environment
```
Dmitri deploys: after test validation + User approval
Paul validates:
  □ Smoke test suite (fast subset)
  □ Performance baseline comparison (no regression)
  □ Integration with external dependencies (real, not mocked)
  □ Data migration on production-like data
  □ Monitoring/alerting firing correctly
```

## AWS Default Infrastructure Per Environment

| Resource | Dev | Test | Staging |
|---|---|---|---|
| Compute | Fargate 0.5vCPU/1GB | Fargate 1vCPU/2GB | Fargate 2vCPU/4GB (prod mirror) |
| Database | RDS t3.micro | RDS t3.small | RDS t3.medium, multi-AZ |
| Events | EventBridge (shared) | EventBridge (isolated) | EventBridge (prod mirror) |
| Monitoring | Basic CloudWatch | Enhanced + X-Ray | Full + Alarms |

## Failure Handling

When validation fails:

```
Paul: "Integration test X failed in [env]. Root cause: [diagnosis]."
  → User: "Fix in place and re-validate, or roll back?"

If fix:
  Dmitri fixes code/config
  Paul verifies fix locally
  Dmitri redeploys to same environment
  Paul re-runs validation suite
  → Loop until green or User decides to roll back

If rollback:
  Dmitri reverts to previous known-good
  Paul confirms previous version healthy
  → User decides: fix in /test-and-develop loop or investigate further
```

## Outputs

After each environment passes:

```
backlog/active/<slug>/
  status.md              — "deployed to [env], validated"
  deploy-log.md          — What was deployed where, when, validation results

monitoring/
  <env>-baseline.md      — Performance baseline for comparison
```

## Invocation

```bash
/deploy-and-validate                    — Deploy current feature through all environments
/deploy-and-validate --to dev           — Deploy to dev only
/deploy-and-validate --to test          — Promote to test (requires User approval)
/deploy-and-validate --to staging       — Promote to staging (requires User approval)
/deploy-and-validate --status           — Show current state per environment
/deploy-and-validate --rollback <env>   — Rollback specified environment
```
