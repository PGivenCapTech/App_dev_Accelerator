# Getting Started with the App Dev Accelerator

This guide walks you through setting up and using the App Dev Accelerator team — from installation to your first deployed feature.

The accelerator works with **both Claude Code and GitHub Copilot** (CLI, VS Code Chat, GitHub.com Chat). Same team, same practices, same quality gates — different invocation mechanism.

## Prerequisites

You need:
- **Claude Code** OR **GitHub Copilot** (CLI, VS Code extension, or GitHub.com)
- **A DiscoveryAccelerator output** — the upstream team that provides industry context, domain model, personas, and architecture decisions. If you don't have one, run the [DiscoveryAccelerator](https://github.com/PGivenCapTech/DiscoveryAccelerator) first.
- **A target project** — either an existing codebase or a greenfield project

Optional but recommended:
- AWS account (if deploying; the team defaults to AWS)
- GitHub repository for your target project

## Installation

### Option A: Claude Code

```bash
# Clone the accelerator
git clone https://github.com/PGivenCapTech/App_dev_Accelerator.git ~/App_dev_Accelerator

# Register as a Claude Code plugin
/plugin marketplace add ~/App_dev_Accelerator
```

The team's skills and agents are now available in your Claude Code session.

### Option B: GitHub Copilot (CLI / VS Code Chat / GitHub.com)

```bash
# Clone the accelerator into your project (or as a sibling)
git clone https://github.com/PGivenCapTech/App_dev_Accelerator.git

# Copy the .github directory into your target project
cp -r App_dev_Accelerator/.github your-project/.github
cp -r App_dev_Accelerator/docs your-project/docs
```

Or if you want the accelerator as a submodule in your project:
```bash
cd your-project
git submodule add https://github.com/PGivenCapTech/App_dev_Accelerator.git .accelerator
cp -r .accelerator/.github .github
cp -r .accelerator/docs docs
```

Copilot automatically reads `.github/copilot-instructions.md` for every conversation and makes `.github/prompts/*.prompt.md` files available as invocable prompts.

### What Goes Where

| File | Claude Code reads | Copilot reads | Purpose |
|---|---|---|---|
| `CLAUDE.md` | Yes (auto) | No | Team instructions for Claude Code |
| `.github/copilot-instructions.md` | No | Yes (auto) | Team instructions for Copilot |
| `.github/prompts/*.prompt.md` | No | Yes (on invoke) | Loop/workflow prompts for Copilot |
| `skills/*/SKILL.md` | Yes (on invoke) | No | Loop/workflow skills for Claude Code |
| `docs/` | Yes | Yes | Shared state (DoR, DoD, defaults, backlog, engagement context) |

Both tools read the same `docs/` directory — the quality gates, SDLC defaults, and engagement context work identically regardless of which tool you use.

## Your First Session

The steps below are the same regardless of tool. The invocation syntax differs:

| Step | Claude Code | Copilot Chat |
|---|---|---|
| Ingest | `/ingest ~/path` | `@workspace #file:ingest.prompt.md` or describe: "Ingest discovery from [path]" |
| Initiate | `/initiate` | `@workspace #file:initiate.prompt.md` or describe: "Let's set up the engagement" |
| Refine | `/refine` | `@workspace #file:refine.prompt.md` or describe: "Refine the top backlog item" |
| Design | `/design` | `@workspace #file:design.prompt.md` or describe: "Design the payment feature" |
| Test & Dev | `/test-and-develop` | `@workspace #file:test-and-develop.prompt.md` or describe: "Start pairing" |
| Deploy | `/deploy-and-validate` | `@workspace #file:deploy-and-validate.prompt.md` or describe: "Deploy to test" |
| Release | `/release` | `@workspace #file:release.prompt.md` or describe: "Release to production" |

For Copilot CLI specifically:
```bash
# Reference a prompt directly
gh copilot chat --prompt-file .github/prompts/refine.prompt.md

# Or just describe what you want (instructions route automatically)
gh copilot chat "Let's refine the user onboarding feature"
```

### Step 1: Connect to Discovery

Link to your DiscoveryAccelerator output so the team can access industry context, domain model, and backlog:

```bash
# Claude Code
/ingest ~/path/to/DiscoveryAccelerator

# Copilot Chat
@workspace "Ingest discovery output from ~/path/to/DiscoveryAccelerator"
```

SM will read the discovery output and build your initial backlog from validated proposals. You'll see a summary of what was ingested — features, constraints, architecture decisions, domain terms.

If you don't have a DiscoveryAccelerator output yet, you can still start — but the team will lack industry context and will ask you for more information during refinement.

### Step 2: Initiate (Capture Your Engagement Context)

```bash
/initiate
```

SM walks through your operational context conversationally — not a form dump. The team needs to know how YOU build software (your SDLC, environments, team, tooling).

**What SM will ask about:**

