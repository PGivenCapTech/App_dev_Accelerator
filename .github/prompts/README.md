# App Dev Accelerator — Copilot Prompts

These prompt files implement the App Dev Accelerator team for **GitHub Copilot CLI** and **Copilot Chat** (VS Code, GitHub.com, JetBrains).

## How to Use

In Copilot Chat, reference a prompt file directly:

```
@workspace /refine — Refine the top backlog item
@workspace /design — Design the current refined feature
@workspace /test-and-develop — Start pairing (TDD loop)
@workspace /deploy-and-validate — Deploy through environments
@workspace /release — Ship to production
```

Or describe what you want and Copilot will route based on `copilot-instructions.md`:

```
"Let's refine the payment processing feature"
"I need to fix a bug in the notification service"
"Design the API for user onboarding"
"Start pairing on the authentication scenarios"
```

## Prompts Available

### Core Loops
| Prompt | Purpose |
|---|---|
| `refine.prompt.md` | Three Amigos refinement → Definition of Ready |
| `spike.prompt.md` | Time-boxed investigation of unknowns |
| `design.prompt.md` | FDD Design by Feature (domain, API, events, NFR strategy) |
| `test-and-develop.prompt.md` | XP pairing + TDD (Paul tests → Dmitri implements → User approves) |
| `deploy-and-validate.prompt.md` | Push through environments with validation |
| `release.prompt.md` | Production deploy + iteration feedback |

### Workflows (Compose Loops)
| Prompt | Purpose |
|---|---|
| `new-feature.prompt.md` | Full lifecycle for net-new functionality |
| `fix-defect.prompt.md` | Abbreviated workflow for bug fixes |
| `refactor.prompt.md` | Restructure without behavior change |

### Connection & Setup
| Prompt | Purpose |
|---|---|
| `initiate.prompt.md` | Capture engagement context (SDLC, envs, team) |
| `ingest.prompt.md` | Bootstrap from DiscoveryAccelerator |
| `challenge.prompt.md` | Feed learnings back to discovery |

## How It Works

- `copilot-instructions.md` — Always loaded by Copilot. Defines the team, practices, quality gates, and routing.
- Each `.prompt.md` — A reusable prompt that casts Copilot into the appropriate personas for that loop.
- `docs/` files — The team reads and writes these during execution (DoR, DoD, engagement context, backlog).

## vs. Claude Code

Same team, same practices, same quality gates. The difference:
- Claude Code uses `CLAUDE.md` + `skills/*/SKILL.md` + agent definitions
- Copilot uses `.github/copilot-instructions.md` + `.github/prompts/*.prompt.md`

Both read the same `docs/` directory for state (DoR, DoD, SDLC defaults, engagement context, backlog).
