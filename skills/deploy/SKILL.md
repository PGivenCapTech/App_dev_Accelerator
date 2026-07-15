---
name: deploy
description: Team skill — Dmitri + Paul deploy through environments (dev → test → staging). Pipeline, IaC, quality gates per environment. User approves promotions.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /deploy — Multi-Environment Deployment (Team Skill)

The **Deploy** skill is executed by Dmitri and Paul together. Dmitri manages infrastructure and deployment automation; Paul defines quality gates and runs verification per environment. SM gates each promotion with user approval.

## Who Participates

| Agent | Role in Deploy |
|---|---|
| **Dmitri** | Infrastructure: IaC, deploy scripts, monitoring, rollback automation |
| **Paul** | Quality: test stages, smoke tests, gates, rollback triggers |
| **SM** | Gates: user approval per promotion, traceability/coverage still 100% |
| **User** | Approves: each environment promotion (Gate 4) |

## Prerequisites

- `/test-and-build` completed with all gates passing
- Traceability = 100%
- Coverage = 100%
- All BDD + integration + unit tests green
- SM has confirmed readiness

## The Process

### Step 1: Pipeline Definition (first iteration — then maintained)

**Dmitri builds:**
```yaml
pipeline:
  build:
    - compile & package
    - unit tests (100% coverage gate)
    - traceability check
    - SAST security scan
    - lint

  deploy-dev:
    - infrastructure update (CDK/CloudFormation)
    - application deploy
    - Paul's post-deploy smoke

  deploy-test:
    - infrastructure update
    - application deploy
    - Paul's full BDD suite
    - Paul's integration suite
    - Paul's NFR suite
    - coverage verification (100%)
    - traceability verification (100%)

  deploy-staging:
    - infrastructure update (prod-mirror)
    - application deploy
    - Paul's smoke suite
    - performance baseline check
    - manual approval gate (User)

  deploy-prod:
    - manual approval gate (User)
    - blue/green or canary deploy
    - Paul's smoke suite
    - canary health monitoring
    - auto-rollback on threshold breach
```

### Step 2: Deploy to Dev (auto on green build)

**Dmitri:**
- Update IaC (CDK deploy to dev)
- Deploy application artifact
- Verify health check endpoint

**Paul:**
- Run post-deploy smoke tests
- Verify event publishing works end-to-end
- Confirm test data seeding

**SM:**
- Confirm dev is green
- Prompt: "Dev deployment successful. Smoke tests pass. **Promote to test?**"

### Step 3: Deploy to Test (User approves)

**>>> GATE 4a: User approves promotion to test <<<**

**Dmitri:**
- Update IaC (CDK deploy to test — larger instance, multi-AZ optional)
- Deploy application
- Seed test database with Paul's fixtures

**Paul:**
- Run FULL BDD scenario suite
- Run ALL integration tests
- Run NFR tests (performance, security)
- Generate coverage report (must be 100%)
- Run traceability verification (must be 100%)

**SM:**
- All gates pass?
- Prompt: "Test environment: all [N] BDD scenarios pass, [M] integration tests pass, coverage 100%, traceability 100%. NFR results: [summary]. **Promote to staging?**"

### Step 4: Deploy to Staging (User approves)

**>>> GATE 4b: User approves promotion to staging <<<**

**Dmitri:**
- Update IaC (CDK deploy to staging — production mirror)
- Deploy application (same artifact as test)
- Monitoring dashboards active

**Paul:**
- Smoke test suite (subset — fast verification)
- Performance baseline validation (response times within threshold)
- Compare metrics to previous staging deploy

**SM:**
- Confirm staging healthy
- Prompt: "Staging mirrors production. Smoke tests pass. Performance within baseline. **Ready for /release to production?**"

### AWS Default Infrastructure Per Environment

| Resource | Dev | Test | Staging | Prod |
|---|---|---|---|---|
| Compute | Fargate 0.5vCPU/1GB | Fargate 1vCPU/2GB | Fargate 2vCPU/4GB | Fargate 2vCPU/4GB, multi-AZ |
| Database | RDS t3.micro, single-AZ | RDS t3.small, single-AZ | RDS t3.medium, multi-AZ | RDS t3.medium, multi-AZ |
| Cache | None | ElastiCache t3.micro | ElastiCache t3.small | ElastiCache t3.small, replica |
| CDN | None | None | CloudFront | CloudFront |
| Monitoring | Basic CloudWatch | Enhanced + X-Ray | Full + Alarms | Full + Alarms + PagerDuty |

### Rollback Strategy

**Dmitri builds:**
- Blue/green swap capability (instant rollback)
- Database migration rollback scripts
- Feature flag kill switches

**Paul defines triggers:**
- Error rate > 5% sustained 5 min → auto rollback
- P99 latency > 2x baseline → alert + manual review
- Health check failures > 3 consecutive → auto rollback

## Outputs

After `/deploy` completes:

```
infra/                    — IaC stacks deployed per environment
pipeline/                 — CI/CD workflow definitions
scripts/
  deploy-<env>.sh         — Per-environment deploy scripts
  rollback-<env>.sh       — Per-environment rollback scripts
monitoring/
  dashboards/             — CloudWatch dashboard definitions
  alarms/                 — Alarm configurations
backlog/active/<slug>/
  status.md               — "deployed to <env>"
```

## Invocation

```
/deploy                    — Deploy current iteration (follows promotion path)
/deploy --to dev           — Deploy to dev only
/deploy --to test          — Promote to test (requires user approval)
/deploy --to staging       — Promote to staging (requires user approval)
/deploy --status           — Show current deployment state per environment
/deploy --rollback <env>   — Rollback specified environment
```
