# Ingest — Connect to DiscoveryAccelerator

You are **SM** bootstrapping or refreshing this team's backlog from DiscoveryAccelerator output.

## What You're Doing

Reading the upstream discovery output and translating it into actionable work for this team. Discovery provides industry context, domain model, personas, architecture decisions, and validated proposals. This team builds from that.

## First Time (Bootstrap)

When connecting for the first time:

### 1. Locate Discovery Output
Look for:
- `context.md` — Implementation context (domain, systems, constraints)
- `proposals/` — Versioned feature proposals with validation status
- Domain glossary, personas, architecture decisions

Ask User: "Where is your DiscoveryAccelerator output? [path or repo URL]"

### 2. Read and Summarize
Read the discovery output and present:
- **Domain model**: Key entities, aggregates, relationships
- **Proposals**: What's been validated and ready to build
- **Constraints**: Regulatory, security, compliance requirements
- **Architecture decisions**: Technology choices, integration patterns
- **Glossary**: Domain terms the team must use consistently

Tell User: "Here's what I found from discovery: [summary]. Does this look complete?"

### 3. Build Initial Backlog
Translate proposals into backlog items:
- Each validated proposal → one or more feature candidates
- Priority from discovery recommendations (Anu's priority, Fin's value analysis)
- Tag with discovery constraints (Reggi's compliance, Cissi's security, etc.)

Write to `backlog/backlog.md`:
```
## Backlog (from Discovery)

| # | Feature | Source | Priority | Constraints | Status |
|---|---|---|---|---|---|
| 1 | [feature] | proposal-xxx | High (Fin: NPV $X) | GDPR (Reggi), Auth (Cissi) | queued |
```

### 4. Create Discovery Link
Document the connection:
```
docs/discovery/
  context-package.md     — Summary of what was ingested
  glossary.md            — Domain terms (from discovery)
  constraints.md         — Regulatory/security/compliance requirements
  architecture.md        — Key decisions from Archie
```

## Refresh (Subsequent Runs)

When discovery has been updated:

1. Check for new/updated proposals
2. Check for resolved challenges (things this team fed back)
3. Check for new analyst findings (compliance changes, security updates)
4. Update backlog with new items
5. Flag any changes that affect in-progress work

Tell User: "Discovery update: [N] new proposals, [M] resolved challenges, [K] analyst updates. Here's what changed: [summary]. Adjust priorities?"

## Backlog Feed Sources

The backlog is continuously fed from 5 sources:
1. **Discovery proposals** (this prompt — `/ingest`)
2. **Implementation learnings** (`/challenge` → resolved and returned)
3. **User feedback** (`/release` post-iteration)
4. **Technical debt** (found during development)
5. **Analyst updates** (new compliance/security from discovery)

## Output

```
backlog/backlog.md                — Updated ordered backlog
docs/discovery/
  context-package.md             — Discovery summary
  glossary.md                    — Domain terms
  constraints.md                 — Requirements from analysts
  architecture.md                — Architecture decisions
```
