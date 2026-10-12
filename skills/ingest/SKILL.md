---
name: ingest
description: Bootstrap or refresh from DiscoveryAccelerator output — pull context, proposals, backlog into the dev project. Runs once to bootstrap, then again when discovery updates.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch]
user-invocable: true
---

# /ingest — Pull Discovery Output into Dev Project

The **Ingest** skill connects this development project to its upstream DiscoveryAccelerator output. Two modes:

- **Bootstrap** (first time): scaffold project from discovery output
- **Refresh** (subsequent): pull updated context, new proposals, revised findings

## Invocation

```bash
/ingest ~/path/to/discovery-project           — Bootstrap (first time)
/ingest --refresh                             — Pull latest changes
/ingest --proposal <id>                       — Pull specific new proposal
/ingest --diff                                — Show what changed upstream
```

## Link Mechanism

First `/ingest` creates `.discovery-link` in project root:

```yaml
source: ~/DiscoveryAccelerator
last_ingest: 2026-07-23T10:30:00
proposals_ingested: [slug-1, slug-2]
context_hash: sha256:...
```

## Bootstrap (First Run)

Pulls and generates:

```
<project-root>/
  .discovery-link              — Link back to discovery
  docs/discovery/              — Ingested context (reference)
  docs/technology/             — Architecture, ADRs, blueprint
  backlog/backlog.md           — Prioritized features from Scribe
  backlog/seed-scenarios/      — Discovery Paul's Gherkin (for Igor)
  infra/                       — IaC skeleton (AWS CDK default)
  pipeline/                    — CI/CD workflow skeleton
  scripts/verify-traceability.sh
  scripts/verify-coverage.sh
```

## Refresh (Subsequent)

Compares upstream hash, presents changes to SM + User:
- New proposals → add to backlog
- Revised architecture → alert Dmitri
- New compliance findings → alert Igor + Paul
- Resolved challenges → unblock items

User approves what to act on.

## Continuous Learning

The backlog receives from:
1. Discovery proposals (`/ingest --refresh`)
2. Implementation learnings (`/challenge` → resolved → `/ingest --refresh`)
3. User feedback (`/release` post-iteration)
4. Technical debt (identified during `/test-and-develop`)
5. Analyst updates (new compliance/security)