| Area | What SM Needs | Example Questions |
|---|---|---|
| SDLC Controls | How you ship software | "Do you use GitFlow or trunk-based? Who reviews PRs?" |
| Environments | Where code runs | "What cloud? What environments exist? How do you deploy?" |
| Codebase Patterns | How code is structured | "What language/framework? Test framework? Build tool?" |
| Test Data | How you test | "Can you use production data? How do you generate test data?" |
| Team | Who you work with | "Who reviews PRs? Who approves production deploys?" |
| Observability | How you monitor | "What monitoring tools? What are your SLO targets?" |
| Tech Debt | Known risks | "Any fragile areas? Known performance issues?" |

**You don't need all answers now.** The team operates on leading practice defaults from day one (trunk-based dev, automated security scanning, continuous delivery, etc.). Your answers override defaults where you're specific — where you're silent, defaults remain.

**Your options when SM asks something you don't know:**
1. **Provide it** — SM documents it and the team uses it
2. **"Skip"** — SM notes a stated assumption and continues with the default
3. **"I'll find out"** — SM parks it, continues what's possible, asks again when it matters

After initiation, SM presents what it has, what's missing, and when it'll need the missing pieces.

**Important:** Your SDLC controls automatically enhance the team's Definition of Ready and Definition of Done. If you require 2 PR approvals, that becomes a DoD criterion. If you have a CAB process, timeline awareness becomes a DoR criterion. This happens automatically.

### Step 3: Review the Backlog

After ingestion and initiation, SM has a prioritized backlog. Review it:

```bash
# SM shows the current backlog state
```

SM will present the top items and propose an iteration plan — which features, what parallel tracks, estimated effort. **This is your first approval gate:**

> SM: "Here's what I'm proposing for Iteration 1: [features]. Approve, adjust, or reprioritize?"

You steer. The team doesn't start work until you say go.

### Step 4: Start Your First Feature

Once you approve the iteration plan:

```bash
/new-feature
```

This kicks off the full workflow: refine → spike (if unknowns) → design → test-and-develop → deploy-and-validate → release.

Or if you want to work one loop at a time:

```bash
/refine                    # Work the top item to Definition of Ready
/design                    # Produce technical design for a refined item
/test-and-develop          # Build it (you'll be pairing with Paul + Dmitri)
/deploy-and-validate       # Push through environments
/release                   # Ship to production
```

## What Your Role Is (Navigator)

You are the **navigator** on this XP team. The agents pair-program; you steer. Here's what that looks like in practice:

### During Refinement (`/refine`)

The Three Amigos (Igor + Paul + Dmitri) discuss the feature with you:
- Igor presents the behavior ("here's what, for whom, why")
- Paul proposes test scenarios ("how would we know it works?")
- Dmitri flags technical risks ("here's what's hard")
- **You:** confirm, adjust, add domain knowledge they don't have

### During Design (`/design`)

Dmitri proposes the technical approach:
- Domain model changes, API contracts, event flows
- Paul checks testability ("I need this interface to stub X")
- Igor validates against scenarios
- **You:** approve the design or raise concerns

### During Development (`/test-and-develop`)

This is where you're most active. Paul and Dmitri ping-pong:

```
Paul writes a failing test → Shows you: "This is the contract. Right behavior?"
  → You: "Go ahead" / "Not quite — [adjustment]"

Dmitri makes it pass → Shows you: "This makes it pass. Look right?"
  → You: "Looks right" / "I'd prefer [alternative]"

Dmitri refactors → Shows you: "Cleaned up, still green."
  → You: "Clean" / "I'd prefer [different structure]"
```

This happens for EVERY test/implementation pair. You see everything, approve everything. If you say "not quite" at any point, the team addresses your concern before moving on.

### During Deployment (`/deploy-and-validate`)

The team deploys through environments. You approve promotions:
- Dev: automatic (no approval needed)
- Test: "All tests pass. Promote to test? **Approve / Hold**"
- Staging: "Test environment validated. Promote to staging? **Approve / Hold**"
- Production: "Staging verified. Go live? **Approve / Hold**"

### After Release (`/release`)

SM presents an iteration summary — what shipped, quality metrics, what was learned, demo of the working feature. You provide feedback that shapes the next iteration.

## Common Scenarios

### "I want to fix a bug"

```bash
/fix-defect
```

Abbreviated workflow: reproduce (failing test first) → root-cause → fix under test → deploy → release.

### "I want to refactor something"

```bash
/refactor
```

Characterization tests first (prove current behavior), then restructure while tests stay green.

### "Discovery got something wrong"

```bash
/challenge
```

Feeds a learning back to the DiscoveryAccelerator team — an assumption that turned out to be wrong, a constraint that was missed, a domain concept that works differently than expected.

### "I need to add a quality criterion"

Tell SM: "Add to Definition of Done: [your criterion]" or "Add to Definition of Ready: [your criterion]"

SM adds it to the appropriate document and enforces it from the next iteration forward.

### "I want to update my SDLC information"

