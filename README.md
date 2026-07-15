# App Dev Accelerator

A collaborative development team (Claude Code plugin) that builds deployed software from DiscoveryAccelerator output. Four agents work as a team — not a pipeline — with test-first development, 100% traceability, 100% coverage, and multi-environment deployment.

## Quick Start

```bash
# Clone
git clone <repo-url> ~/App_dev_Accelerator

# Install as Claude Code plugin
/plugin marketplace add ~/App_dev_Accelerator

# Link to a discovery project and bootstrap
/ingest ~/DiscoveryAccelerator

# Start the iteration cycle
/plan
/test-and-build
/deploy
/release
```

## How It Works

### Upstream: DiscoveryAccelerator Provides Context

This team does NOT do industry research, domain discovery, or architecture selection. That's handled by the [DiscoveryAccelerator](https://github.com/PGivenCapTech/DiscoveryAccelerator) (14 agents: Anu, Archie, Scout, Paul, Scribe, analysts, etc.).

The `/ingest` skill pulls discovery output into the dev project, and `/ingest --refresh` picks up updates continuously.

### The Team

| Agent | Role |
|---|---|
| **SM** | Scrum Master — orchestrates iterations, manages backlog, enforces quality gates |
| **Igor** | Story Translator — decomposes discovery backlog into dev-sized Gherkin features |
| **Paul** | Test Engineer — builds test infrastructure FIRST; co-owns deployment pipeline |
| **Dmitri** | Developer — implements against Paul's tests; co-owns pipeline + AWS infra |

### The Skills (Iteration Cycle)

```
/plan → /test-and-build → /deploy → /release → (user feedback) → /plan ...
```

| Skill | What Happens |
|---|---|
| `/plan` | SM proposes iteration, Igor writes features, Paul plans tests. User approves. |
| `/test-and-build` | Paul builds tests first, Dmitri codes against them. SM verifies gates. |
| `/deploy` | Dmitri + Paul deploy dev → test → staging. User approves promotions. |
| `/release` | Production deploy, smoke verification, user gives iteration feedback. |

### Supporting Skills

| Skill | Purpose |
|---|---|
| `/ingest` | Bootstrap from discovery or refresh with new context |
| `/challenge` | Feed implementation learnings back to discovery team |

## Non-Negotiable Quality Gates

- **100% Traceability** — every requirement ↔ test ↔ code, bidirectional
- **100% Unit Test Coverage** — line + branch, no exclusions
- **All BDD Scenarios Pass** — no pending, no skipped
- **User Approval** — at iteration plan, contents, promotion, and feedback

## Human Approval Gates

The user drives. SM pauses at:

1. **Iteration Plan** — approve which features, structure, effort
2. **Iteration Contents** — approve Igor's decomposition + Paul's test plan
3. **Environment Promotions** — approve each promotion (test → staging → prod)
4. **Post-Iteration Feedback** — review demo, metrics, learnings; adjust next iteration

## Continuous Backlog Feed

The backlog is never static. It receives input from:

1. **Discovery proposals** (`/ingest --refresh`)
2. **Implementation learnings** (`/challenge` → resolved → `/ingest --refresh`)
3. **User feedback** (`/release` post-iteration)
4. **Technical debt** (identified during `/test-and-build`)
5. **Analyst updates** (new compliance/security requirements)

## AWS Default

When no implementation context specifies otherwise:

| Layer | Default |
|---|---|
| Compute | ECS Fargate / Lambda |
| Database | RDS PostgreSQL |
| Events | EventBridge + SQS |
| IaC | AWS CDK (TypeScript) |
| CI/CD | GitHub Actions |
| Environments | dev → test → staging → prod |

## Project Structure (This Repo — The Template)

```
.claude-plugin/
  marketplace.json          — Plugin registration
.claude/
  skills/                   — Symlinks to skill definitions
agents/
  sm-scrummaster.md         — Scrum Master agent
  igor-product-owner.md     — Story Translator agent
  paul-tester.md            — Test Engineer agent
  dmitri-developer.md       — Developer agent
skills/
  plan/SKILL.md             — /plan skill definition
  test-and-build/SKILL.md   — /test-and-build skill definition
  deploy/SKILL.md           — /deploy skill definition
  release/SKILL.md          — /release skill definition
  ingest/SKILL.md           — /ingest skill definition
  challenge/SKILL.md        — /challenge skill definition
docs/
  discovery/                — Ingested from DiscoveryAccelerator (after /ingest)
  technology/               — Architecture decisions (generated)
CLAUDE.md                   — Team instructions and conventions
```

## Relationship to DiscoveryAccelerator

```
DiscoveryAccelerator (upstream)          App Dev Accelerator (this repo)
─────────────────────────────           ────────────────────────────────
14 agents: Scout, Anu, Archie,          4 agents: SM, Igor, Paul, Dmitri
  Paul, Scribe, Opi, Captain            6 skills: /plan, /test-and-build,
  Obvious, Reggi, Leggi, Rikki,           /deploy, /release, /ingest,
  Cissi, Itty, Polly, Fin                 /challenge

Produces:                               Consumes:
  context.md                     ──→      docs/discovery/context.md
  proposals/                     ──→      docs/discovery/proposals/
  backlog items                  ──→      backlog/backlog.md
  architecture decisions         ──→      docs/technology/

                                        Feeds back:
  resolved challenges            ←──      /challenge items
  revised requirements           ←──      implementation learnings
```

## Prerequisites

- Claude Code (CLI, desktop, or IDE extension)
- DiscoveryAccelerator plugin installed (upstream)
- AWS credentials configured (for `/deploy` and `/release`)
- Git
