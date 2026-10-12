---
name: bootstrap
description: Bootstrap a new team project repo — scaffolds the directory structure, connects to the accelerator via submodule, generates tool-specific instructions, copies DoR/DoD templates, then launches /initiate.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /bootstrap — Create a New Team Project

The **Bootstrap** skill creates a new team project repo that inherits methodology and tooling from this accelerator, then has its own local context for engagement work.

## What It Creates

```
<project-name>/
├── .git/                            — Fresh repo
├── .accelerator/                    — Git submodule → App_dev_Accelerator
├── .github/
│   ├── copilot-instructions.md      — Generated (references .accelerator/)
│   └── prompts/                     — Symlinks to .accelerator/.github/prompts/
├── .claude/
│   └── skills -> .accelerator/.claude/skills/  — Directory symlink (auto-syncs)
├── CLAUDE.md                        — Generated (references .accelerator/)
├── docs/
│   ├── definition-of-ready.md       — Copied from accelerator (team owns it now)
│   ├── definition-of-done.md        — Copied from accelerator (team owns it now)
│   ├── sdlc-defaults.md             — Symlink to accelerator (shared, read-only)
│   ├── environment-strategy.md      — Symlink to accelerator (shared, read-only)
│   └── engagement/                  — Empty, filled during /initiate
│       ├── sdlc-controls.md
│       ├── environments.md
│       ├── codebase-patterns.md
│       ├── test-data.md
│       ├── team.md
│       ├── observability.md
│       └── tech-debt.md
├── backlog/
│   ├── backlog.md                   — Empty, filled during /ingest or /refine
│   ├── ready/                       — Refined features (ready for design)
│   ├── active/                      — In-progress work
│   └── done/                        — Completed work
├── src/                             — Production code (populated during /test-and-develop)
├── infra/                           — Infrastructure-as-code (populated during /deploy-and-validate)
├── monitoring/                      — Baselines (populated during /deploy-and-validate)
└── .gitignore                       — Sensible defaults
```

## The Process

### 1. Gather Basic Info

Ask the User:

```
"Let's set up your team project. I need a few things:

1. Project name? (kebab-case, e.g., 'payment-service' or 'customer-portal')
2. Where should I create it? (default: ~/projects/<name>)
3. Create a GitHub repo? (yes/no — if yes, public or private?)
4. Discovery Accelerator output location? (path, URL, or 'none yet')
5. Which AI tool will the team use? (Claude Code / Copilot / Both)"
```

### 2. Create Project Structure

```bash
# Create project directory
mkdir -p <path>/<project-name>
cd <path>/<project-name>
git init

# Add accelerator as submodule
git submodule add https://github.com/PGivenCapTech/App_dev_Accelerator.git .accelerator

# Create directory structure
mkdir -p .github/prompts
mkdir -p .claude
mkdir -p docs/engagement
mkdir -p backlog/{ready,active,done}
mkdir -p src
mkdir -p infra
mkdir -p monitoring
```

### 3. Generate Tool Instructions

#### CLAUDE.md (Generated)

```markdown
# <Project Name>

## Accelerator

This project uses the [App Dev Accelerator](.accelerator/) for methodology, quality gates, and team practices. The accelerator is connected as a git submodule at `.accelerator/`.

**To update methodology:** `git submodule update --remote .accelerator`

## Team Instructions

All team practices, workflows, loops, and quality gates are defined in the accelerator. Key references:

- **How the team works:** `.accelerator/CLAUDE.md`
- **Definition of Ready:** `docs/definition-of-ready.md` (team-owned, enhanced by SDLC)
- **Definition of Done:** `docs/definition-of-done.md` (team-owned, enhanced by SDLC)
- **SDLC Defaults:** `.accelerator/docs/sdlc-defaults.md` (shared baseline)
- **Environment Strategy:** `.accelerator/docs/environment-strategy.md`
- **Getting Started:** `.accelerator/docs/getting-started.md`

## Engagement Context

This team's operational context is in `docs/engagement/`. See each file for details.

## Conventions

<< inherited from accelerator — see .accelerator/CLAUDE.md >>

- Constructor injection (not field injection)
- Value objects / records for DTOs
- Sealed/discriminated event hierarchy
- Event naming: {Aggregate}{PastTenseVerb}Event
- Test naming: {Feature}StepDefinitions, {Feature}IntegrationTest, {Class}Test
- Every commit references the scenario it satisfies
- Ubiquitous language from discovery glossary
```

