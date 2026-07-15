---
name: challenge
description: Feedback loop to DiscoveryAccelerator — when implementation reveals wrong assumptions, missing requirements, or domain model gaps, route them back to the discovery team for resolution.
allowed-tools: [Read, Write, Edit, Bash]
user-invocable: true
---

# /challenge — Feed Back to Discovery

The **Challenge** skill routes implementation learnings back to the DiscoveryAccelerator team. When Dmitri, Paul, or Igor discover that a discovery assumption is wrong, a requirement is missing, or the domain model has gaps — this skill creates a structured challenge that the discovery team can resolve.

## When to Use

- Dmitri discovers an API doesn't support the assumed contract
- Paul finds an edge case that reveals a missing business rule
- Igor can't decompose a story because the domain model is ambiguous
- A compliance requirement was missed that blocks implementation
- Architecture decision doesn't hold under real implementation load
- Glossary term is ambiguous in practice

## Invocation

```bash
# Raise a challenge
/challenge "The payment API doesn't support idempotency keys — Archie's architecture assumed it did"

# Raise against a specific proposal
/challenge --proposal <id> "Anu's hypothesis assumes users have email — 30% of our target segment doesn't"

# List open challenges
/challenge --list

# Check if upstream resolved any
/challenge --check
```

## What Gets Created

A challenge file in `backlog/challenges/`:

```markdown
---
id: challenge-<timestamp>
status: open  # open → sent → resolved → applied
raised_by: dmitri  # or paul, igor
proposal: <id>
discovery_agents: [archie, anu]  # who needs to weigh in
created: 2026-07-15
resolved: null
---

## Challenge

The payment API doesn't support idempotency keys — Archie's architecture assumed it did.

## Context

- Feature: monthly-payment-batch
- Implementation phase: /test-and-build
- Paul's test: PaymentIdempotencyIT:L23 — fails because API returns duplicate

## Impact

- Cannot safely retry failed payments
- Affects: 3 scenarios in payment-batch.feature
- Blocks: deployment of payment feature

## What We Need from Discovery

1. Archie: Revised architecture for payment retry without idempotency
2. Anu: Is "at-most-once" payment acceptable? Or must we guarantee exactly-once?

## Resolution (filled by discovery team)
<!-- Updated after /ingest --refresh picks up the resolution -->
```

## How It Flows Back

```
Dev Team (/challenge)
    ↓ writes challenge file
backlog/challenges/<id>.md
    ↓ user communicates to discovery (manual or git push)
DiscoveryAccelerator team resolves
    ↓ updates proposal with revised analysis
/ingest --refresh
    ↓ SM picks up resolution
Dev team adjusts (Igor rewrites scenario, Paul updates test, Dmitri reimplements)
```

## SM's Role

SM monitors challenges and:
- Moves affected features to `backlog/blocked/` if the challenge blocks progress
- Pulls the next non-blocked item for the team to work on
- When `/ingest --refresh` shows a resolution → moves feature back to active
- Ensures the resolution is reflected in Igor's features, Paul's tests, and Dmitri's code

## Challenge States

| State | Meaning |
|---|---|
| `open` | Raised by dev team, not yet communicated upstream |
| `sent` | Communicated to discovery team (user pushed/shared) |
| `resolved` | Discovery team provided updated analysis |
| `applied` | Dev team incorporated the resolution |
| `won't-fix` | Discovery team says "proceed as-is" with rationale |
