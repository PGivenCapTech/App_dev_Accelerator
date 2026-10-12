---
name: spike
description: Spike loop — time-boxed investigation to confirm or kill assumptions before committing to build. Produces evidence, not production code.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /spike — Spike Loop (Assumption Validation)

The **Spike** loop is a time-boxed investigation that answers a specific question or validates a specific assumption. It produces **evidence and a decision**, not production code. Spikes are created during /refine when the team encounters unknowns.

## Context Check (Before Starting)

Before starting a spike, verify:
- `docs/engagement/environments.md` — Sandbox/dev environment access for prototyping
- `docs/engagement/codebase-patterns.md` — Existing patterns (don't spike what already exists)
- `docs/engagement/team.md` — Technical lead (who to validate findings with)

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Lead investigator** | Dmitri (technical) or Igor (business) | Drives the investigation |
| **Challenge** | Paul | "How would we prove/disprove this?" |
| **Navigator** | User | Sets time-box, approves conclusion |

## Spike Contract (Entry Criteria)

Every spike starts with:

```
Question:     [Specific question to answer]
Hypothesis:   [What we believe is true]
Time-box:     [Max duration — typically hours, not days]
Success:      [What evidence would confirm the hypothesis]
Failure:      [What evidence would kill the hypothesis]
Impact:       [What's blocked until this is answered]
```

## The Loop

```
┌─────────────────────────────────────────────────┐
│  1. State the hypothesis clearly                │
│     User approves: "This is what we need to     │
│     learn"                                      │
│                                                 │
│  2. Dmitri/Igor investigates:                   │
│     - Prototype (throwaway code)                │
│     - Research (API docs, vendor specs)          │
│     - Benchmark (performance test)              │
│     - Proof of concept (minimal viable test)    │
│                                                 │
│  3. Paul challenges the evidence:               │
│     "Does this actually prove/disprove it?"     │
│     "What conditions weren't tested?"           │
│                                                 │
│  4. Present findings to User:                   │
│     "Confirmed" / "Killed" / "Inconclusive"     │
│                                                 │
│  5. User decides:                               │
│     □ Confirmed → back to /refine or /design    │
│     □ Killed → reshape the feature or drop it   │
│     □ Inconclusive → extend time-box or /challenge│
│     □ Need more info → loop again               │
└─────────────────────────────────────────────────┘
```

## Spike Types

### Technical Spike (Dmitri leads)
- Can we integrate with [external API]?
- What's the actual performance of [approach] under [load]?
- Does [library/framework] support [capability] we need?
- What's the migration path from [current] to [proposed]?

### Business Spike (Igor leads)
- Do users actually need [capability]? (prototype + feedback)
- What's the regulatory position on [approach]?
- What data exists to validate [assumption]?

### Architecture Spike (Dmitri leads, informed by Discovery Archie)
- Does [pattern] work at our scale?
- What's the operational complexity of [approach]?
- How does [choice] affect our NFR targets?

## Rules

- **Time-boxed**: spikes end when the time-box expires, even if inconclusive
- **Throwaway**: spike code is NOT production code — it proves a point, then gets deleted
- **Evidence-based**: conclusions must cite specific evidence, not opinions
- **One question per spike**: if multiple unknowns, create multiple spikes

## Outputs

```
backlog/spikes/<spike-slug>/
  hypothesis.md     — Question, hypothesis, success/failure criteria
  evidence.md       — What was found (code snippets, benchmarks, API responses)
  conclusion.md     — Confirmed/Killed/Inconclusive + rationale
  impact.md         — How this affects the blocked feature(s)
```

## Invocation

```bash
/spike "Can the payment API handle idempotency without native support?"
/spike --list                  — Show open spikes
/spike --close <slug>          — Present conclusion for user approval
```