#### .github/copilot-instructions.md (Generated)

```markdown
# <Project Name> — Copilot Instructions

## Accelerator

This project uses the App Dev Accelerator (.accelerator/) for methodology. All team practices, quality gates, and prompts are inherited from there.

## Prompt Routing

Use prompts from `.github/prompts/` — they are linked to the accelerator's methodology.

<< include the full prompt routing section from accelerator copilot-instructions.md >>

## Team, Quality Gates, Conventions

See `.accelerator/.github/copilot-instructions.md` for full team definition, practices, and quality gates.

## This Engagement

- Engagement context: `docs/engagement/`
- Definition of Ready: `docs/definition-of-ready.md`
- Definition of Done: `docs/definition-of-done.md`
- Backlog: `backlog/backlog.md`
```

### 4. Create Symlinks

```bash
# Skills (for Claude Code) — single directory symlink keeps all skills in sync
ln -sf ../.accelerator/.claude/skills .claude/skills

# Prompts (for Copilot)
for prompt in .accelerator/.github/prompts/*.prompt.md; do
  name=$(basename "$prompt")
  ln -sf "../../.accelerator/.github/prompts/$name" ".github/prompts/$name"
done

# Shared docs (read-only, stay in sync with accelerator)
ln -sf ../.accelerator/docs/sdlc-defaults.md docs/sdlc-defaults.md
ln -sf ../.accelerator/docs/environment-strategy.md docs/environment-strategy.md
```

### 5. Copy Team-Owned Documents

These are COPIED (not linked) because the team enhances them with SDLC-derived and custom criteria:

```bash
cp .accelerator/docs/definition-of-ready.md docs/definition-of-ready.md
cp .accelerator/docs/definition-of-done.md docs/definition-of-done.md
```

### 6. Create Engagement Stubs

```bash
# Create empty engagement context files with headers
for area in sdlc-controls environments codebase-patterns test-data team observability systems-of-record tech-debt; do
  printf "# %s\n\n_To be captured during /initiate._\n" "$area" > "docs/engagement/${area}.md"
done
```

### 7. Create .gitignore

```
# Dependencies
node_modules/
.venv/
target/
build/

# IDE
.idea/
.vscode/settings.json
*.swp

# OS
.DS_Store
Thumbs.db

# Secrets (NEVER committed)
.env
.env.*
*.pem
*.key
credentials.json

# Build artifacts
dist/
*.jar
*.war

# Coverage reports (generated, not committed)
coverage/
htmlcov/
*.lcov

# Docker volumes
pgdata/
```

### 8. Initial Commit

```bash
git add -A
git commit -m "Bootstrap project from App Dev Accelerator

Inherits methodology via .accelerator submodule.
Ready for /initiate to capture engagement context."
```

### 9. GitHub Repo (if requested)

```bash
gh repo create <org>/<project-name> --private --source=. --push
```

### 10. Launch /initiate

After bootstrap completes:

> "Project scaffolded at `<path>`. Ready to capture your engagement context. Starting /initiate..."

Automatically launch the initiation loop to capture SDLC, environments, team, etc.

## Updating the Accelerator

When the accelerator is updated (improved prompts, new defaults, better practices):

```bash
cd <project>
git submodule update --remote .accelerator
git add .accelerator
git commit -m "Update accelerator to latest"
```

Symlinked files (prompts, skills, shared docs) automatically reflect the update. Team-owned files (DoR, DoD) are NOT overwritten — the team manages those.

## Multiple Teams

```
App_dev_Accelerator (source of truth — methodology)
  ↑ submodule
  ├── team-alpha-project/         (Team A's work)
  ├── team-beta-project/          (Team B's work)
  └── team-gamma-project/         (Team C's work)
```

Each team has their own:
- Engagement context
- Backlog
- DoR/DoD (enhanced for their engagement)
- Code, infra, monitoring

All share:
- Methodology (skills, prompts, agents)
- SDLC defaults
- Environment strategy options
- Getting started guide

## Invocation

```bash
/bootstrap                           — Interactive project creation
/bootstrap <project-name>            — Quick start with defaults
/bootstrap --path ~/projects/myapp   — Specify creation path
/bootstrap --github <org>/<name>     — Create GitHub repo immediately
/bootstrap --tool claude             — Claude Code only (no .github/)
/bootstrap --tool copilot            — Copilot only (no CLAUDE.md or .claude/)
/bootstrap --tool both               — Both tools (default)
```
