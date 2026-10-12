# Registration Spike — Quick Start

## Prerequisites

- **Node.js** v20+
- **Docker** (via Colima or Docker Desktop) with Docker Compose plugin
- ~4GB RAM available for Docker containers

## One-time Setup

```bash
# Install deps, start Zeebe + Elasticsearch, build, deploy BPMN
make setup
```

This takes ~2 minutes (Zeebe startup is the bottleneck).

## Run the Demo

```bash
# Start BFF (:3000) + frontend (:5174) in foreground
make start
```

In a second terminal:

```bash
# Start a registration workflow for the test user
curl -X POST http://localhost:3000/api/workflow/start
```

Then open **http://localhost:5174** — you'll see the first registration form.

Walk through all 3 steps:
1. **Verify Your Identity** — first name, last name, date of birth
2. **Create Your Account** — email, password, security question
3. **Review & Agree** — consent checkboxes, notification toggles

Each form is fetched live from **Contentful** and the workflow is driven by **Camunda/Zeebe**.

## Other Commands

| Command | What it does |
|---|---|
| `make test` | Run all 94 tests |
| `make validate` | Verify BPMN form references exist in Contentful |
| `make stop` | Kill BFF + frontend |
| `make clean` | Stop everything including Docker containers |
| `make infra` | Start only Zeebe + Elasticsearch |
| `make infra-down` | Stop Docker containers |

## Architecture

```
Browser (:5174)  →  Vite proxy  →  BFF (:3000)  →  Zeebe (:26500)
                                       ↓
                                  Contentful CDN
                                  (form schemas)
```

**Pattern**: No-Tasklist Worker — BPMN process drives form sequence,
Contentful provides form schemas, BFF bridges them via SDUI composition.

## Key Files

| Path | Purpose |
|---|---|
| `bpmn/registration-invite.bpmn` | 3-step registration workflow |
| `packages/bff/src/camunda/` | Zeebe workers + task cache |
| `packages/bff/src/contentful/` | CMS client (mock + real Contentful) |
| `packages/bff/src/composition/` | SDUI composition with intercept |
| `packages/frontend/src/` | React SPA with dynamic form renderer |
| `docs/findings.md` | Spike results — S1-S8 pass/fail with evidence |
