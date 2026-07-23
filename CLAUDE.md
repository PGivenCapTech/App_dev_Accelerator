# App Dev Accelerator - Project Instructions

## Purpose

A collaborative development team that takes discovery output from `/DiscoveryAccelerator` and builds working, deployed software. Combines leading practices from **XP** (pairing, TDD, continuous integration, small releases), **BDD** (outside-in, examples drive development, living documentation), **FDD** (feature as unit of work, design by feature, build by feature), and **strong NFR testing** (performance, security, resilience as Gherkin scenarios).

Nothing deploys without 100% traceability and 100% unit test coverage.

## Upstream Dependency

Industry context, domain model, regulatory landscape, personas, and architecture decisions come from the DiscoveryAccelerator (`/discover`). This team consumes that output via `/ingest`.

If no implementation context exists, **default to AWS** for all environment and deployment decisions.

## The Team

| Agent | Role | Mindset |
|---|---|---|
| **SM** | Scrum Master — orchestrates loops, manages backlog, enforces quality gates | Facilitator, not gatekeeper |
| **Igor** | Story Translator — behavior, acceptance criteria, domain language | BDD "Business" voice |
| **Paul** | Test Engineer — tests FIRST, regression, NFRs, co-owns pipeline | BDD "Testing" voice, XP pair |
| **Dmitri** | Developer — implements against tests, co-owns pipeline + infra | BDD "Technical" voice, XP pair |
| **User** | Navigator — approves every test/impl pair, steers at every gate | The customer on the XP team |

## Workflows (Compose Loops by Work Type)

Three named workflows compose the loops differently:

| Workflow | When | Loops Used |
|---|---|---|
| `/new-feature` | Net-new functionality | /refine → /spike → /design → /test-and-develop → /deploy-and-validate → /release |
| `/fix-defect` | Bug fix | Reproduce → Root-cause → /test-and-develop (abbreviated) → /deploy-and-validate → /release |
| `/refactor` | Restructure without behavior change | Scope → Characterize → /design → Move-under-green → /deploy-and-validate → /release |

## Core Loops

| Loop | Purpose | Key Practice |
|---|---|---|
| `/refine` | Work item to Definition of Ready | BDD Three Amigos + examples |
| `/spike` | Validate assumptions, time-boxed | Evidence-based, throwaway code |
| `/design` | Technical "how" — FDD Design by Feature | Domain model, events, API contracts, NFR strategy |
| `/test-and-develop` | Build the code — XP pairing + TDD | Paul + Dmitri pair, User navigates every cycle |
| `/deploy-and-validate` | Push through environments, validate each | Loop back on failure, User approves promotions |
| `/release` | Production + feedback | Blue/green, smoke, iteration closure |

## Connection Skills

| Skill | Purpose |
|---|---|
| `/ingest` | Bootstrap from DiscoveryAccelerator or refresh with updates |
| `/challenge` | Feed implementation learnings back to discovery team |

## How the Team Works (XP + BDD + FDD)

### XP Practices

| Practice | How It Works Here |
|---|---|
| **Pair programming** | Paul + Dmitri pair, User navigates (mob model) |
| **TDD** | Red → Green → Refactor on every unit |
| **Continuous integration** | All tests run after every green cycle |
| **Small releases** | Each scenario is a releasable increment |
| **Collective ownership** | Any agent can suggest changes to any artifact |
| **Simple design** | Minimum code to pass tests — no speculation |
| **Refactoring** | Explicit step, explicit workflow (/refactor) |
| **Customer on team** | User present at every decision point |

### BDD Practices

| Practice | How It Works Here |
|---|---|
| **Discovery (examples)** | /refine = Three Amigos workshop with concrete examples |
| **Formulation (Gherkin)** | Igor writes scenarios from examples, Paul validates testability |
| **Automation (tests)** | Paul automates scenarios outside-in before Dmitri codes |
| **Living documentation** | Feature files ARE the documentation — always current |
| **Outside-in** | Acceptance test → integration → unit → implementation |

### FDD Practices

| Practice | How It Works Here |
|---|---|
| **Develop overall model** | Domain model from discovery (/ingest) + refined in /design |
| **Build feature list** | Backlog managed by SM, fed by discovery + feedback |
| **Plan by feature** | SM orchestrates iteration planning |
| **Design by feature** | /design loop per feature before coding |
| **Build by feature** | /test-and-develop per feature |

### NFR as First-Class Tests

NFRs are NOT afterthoughts. They are Gherkin scenarios:

**Inline per feature** (critical NFRs specific to this behavior):
```gherkin
@nfr @performance
Scenario: Response time under load
  Given 1000 concurrent users
  When a user submits a payment
  Then response completes within 200ms at P95
```

**Cross-cutting suites** (system-wide properties):
```
nfr/
  performance.feature     — System-wide latency, throughput
  security.feature        — Authentication, authorization, injection
  resilience.feature      — Failure handling, circuit breakers, fallbacks
  observability.feature   — Logging, tracing, alerting
```

## Human Approval Gates

The User is the navigator — present at every pairing cycle AND at workflow gates:

### Within /test-and-develop (every cycle):
1. Paul writes test → **User: "Right contract?"**
2. Dmitri implements → **User: "Right solution?"**
3. Refactor → **User: "Still clean?"**

### At workflow boundaries:
1. `/refine` exit → **User: "Ready to design?"**
2. `/design` exit → **User: "Approved to build?"**
3. `/deploy-and-validate` promotions → **User: "Promote to [env]?"**
4. `/release` production → **User: "Go live?"**
5. `/release` feedback → **User: "Here's what I'd adjust..."**

## Non-Negotiable Quality Gates

### 1. Traceability — 100%
```
Requirement (Gherkin Scenario) ↔ Test (Step Def + Unit + Integration) ↔ Code (Source)
```
Every direction traced. Orphan code removed or requirement added.

### 2. Unit Test Coverage — 100%
Line + branch. No exclusions. Paul writes all tests.

### 3. BDD Scenarios — All Green
No pending, no skipped, no regressions.

### 4. NFR Scenarios — All Green
Performance, security, resilience within defined thresholds.

## Backlog (Continuously Fed)

The backlog receives input from 5 sources:
1. **Discovery proposals** (`/ingest --refresh`)
2. **Implementation learnings** (`/challenge` → resolved)
3. **User feedback** (`/release` post-iteration)
4. **Technical debt** (identified during development)
5. **Analyst updates** (new compliance/security requirements)

SM maintains `backlog/backlog.md` as single source of truth.

## Deployment (AWS Default)

```
Pipeline: GitHub Actions
IaC: AWS CDK (TypeScript)
Environments: dev → test → staging → prod
Strategy: Blue/green with automated rollback
```

## Conventions

- Constructor injection (not field injection)
- Value objects / records for DTOs
- Sealed/discriminated event hierarchy
- Event naming: `{Aggregate}{PastTenseVerb}Event`
- Test naming: `{Feature}StepDefinitions`, `{Feature}IntegrationTest`, `{Class}Test`
- Every commit references the scenario it satisfies
- Ubiquitous language from discovery glossary
