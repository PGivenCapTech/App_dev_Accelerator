# App Dev Accelerator

A collaborative AI development team that takes discovery output and builds working, deployed software. Combines **XP** (pairing, TDD, continuous integration), **BDD** (outside-in, examples drive development), **FDD** (design by feature, build by feature), and **strong NFR testing** (performance, security, resilience as Gherkin scenarios).

Works with **Claude Code** and **GitHub Copilot** (CLI, VS Code Chat, GitHub.com).

## Quick Start

```bash
# Clone the accelerator
git clone https://github.com/PGivenCapTech/App_dev_Accelerator.git

# Bootstrap a new team project
/bootstrap my-project          # Claude Code
# or
@workspace "Bootstrap a new team project called my-project"  # Copilot
```

This creates your team's repo with the accelerator as a submodule, then launches `/initiate` to capture your engagement context. See `docs/getting-started.md` for the full walkthrough.

## The Team

| Agent | Role | Mindset |
|---|---|---|
| **SM** | Scrum Master — orchestrates loops, manages backlog, enforces quality gates | Facilitator, not gatekeeper |
| **Igor** | Story Translator — behavior, acceptance criteria, domain language | BDD "Business" voice |
| **Paul** | Test Engineer — tests FIRST, NFRs, regression, co-owns pipeline | BDD "Testing" voice |
| **Dmitri** | Developer — implements against tests, co-owns pipeline + infra | BDD "Technical" voice |
| **User** | Navigator — approves every test/impl pair, steers at every gate | XP Customer on team |

## Workflows

| Workflow | When | Loops Composed |
|---|---|---|
| `/new-feature` | Net-new functionality | refine → spike → design → test-and-develop → deploy-and-validate → release |
| `/fix-defect` | Bug fix | reproduce → root-cause → test-and-fix → deploy-and-validate → release |
| `/refactor` | Restructure, preserve behavior | scope → characterize → design → move-under-green → deploy-and-validate → release |

## Core Loops

| Loop | Purpose | Key Practice |
|---|---|---|
| `/refine` | Work item → Definition of Ready | BDD Three Amigos + examples |
| `/spike` | Validate assumptions (time-boxed) | Evidence, not opinions |
| `/design` | Technical "how" — FDD Design by Feature | Domain model, events, API, NFR strategy |
| `/test-and-develop` | Build code — XP pairing + TDD | Ping-pong: Paul tests → Dmitri implements → User approves |
| `/deploy-and-validate` | Push through environments | Validate per level, loop back on failure |
| `/release` | Production + iteration closure | Blue/green, smoke, feedback |

## Setup & Connection

| Skill | Purpose |
|---|---|
| `/bootstrap` | Create a new team project repo (submodule connection, scaffolding) |
| `/initiate` | Capture engagement context (SDLC, environments, team, systems of record) |
| `/ingest` | Connect to DiscoveryAccelerator output or refresh |
| `/challenge` | Feed implementation learnings back to discovery |

## Quality Gates (Non-Negotiable)

| Gate | Criterion | Documented In |
|---|---|---|
| **Entry** | Definition of Ready (all criteria met) | `docs/definition-of-ready.md` |
| **Exit** | Definition of Done (all criteria met) | `docs/definition-of-done.md` |

**Definition of Done — core criteria:**
1. **Traceability — 100%** — bidirectional: scenario ↔ test ↔ code
2. **All Tests Passing and Automated** — no pending, no skipped, no manual
3. **All NFRs as Tests** — performance, security, resilience as Gherkin scenarios
4. **Unit Test Coverage — 100%** — line + branch, no exclusions

Both DoR and DoD are automatically enhanced by client SDLC controls captured during `/initiate`.

## Environment Strategies

Selected during `/initiate` based on what's available:

| Strategy | What's Needed | Multi-Dev |
|---|---|---|
| **Local** | Docker only | Each dev runs own stack |
| **Cloud** (AWS default) | Cloud account + CI/CD | Ephemeral per-branch + shared upper |
| **Hybrid** | Docker + cloud for upper envs | Local dev, cloud test/staging/prod |

See `docs/environment-strategy.md` for full detail.

## SDLC Defaults

The team operates on leading practice defaults from day one (`docs/sdlc-defaults.md`). Client SDLC overrides where explicit — defaults remain where silent. Covers:

- Source control (trunk-based, squash merge)
- Branch protection (CI + 1 approval)
- Security (SAST, dependency scanning, secrets detection)
- Change management (no CAB — automated gates)
- Release (continuous delivery, blue/green, automated rollback)
- CI/CD (< 10 min pipeline, same artifact all environments)

