---
name: ingest
description: Bootstrap or refresh from DiscoveryAccelerator output — pull context, proposals, backlog, architecture decisions into the dev project. Runs once to bootstrap, then again whenever discovery updates.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /ingest — Pull Discovery Output into Dev Project

The **Ingest** skill connects this development project to its upstream DiscoveryAccelerator output. It runs in two modes:

- **Bootstrap** (first time): scaffolds the project from discovery output
- **Refresh** (subsequent): pulls updated context, new proposals, revised backlog items

## Invocation

```bash
# Bootstrap: first time, specify discovery source
/ingest ~/path/to/discovery-project

# Refresh: pull latest changes from already-linked discovery
/ingest --refresh

# Pull a specific new proposal into the backlog
/ingest --proposal <proposal-id>

# Show what's changed upstream since last ingest
/ingest --diff
```

## How the Link Works

On first `/ingest`, a `.discovery-link` file is created in the project root:

```yaml
---
source: /Users/pgiven/DiscoveryAccelerator  # or git URL
last_ingest: 2026-07-15T10:30:00
proposals_ingested:
  - accelerator-platform-v3
  - notification-system-v2
context_hash: sha256:abc123...  # detect upstream changes
---
```

This file tells `/ingest --refresh` where to look without the user specifying the path again.

## Bootstrap Mode (First Run)

### What Gets Pulled

| Discovery Source | Dev Project Destination | Purpose |
|---|---|---|
| `context.md` | `docs/discovery/context.md` | Implementation context (platform, constraints) |
| `proposals/<id>/proposal.json` | `docs/discovery/proposals/<id>.json` | Full proposal with all agent analyses |
| Anu's hypothesis + success criteria | `backlog/backlog.md` (seeded) | Initial prioritized backlog |
| Archie's architecture analysis | `docs/technology/reference-architecture.md` | Architecture decisions |
| Paul's Given/When/Then (discovery) | `backlog/seed-scenarios/` | Starting scenarios for Igor to decompose |
| Domain terms from Anu | `docs/discovery/glossary.md` | Ubiquitous language |
| Analyst findings (Reggi, Cissi, etc.) | `docs/discovery/compliance.md` | Compliance constraints |
| Scribe's backlog items | `backlog/backlog.md` | Feature list with acceptance criteria |

### What Gets Generated

From the ingested context, scaffold the dev project:

```
<project-root>/
  .discovery-link           — Link back to discovery source
  docs/
    discovery/              — Ingested context (read-only reference)
    technology/             — Architecture, ADRs, tech-blueprint (generated)
    event-flow-mapping.md   — Traceability skeleton
    event-flows.md          — Mermaid diagram skeleton
  backlog/
    backlog.md              — Prioritized features from Scribe
    seed-scenarios/         — Paul's discovery Gherkin (for Igor to decompose)
    active/                 — Empty (SM fills during /plan)
    done/                   — Empty
    blocked/                — Empty
  src/                      — Source tree (per tech stack from Archie)
  infra/                    — IaC skeleton (AWS CDK default)
  pipeline/                 — CI/CD workflow skeleton
  scripts/
    verify-traceability.sh  — Traceability check (generated)
    verify-coverage.sh      — Coverage check (generated)
```

### Tech Stack Detection

From Archie's analysis, determine:
- Language + framework → project scaffolding (Gradle, npm, pip, etc.)
- Database → migration tooling setup
- Messaging → event infrastructure
- Deployment target → IaC templates

If Archie didn't specify → **AWS defaults** (see CLAUDE.md).

## Refresh Mode (Subsequent Runs)

When `/ingest --refresh` is run:

1. Read `.discovery-link` to find upstream source
2. Compare `context.md` hash → has implementation context changed?
3. Check for new or updated proposals → new backlog items?
4. Check for new analyst findings → new compliance constraints?
5. Present changes to SM:

```
DISCOVERY UPDATES SINCE LAST INGEST:

Context changes:
  - Platform constraint added: "Must support Azure AD SSO" (new)
  - Architecture decision revised: "Archie now recommends EventBridge over SQS direct"

New proposals:
  - notification-system-v2 (status: backlog-ready)
    Anu: "Strong hypothesis, validated"
    Archie: "Feasible, M effort"
    Paul: "5 scenarios defined"

Updated analyst findings:
  - Cissi: "New NIST 800-53 control applicable to auth module"
  - Reggi: "GDPR Article 17 applies to user data deletion flow"

RECOMMENDED ACTIONS:
  1. Add notification-system to backlog (priority: high)
  2. Update compliance.md with new findings
  3. Flag SSO constraint to Dmitri (affects auth implementation)
```

SM decides what to act on. User approves.

## Continuous Learning Protocol

The dev team learns from discovery **continuously**, not just at bootstrap:

### What Triggers a Refresh

- User runs `/ingest --refresh` explicitly
- SM detects a `/challenge` was resolved upstream
- Discovery team runs new analyst assessments
- Context.md is updated with new stakeholder information

### What the Team Does with New Information

| New Information | Impact | Who Acts |
|---|---|---|
| New proposal (backlog-ready) | Add to `backlog/backlog.md` | SM adds, user approves in next `/plan` |
| Revised architecture decision | Update tech-blueprint, may affect active code | SM alerts Dmitri |
| New compliance constraint | Add scenarios, may need new tests | SM alerts Igor + Paul |
| Discovery question answered | Unblock `blocked/` items | SM moves to backlog |
| Context change (platform/stack) | May require pipeline/infra changes | SM alerts Dmitri |
| Revised success criteria | Update existing feature acceptance criteria | SM alerts Igor |

### Backlog Continuous Feed

The backlog is NEVER static. It receives input from:

1. **Discovery proposals** (via `/ingest --refresh`)
2. **Implementation learnings** (via `/challenge` → discovery resolves → `/ingest --refresh`)
3. **User feedback** (via `/release` post-iteration feedback)
4. **Technical debt** identified during `/test-and-build`
5. **Analyst updates** (new compliance/security requirements)

SM maintains `backlog/backlog.md` as the single source of truth for what to build next, incorporating all these feeds.

## State

```yaml
# .discovery-link (project root)
source: ~/DiscoveryAccelerator  # or git@github.com:org/discovery.git
last_ingest: 2026-07-15T10:30:00
proposals_ingested: [slug-1, slug-2]
context_hash: sha256:...
```

```
# docs/discovery/ (read-only reference — don't edit, re-ingest to update)
context.md
glossary.md
compliance.md
proposals/<id>.json
```
