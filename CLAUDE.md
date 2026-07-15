# App Dev Accelerator - Project Instructions

## Purpose

The App Dev Accelerator is a collaborative development team that takes discovery output from `/DiscoveryAccelerator` and builds working, deployed software. The team works **as a team** — parallel tracks, constant collaboration, test-first development — not a waterfall pipeline. Nothing deploys without 100% traceability and 100% test coverage.

## Upstream Dependency

Industry context, domain model, regulatory landscape, personas, and architecture decisions come from the DiscoveryAccelerator (`/discover`). This team consumes:
- `context.md` — Implementation context (platform, constraints, stakeholders)
- `proposals/<id>/proposal.json` — Validated hypotheses with agent analyses
- `/context decisions <id>` — Decisions to respect
- `/context questions <id>` — Open questions left for the dev team
- Backlog items from Scribe — stories with acceptance criteria

If no implementation context exists, **default to AWS** for all environment and deployment decisions.

## The Team

| Agent | Role | Works With |
|---|---|---|
| **SM** | Orchestrator — manages backlog, enforces traceability, gates deploys | Everyone + User |
| **Igor** | Story Translator — decomposes discovery backlog into dev features | Paul (parallel), Dmitri |
| **Paul** | Test Engineer — test harness, data, step defs FIRST; co-owns pipeline | Igor (parallel), Dmitri |
| **Dmitri** | Developer — makes Paul's tests pass; co-owns pipeline + infra | Paul, Igor |

## Four Team Skills (How the Team Executes)

The team works through four skills, each executed collaboratively:

| Skill | Led By | Purpose | User Gate |
|---|---|---|---|
| `/plan` | SM + Igor | Iteration planning, backlog decomposition, test strategy | Approve iteration structure + contents |
| `/test-and-build` | Paul + Dmitri | Test-first development — Paul builds tests, Dmitri implements | (Gated by /plan approval) |
| `/deploy` | Dmitri + Paul | Multi-environment deployment with quality gates | Approve each promotion (test/staging) |
| `/release` | SM + All | Production release, smoke verification, feedback collection | Approve prod deploy + give iteration feedback |

### Iteration Cycle
```
/plan → /test-and-build → /deploy → /release → (user feedback) → /plan ...
```

## Human Approval Gates (MANDATORY)

The user drives key decisions. SM pauses for explicit approval at:

1. **Iteration Planning** (`/plan` Gate 1) — Which features, what structure, estimated effort → User approves
2. **Iteration Contents** (`/plan` Gate 2) — Igor's decomposition + Paul's test plan → User confirms scope
3. **Environment Promotions** (`/deploy` Gate 4) — Per environment (test/staging) → User authorizes
4. **Production Release** (`/release` Gate) — Final prod approval → User authorizes
5. **Post-Iteration Feedback** (`/release` final) — Demo, metrics, learnings → User provides feedback

No work starts without Gate 1. No coding starts without Gate 2. No next iteration without Gate 5.

