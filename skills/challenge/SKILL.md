---
name: challenge
description: Feedback loop to DiscoveryAccelerator — route wrong assumptions, missing requirements, or domain model gaps back to the discovery team.
allowed-tools: [Read, Write, Edit, Bash]
user-invocable: true
---

# /challenge — Feed Back to Discovery

The **Challenge** skill routes implementation learnings back to the DiscoveryAccelerator team when the dev team discovers that discovery assumptions are wrong.

## When to Use

- API doesn't support assumed contract
- Edge case reveals missing business rule
- Domain model is ambiguous in practice
- Compliance requirement was missed
- Architecture decision doesn't hold under implementation

## Invocation

```bash
/challenge "Payment API doesn't support idempotency — Archie assumed it did"
/challenge --proposal <id> "Hypothesis assumes email — 30% don't have it"
/challenge --list                  — Show open challenges
/challenge --check                 — Check if upstream resolved any
```

## What Gets Created

```markdown
# backlog/challenges/<id>.md
---
status: open
raised_by: dmitri
proposal: <id>
discovery_agents: [archie, anu]
---

## Challenge
[Description]

## Impact
[What's blocked, which scenarios affected]

## What We Need
[Specific questions for discovery team]
```

## Flow

```
Dev team (/challenge) → backlog/challenges/ → User communicates upstream
  → Discovery resolves → /ingest --refresh → SM unblocks features
```

## States

open → sent → resolved → applied (or won't-fix)
```