```bash
/initiate --area sdlc
```

SM re-asks about SDLC controls; updates to your answers automatically update the effective DoR/DoD criteria.

### "I want to see where we are"

```bash
/initiate --status           # What engagement context is captured/missing/assumed
/initiate --assumptions      # All stated assumptions (need validation before release)
```

## How the Quality Gates Work

Two gates sandwich every piece of work:

**Definition of Ready** (entry to development):
- Behavior described in Given/When/Then examples
- Edge cases identified
- NFRs identified
- Dependencies clear
- Plus any SDLC-derived criteria (e.g., "reviewers identified")

**Definition of Done** (exit from development):
- 100% traceability (requirement ↔ test ↔ code, bidirectional)
- All tests passing and automated (no skipped, no manual)
- All NFRs represented as automated Gherkin scenarios
- 100% unit test coverage (line + branch, no exclusions)
- Plus any SDLC-derived criteria (e.g., "PR approved by 2 reviewers")

**Nothing ships unless both gates are fully satisfied.** SM enforces this continuously — not just at release, but as code lands during development.

## The Defaults (What You Get Without Configuration)

Even before you provide any engagement context, the team operates with:

| Area | Default |
|---|---|
| Source control | Trunk-based, short-lived branches, squash merge |
| Branch protection | CI + 1 approval on main |
| Security | SAST every PR, dep scanning every build, secrets detection pre-commit |
| Change management | No CAB — automated gates + User approval for staging/prod |
| Release | Continuous delivery, blue/green, automated rollback |
| Incident response | Rollback first, investigate second, fix via normal pipeline |
| CI/CD | Build → Test → Coverage → Traceability → Security → Deploy (< 10 min target) |
| Infrastructure | AWS: ECS Fargate, RDS PostgreSQL, EventBridge, CDK, GitHub Actions |
| Documentation | ADRs in repo, Gherkin as living docs, no wiki |

See `docs/sdlc-defaults.md` for the full set. Your SDLC overrides any of these where you're explicit.

## Project Structure (What Gets Generated)

As the team works, it generates artifacts in your target project:

```
backlog/
  backlog.md                    — Ordered feature list with status
  ready/<feature>/              — Refined features (scenarios, risks, dependencies)
  active/<feature>/             — In-progress (traceability matrix, status)
  done/<feature>/               — Completed (full trace preserved)

docs/
  engagement/                   — Your operational context (SDLC, envs, team, etc.)
  adr/                          — Architecture Decision Records
  definition-of-ready.md        — Entry gate (enhanced by your SDLC)
  definition-of-done.md         — Exit gate (enhanced by your SDLC)
  sdlc-defaults.md              — Team's leading practice baseline

src/
  main/                         — Production code (Dmitri)
  test/
    features/                   — Gherkin step definitions
    unit/                       — Unit tests (100% coverage)
    integration/                — API + database tests
    nfr/                        — Performance, security, resilience

infra/                          — CDK infrastructure-as-code

nfr/
  performance.feature           — Cross-cutting performance scenarios
  security.feature              — Cross-cutting security scenarios
  resilience.feature            — Cross-cutting resilience scenarios

monitoring/
  <env>-baseline.md             — Performance baselines per environment
```

## Tips

1. **Be specific when you steer.** "Not quite" is fine, but "not quite — the edge case is [X]" is better. The team responds to concrete direction.

2. **Don't worry about forgetting context.** SM maintains engagement context and prompts you when something is needed. You'll never be expected to remember what you said three sessions ago.

3. **Challenge early.** If something from discovery feels wrong during refinement, use `/challenge` immediately. Don't wait until it's built.

4. **Assumptions get validated.** If you skipped context during initiation, SM tracks those assumptions and will bring them back before release. Nothing ships with unvalidated assumptions.

5. **One feature at a time.** The team can work parallel tracks, but you navigate one loop at a time. SM handles the orchestration.

6. **The Gherkin IS the documentation.** Don't ask for separate requirements docs — the scenarios in `backlog/ready/<feature>/feature.md` are the living specification. They're always current because they're the tests.

## Troubleshooting

**"The team keeps asking me questions I don't know the answer to"**
Say "skip" or "I'll find out." The team will work with defaults or park the question. You're never blocked by not knowing something immediately.

**"I want to change something the team already built"**
Raise it during the next `/refine` or tell SM to add a backlog item. The team will treat it as a new feature or defect fix — same process, same quality.

**"Traceability/coverage is blocking deployment but I want to ship"**
The gates are non-negotiable. SM will tell you exactly what's missing and who needs to fix it. The fix is usually small — an untested edge case, an orphan utility method, a missing step definition.

**"I need to skip a quality gate for an emergency"**
You can't skip the gates, but the process is fast. `/fix-defect` with critical severity uses the same pipeline with the same gates — it's just prioritized. The team's defaults (no CAB, deploy-on-green) mean the only bottleneck is the code itself being correct.