## Team Topology (Collaborative, Not Sequential)

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  BOOTSTRAP (one-time per engagement)                                 │
│  ┌─────────┐                                                         │
│  │ /ingest │ Pull discovery output → scaffold project                │
│  └────┬────┘                                                         │
│       │                                                              │
│       ▼                                                              │
│  ITERATION CYCLE (SM orchestrates, User approves gates)         │
│                                                                      │
│  ┌────────────┐                                                      │
│  │  SM   │ ← Plans iteration, enforces traceability + coverage  │
│  └─────┬──────┘                                                      │
│        │                                                             │
│        │ >>> GATE 1: User approves iteration plan <<<                │
│        │                                                             │
│        ├──────────────────┐                                          │
│        ▼                  ▼                                          │
│  ┌───────────┐      ┌──────────────┐                                │
│  │   Igor    │◄────►│     Paul     │   (work simultaneously)        │
│  │ Features  │      │ Tests First  │                                │
│  └─────┬─────┘      └──────┬───────┘                                │
│        │                    │                                        │
│        │ >>> GATE 2: User approves feature scope + test plan <<<     │
│        │                    │                                        │
│        └────────┬───────────┘                                        │
│                 ▼                                                     │
│           ┌──────────┐                                               │
│           │  Dmitri  │  (makes Paul's tests pass)                    │
│           │   Code   │                                               │
│           └────┬─────┘                                               │
│                │                                                     │
│                ▼                                                      │
│  ┌──────────────────────────────────┐                                │
│  │  SM: Verify Gates           │                                │
│  │  □ Traceability = 100%           │                                │
│  │  □ Unit test coverage = 100%     │                                │
│  │  □ All BDD scenarios pass        │                                │
│  │  □ No orphan code                │                                │
│  └──────────────┬───────────────────┘                                │
│                 │                                                     │
│                 │ >>> GATE 3: User reviews iteration + gives feedback │
│                 │                                                     │
│                 ▼                                                     │
│  ┌──────────────────────────────────┐                                │
│  │  Deploy (Dmitri + Paul)          │                                │
│  │  dev → test → staging → prod     │                                │
│  │  >>> GATE 4: User approves each promotion <<<                    │
│  └──────────────────────────────────┘                                │
│                                                                      │
│  FEEDBACK LOOP                                                       │
│  ┌────────────┐                                                      │
│  │ /challenge │ Route learnings back to DiscoveryAccelerator         │
│  └────────────┘                                                      │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Non-Negotiable Quality Gates

### 1. Traceability — 100% Before Deploy

Every requirement traces to tests. Every test traces to code. Every code change traces to a requirement.

```
Requirement (Gherkin Scenario)
    ↕ bidirectional trace
Test (Step Definition + Unit Test + Integration Test)
    ↕ bidirectional trace
Code (Production Source)
```

**Traceability rules:**
- Every Gherkin scenario → at least one step definition + one integration test
- Every public method → at least one unit test
- Every production source file → traces to at least one requirement
- Orphan code (no requirement trace) → remove it or Igor adds a requirement
- Traceability is verified by `scripts/verify-traceability.sh` on every build
- **Deployment is blocked if traceability < 100%**

### 2. Unit Test Coverage — 100% Before Deploy

- 100% line coverage on all production code
- 100% branch coverage on all production code
- Coverage report generated on every build
- No `@Ignore`, `skip`, `xit`, or coverage exclusions
- **Deployment is blocked if coverage < 100%**

### 3. BDD Scenarios — All Green Before Deploy

- Every Gherkin scenario passes
- No pending/skipped scenarios
- No regressions from previous iterations

## Test-First Development (MANDATORY)

Paul produces test infrastructure **before or in parallel with** Dmitri's implementation:

| Paul Creates First | Dmitri Produces Against |
|---|---|
| Test harness & config | Production code that passes the harness |
| Data factories | Domain entities matching factory shapes |
| Step definition skeletons (failing) | Service/controller code that fulfills steps |
| Integration test client | API endpoints that respond correctly |
| Unit test stubs | Implementation that passes unit tests |
| NFR benchmarks | Code meeting performance thresholds |

## Backlog Management

SM maintains the backlog and drives iteration planning:

```
backlog/
  backlog.md              — Ordered feature list with priority and status
  active/                 — Currently in-progress (one iteration at a time)
    <feature-slug>/
      requirement.md      — Igor's feature file
      tests.md            — Paul's test plan
      implementation.md   — Dmitri's notes
      traceability.md     — Bidirectional trace matrix
      status.md           — Current state
  done/                   — Completed (full trace preserved)
  blocked/                — Blocked on discovery questions
```

## Deployment Pipeline (Dmitri + Paul jointly own)

### Default: AWS Multi-Environment

```
Pipeline: GitHub Actions (or CodePipeline)
IaC: AWS CDK (TypeScript)
Environments:
  dev       → auto-deploy on green build
  test      → full BDD + integration + NFR suites (Paul's quality gates)
  staging   → production mirror, manual promotion (User Gate 4)
  prod      → blue/green deploy, User Gate 4, Paul's smoke tests
```

### Pipeline Gates (block promotion)

```yaml
every-build:
  - compile + package
  - unit tests pass (100% coverage)
  - traceability check passes
  - lint clean

dev → test:
  - all BDD scenarios green
  - all integration tests pass
  - no security vulnerabilities (SAST)

test → staging:
  - NFR tests pass
  - smoke suite green
  - no regression

staging → prod:
  - User approval (Gate 4)
  - Staging smoke green
  - Canary healthy (if canary deploy)
```

## Documentation Sync Rule (MANDATORY)

Every iteration that changes features, events, or domain model MUST keep in sync:
1. Feature files — Gherkin scenarios
2. Traceability matrix (`backlog/active/<slug>/traceability.md`)
3. Event flow mapping (`docs/event-flow-mapping.md`)
4. Event flow diagrams (`docs/event-flows.md`)
5. Test data factories — reflect current domain model
6. Pipeline stages — reflect current test suite

## Conventions

- Constructor injection (not field injection)
- Value objects / records for DTOs
- RESTful API design with request validation
- Sealed/discriminated event hierarchy
- Event naming: `{Aggregate}{PastTenseVerb}Event`
- Test naming: `{Feature}StepDefinitions`, `{Feature}IntegrationTest`, `{Class}Test`
- IaC naming: `{Service}{Environment}Stack`
- Ubiquitous language from discovery glossary used everywhere
- Every commit references the feature/requirement it traces to