## Systems of Record

The team integrates with client systems (`docs/systems-of-record.md`):

| System | Sync | Example |
|---|---|---|
| Requirements | Bidirectional | Jira, Azure DevOps |
| Test Management | Bidirectional | Xray, Zephyr, TestRail |
| Artifact Repository | Publish | Artifactory, ECR |
| Change Management | Bidirectional | ServiceNow |
| Security Scanning | Publish + Consume | SonarQube, Snyk |
| Documentation | Publish | Confluence, SharePoint |
| Communication | Notify | Slack, Teams |
| Monitoring/Incidents | Configure + Trigger | PagerDuty, Datadog |

## Multi-Team Model

```
App_dev_Accelerator (this repo — methodology, shared)
  ↑ submodule
  ├── team-alpha-project/     (Team A's work)
  ├── team-beta-project/      (Team B's work)
  └── team-gamma-project/     (Team C's work)
```

Each team inherits methodology via submodule. Teams own their:
- Engagement context, DoR/DoD (enhanced for their engagement)
- Backlog, code, infrastructure, monitoring
- Branch strategy (feature branches per developer)

Human SM coordinates across developers. Each developer's AI team operates within their feature branch.

## Practices Embedded

**XP:** Pairing (mob model — Paul + Dmitri + User as navigator), TDD (red-green-refactor), continuous integration, small releases, simple design, collective ownership, refactoring as first-class workflow.

**BDD:** Outside-in development, Three Amigos refinement, examples drive tests, living documentation (Gherkin scenarios ARE the requirements).

**FDD:** Feature as unit of work, domain model first, design by feature, build by feature.

**NFR Testing:** Performance, security, and resilience as Gherkin scenarios — both inline per feature and cross-cutting system suites.

## Tool Support

| Feature | Claude Code | GitHub Copilot |
|---|---|---|
| Instructions | `CLAUDE.md` | `.github/copilot-instructions.md` |
| Skills/Prompts | `skills/*/SKILL.md` | `.github/prompts/*.prompt.md` |
| Agents | `agents/*.md` | Persona instructions in prompts |
| Invocation | `/refine`, `/design`, etc. | `@workspace #file:refine.prompt.md` or describe naturally |
| Shared state | `docs/` | `docs/` |

Both tools read the same `docs/` directory — quality gates, engagement context, and backlog work identically.

## Project Structure

```
.claude-plugin/marketplace.json      — Plugin registration (Claude Code)
.claude/skills/                      — Skill symlinks (Claude Code)
.github/
  copilot-instructions.md            — Team instructions (Copilot)
  prompts/                           — Loop/workflow prompts (Copilot)
agents/                              — 4 agent definitions (Claude Code)
skills/
  bootstrap/SKILL.md                 — /bootstrap (new team project)
  initiate/SKILL.md                  — /initiate (engagement setup)
  refine/SKILL.md                    — /refine loop
  spike/SKILL.md                     — /spike loop
  design/SKILL.md                    — /design loop
  test-and-develop/SKILL.md          — /test-and-develop loop
  deploy-and-validate/SKILL.md       — /deploy-and-validate loop
  release/SKILL.md                   — /release loop
  new-feature/SKILL.md               — /new-feature workflow
  fix-defect/SKILL.md                — /fix-defect workflow
  refactor/SKILL.md                  — /refactor workflow
  ingest/SKILL.md                    — /ingest (discovery connection)
  challenge/SKILL.md                 — /challenge (feedback to discovery)
docs/
  getting-started.md                 — Full setup + usage guide
  definition-of-ready.md             — Entry gate (template)
  definition-of-done.md              — Exit gate (template)
  sdlc-defaults.md                   — Leading practice baseline
  environment-strategy.md            — Local/cloud/hybrid options
  systems-of-record.md               — External system integration guide
```

## Upstream Dependency

Industry context, domain model, architecture decisions, and validated backlog come from the [DiscoveryAccelerator](https://github.com/PGivenCapTech/DiscoveryAccelerator). Connect via `/ingest`.

## Updating

When methodology improves (in team projects that use this as a submodule):

```bash
git submodule update --remote .accelerator
git add .accelerator
git commit -m "Update accelerator to latest"
```

Symlinked skills/prompts and shared docs reflect the update immediately. Team-owned files (DoR, DoD, engagement context) are not affected.
