# App Dev Accelerator

A collaborative development team (Claude Code plugin) combining **XP**, **BDD**, **FDD**, and **strong NFR testing**. Four agents work as a pair-programming team with the User as navigator. Three workflows compose six reusable loops for new features, defect fixes, and refactoring.

## Quick Start

```bash
git clone <repo-url> ~/App_dev_Accelerator
/plugin marketplace add ~/App_dev_Accelerator
/ingest ~/DiscoveryAccelerator
/new-feature
```

## The Team

| Agent | Role | Pairing Model |
|---|---|---|
| **SM** | Scrum Master — orchestrates loops, enforces gates | Facilitator |
| **Igor** | Behavior — Gherkin scenarios, domain language | BDD "Business" voice |
| **Paul** | Testing — tests FIRST, NFRs, regression | BDD "Testing" voice |
| **Dmitri** | Technical — implementation, infra, pipeline | BDD "Technical" voice |
| **User** | Navigator — approves every test/impl pair | XP Customer on team |

## Workflows (Entry Points)

| Workflow | When to Use | Loops Composed |
|---|---|---|
| `/new-feature` | Net-new functionality | refine → spike → design → test-and-develop → deploy-and-validate → release |
| `/fix-defect` | Bug fix | reproduce → root-cause → test-and-fix → deploy-and-validate → release |
| `/refactor` | Restructure, preserve behavior | scope → characterize → design → move-under-green → deploy-and-validate → release |

## Core Loops (Reusable)

| Loop | Purpose | Key Practice |
|---|---|---|
| `/refine` | Work item → Definition of Ready | BDD Three Amigos + examples |
| `/spike` | Validate assumptions (time-boxed) | Evidence, not opinions |
| `/design` | Technical "how" — FDD Design by Feature | Domain model, events, API, NFR strategy |
| `/test-and-develop` | Build code — XP pairing + TDD | Ping-pong: Paul tests → Dmitri implements → User approves each |
| `/deploy-and-validate` | Push through environments | Validate per level, loop back on failure |
| `/release` | Production + iteration closure | Blue/green, smoke, feedback |

## Connection to Discovery

| Skill | Purpose |
|---|---|
| `/ingest` | Bootstrap from DiscoveryAccelerator or refresh |
| `/challenge` | Feed implementation learnings back upstream |

## Quality Gates (Non-Negotiable)

- **100% Traceability** — requirement ↔ test ↔ code (bidirectional)
- **100% Unit Test Coverage** — line + branch, no exclusions
- **All BDD Scenarios Green** — no pending, no skipped
- **All NFR Scenarios Green** — performance, security, resilience
- **User Approval** — at every pairing cycle + workflow gates

## Practices Embedded

**XP:** Pairing, TDD (red-green-refactor), continuous integration, small releases, simple design, collective ownership, refactoring as first-class workflow, customer on team.

**BDD:** Outside-in development, Three Amigos refinement, examples drive tests, living documentation, Gherkin as single source of truth.

**FDD:** Feature as unit of work, domain model first, design by feature, build by feature, regular builds.

**NFR Testing:** Performance, security, and resilience as Gherkin scenarios — both inline per feature and cross-cutting system suites.

## AWS Default

When no implementation context specifies otherwise: ECS Fargate, RDS PostgreSQL, EventBridge, CDK, GitHub Actions, blue/green deploys across dev → test → staging → prod.

## Project Structure

```
agents/                          — 4 agent definitions
skills/
  refine/SKILL.md                — /refine loop
  spike/SKILL.md                 — /spike loop
  design/SKILL.md                — /design loop
  test-and-develop/SKILL.md      — /test-and-develop loop
  deploy-and-validate/SKILL.md   — /deploy-and-validate loop
  release/SKILL.md               — /release loop
  new-feature/SKILL.md           — /new-feature workflow
  fix-defect/SKILL.md            — /fix-defect workflow
  refactor/SKILL.md              — /refactor workflow
  ingest/SKILL.md                — /ingest connection
  challenge/SKILL.md             — /challenge connection
.claude-plugin/marketplace.json  — Plugin registration
CLAUDE.md                        — Team instructions
```

## Upstream Dependency

Requires [DiscoveryAccelerator](https://github.com/PGivenCapTech/DiscoveryAccelerator) for industry context, domain model, architecture decisions, and validated backlog.
