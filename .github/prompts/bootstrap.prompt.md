# Bootstrap — Create a New Team Project

You are **SM** setting up a new team project that inherits methodology from the App Dev Accelerator.

## What You're Doing

Creating a team project repo that:
- Connects to the accelerator via git submodule (inherits methodology)
- Has its own engagement context, backlog, code, and infrastructure
- Is ready for `/initiate` to capture operational context
- Supports Claude Code, Copilot, or both

## Ask the User

```
"Let's set up your team project. I need a few things:

1. Project name? (kebab-case, e.g., 'payment-service')
2. Where should I create it? (default: ~/projects/<name>)
3. Create a GitHub repo? (yes/no — if yes, public or private?)
4. Discovery Accelerator output location? (path, URL, or 'none yet')
5. Which AI tool will the team use? (Claude Code / Copilot / Both)"
```

## What to Create

### Directory Structure

```
<project-name>/
├── .accelerator/                    — Git submodule → App_dev_Accelerator
├── .github/
│   ├── copilot-instructions.md      — Generated (references .accelerator/)
│   └── prompts/                     — Symlinks to .accelerator/.github/prompts/
├── .claude/
│   └── skills/                      — Symlinks to .accelerator/skills/
├── CLAUDE.md                        — Generated (references .accelerator/)
├── docs/
│   ├── definition-of-ready.md       — Copied (team-owned, enhanced by SDLC)
│   ├── definition-of-done.md        — Copied (team-owned, enhanced by SDLC)
│   ├── sdlc-defaults.md             — Symlink to accelerator
│   ├── environment-strategy.md      — Symlink to accelerator
│   └── engagement/                  — Empty stubs for /initiate
├── backlog/
│   ├── backlog.md                   — Empty
│   ├── ready/
│   ├── active/
│   └── done/
├── src/
├── infra/
├── monitoring/
└── .gitignore
```

### Key Decisions

- **Symlinked files** (prompts, skills, shared docs): Stay in sync with accelerator updates
- **Copied files** (DoR, DoD): Team owns these — they get enhanced with SDLC criteria
- **Generated files** (CLAUDE.md, copilot-instructions.md): Reference accelerator but include team-specific content
- **Tool selection**: Only create Claude Code files if using Claude, only Copilot files if using Copilot, both if both

### Commands to Run

```bash
mkdir -p <path>/<project-name> && cd <path>/<project-name>
git init
git submodule add https://github.com/PGivenCapTech/App_dev_Accelerator.git .accelerator
mkdir -p .github/prompts .claude/skills docs/engagement backlog/{ready,active,done} src infra monitoring

# Symlinks (prompts)
for prompt in .accelerator/.github/prompts/*.prompt.md; do
  ln -sf "../../.accelerator/.github/prompts/$(basename $prompt)" ".github/prompts/$(basename $prompt)"
done

# Symlinks (skills)
for skill in .accelerator/skills/*/; do
  name=$(basename "$skill")
  ln -sf "../../.accelerator/skills/$name/SKILL.md" ".claude/skills/${name}.md"
done

# Symlinks (shared docs)
ln -sf ../.accelerator/docs/sdlc-defaults.md docs/sdlc-defaults.md
ln -sf ../.accelerator/docs/environment-strategy.md docs/environment-strategy.md

# Copy team-owned docs
cp .accelerator/docs/definition-of-ready.md docs/definition-of-ready.md
cp .accelerator/docs/definition-of-done.md docs/definition-of-done.md

# Engagement stubs
for area in sdlc-controls environments codebase-patterns test-data team observability tech-debt; do
  printf "# %s\n\n_To be captured during /initiate._\n" "$area" > "docs/engagement/${area}.md"
done
```

### After Scaffold

1. Generate CLAUDE.md and copilot-instructions.md (see `.accelerator/skills/bootstrap/SKILL.md` for templates)
2. Create .gitignore
3. Initial commit
4. Create GitHub repo (if requested)
5. Launch `/initiate` to capture engagement context

Tell User:
> "Project scaffolded at `<path>`. Structure is ready. Starting engagement setup — let's capture your operational context..."

Then run the initiate process.

## Updating the Accelerator Later

```bash
cd <project>
git submodule update --remote .accelerator
git add .accelerator
git commit -m "Update accelerator to latest"
```

Symlinked files auto-reflect the update. Team-owned files (DoR, DoD) are not affected.
