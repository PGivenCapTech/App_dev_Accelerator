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

## Initiation & Connection Skills

| Skill | Purpose |
|---|---|
| `/initiate` | Capture engagement context (SDLC, environments, codebase, team, test data, observability) |
| `/ingest` | Bootstrap from DiscoveryAccelerator or refresh with updates |
| `/challenge` | Feed implementation learnings back to discovery team |

## Context-Check Protocol (MANDATORY — Every Loop)

Every loop, before starting substantive work, checks for required engagement context. If missing:

1. **Prompt the User** — "I need [specific thing] to proceed. Can you provide it?"
2. **User provides** → SM documents in `docs/engagement/<area>.md`
3. **User says "skip"** → SM states an assumption and continues with a default
4. **User says "I'll find out"** → SM parks, continues what's possible, asks again later

**Engagement context lives in `docs/engagement/`:**
- `sdlc-controls.md` — Git workflow, change management, security gates, review process
- `environments.md` — Cloud accounts, access, network, secrets, CI/CD
- `codebase-patterns.md` — Build tooling, test frameworks, conventions, shared libraries
- `test-data.md` — Data constraints, sources, synthetic generation, PII handling
- `team.md` — Client contacts, communication channels, review/approval people
- `observability.md` — Monitoring tools, alerting, SLOs, log/trace/metric standards
- `tech-debt.md` — Known risks, fragile areas, low coverage zones (grows over iterations)

**Stated assumptions** (from "skip") are tracked and must be validated before `/release`. An assumption that reaches production without validation is a risk SM must flag.

**Living knowledge**: After each iteration, SM updates `docs/engagement/` with what was learned. This context accumulates — `/initiate` is never "done."

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

## Definition of Done (Authoritative: `docs/definition-of-done.md`)

The full Definition of Done is maintained in `docs/definition-of-done.md` — that file is the single source of truth. Users can enhance it with engagement-specific criteria. Summary of core (non-negotiable) criteria:

1. **Traceability — 100%** — bidirectional: scenario ↔ test ↔ code. No orphans.
2. **All Tests Passing and Automated** — no pending, no skipped, no manual. CI enforced.
3. **All NFRs as Tests** — performance, security, resilience expressed as Gherkin scenarios with automated verification. No "soft" NFRs.
4. **Unit Test Coverage — 100%** — line + branch. No exclusions. CI gate blocks if < 100%.

**Nothing is released unless ALL criteria are met. No negotiation. No deferral.**

SM enforces DoD continuously (not just at release) and blocks deployment on any gap.

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
