---
name: refine
description: Refinement loop — three amigos (Igor + Paul + Dmitri + User) work a backlog item to Definition of Ready. BDD examples, acceptance criteria, NFRs, and unknowns surfaced.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /refine — Refinement Loop (Three Amigos + User)

The **Refine** loop takes a raw backlog item and works it collaboratively until it meets the Definition of Ready. This is BDD's "Discovery" workshop — the team explores the behavior through examples BEFORE anyone writes code or tests.

## Context Check (Before Starting)

Before starting refinement, verify engagement context is available:
- `docs/engagement/team.md` — Product contact (who clarifies business questions?)
- `docs/engagement/tech-debt.md` — Known fragile areas (affects risk assessment)
- `docs/discovery/context-package.md` — Domain terms, personas, constraints

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants (Three Amigos + User)

| Role | Agent | Contribution |
|---|---|---|
| **Business** | Igor | What behavior is needed, for whom, why |
| **Testing** | Paul | How do we know it works? Edge cases? What could go wrong? |
| **Technical** | Dmitri | Is it feasible? What's hard? What's risky? |
| **Navigator** | User | Steers, approves, provides domain knowledge the team lacks |

## Definition of Ready (Authoritative: `docs/definition-of-ready.md`)

The full Definition of Ready is maintained in `docs/definition-of-ready.md` — that file is the single source of truth. It includes core criteria, SDLC-derived criteria (added automatically when client SDLC controls are captured via `/initiate`), and any engagement-specific criteria the User has added.

A backlog item is READY when ALL criteria in that document are met. Summary of core criteria:

```
□ Behavior described in concrete examples (Given/When/Then)
□ Happy path scenarios defined
□ Edge cases and error scenarios identified
□ NFR scenarios identified (performance, security, resilience inline)
□ Unknowns surfaced → either answered OR sent to /spike
□ Domain terms used consistently (glossary alignment)
□ Acceptance criteria testable without interpretation
□ Dependencies identified
□ Effort estimate agreed (S/M/L)
□ User approves: "This is ready to design"
```

**Plus** any SDLC-derived and engagement-specific criteria from `docs/definition-of-ready.md`.

## The Loop

```
┌─────────────────────────────────────────────────┐
│  1. Igor presents the item (from discovery)     │
│     "Here's what, for whom, why"                │
│                                                 │
│  2. Paul asks: "How would we test this?"        │
│     Proposes examples (Given/When/Then)         │
│                                                 │
│  3. Dmitri asks: "What's hard here?"            │
│     Flags technical risks, unknowns             │
│                                                 │
│  4. User steers: approves, adjusts, adds context│
│                                                 │
│  5. Team iterates examples until shared         │
│     understanding emerges                        │
│                                                 │
│  6. Check Definition of Ready                   │
│     □ Ready → exit loop, item moves to backlog  │
│     □ Unknown → create /spike                   │
│     □ Not ready → loop again from step 2        │
└─────────────────────────────────────────────────┘
```

## Process Detail

### Step 1: Igor Presents

Igor reads the discovery backlog item and presents:
- **Who**: persona from discovery
- **What**: capability needed
- **Why**: business outcome / hypothesis being tested
- **Context**: decisions from discovery, constraints from analysts

**Prompt to User:** "Here's the item: [summary]. Does this match your understanding of what we need to build?"

### Step 2: Paul Explores with Examples

Paul proposes concrete scenarios using BDD format:

```gherkin
# Example-driven exploration
Scenario: [Happy path example]
  Given [specific precondition with real data]
  When [specific action]
  Then [specific observable outcome]

Scenario: [What if this goes wrong?]
  Given [edge condition]
  When [same action]
  Then [error handling]
```

Paul also asks:
- "What happens when [boundary condition]?"
- "What data volumes are we talking about?"
- "What's the performance expectation here?"
- "Who else is affected by this change?"

**Prompt to User:** "Here are the examples I think test this behavior. Missing anything? Any scenarios that would surprise you?"

### Step 3: Dmitri Assesses Feasibility

Dmitri reads Paul's examples and flags:
- Technical risks or unknowns
- Dependencies on external systems
- Architecture implications
- Whether this needs a /spike before /design

**Prompt to User:** "Dmitri flags [concerns]. Do these change the scope or priority?"

### Step 4: NFR Scenarios (BDD's Three Amigos on Non-Functional)

Paul proposes NFR scenarios inline with the feature:

```gherkin
@nfr @performance
Scenario: Response time under normal load
  Given the system has 1000 concurrent users
  When a user [performs the action]
  Then the response completes within 200ms at P95

@nfr @security
Scenario: Unauthorized access prevented
  Given a user without [required role]
  When they attempt to [perform the action]
  Then access is denied with 403
  And an audit event is published

@nfr @resilience
Scenario: Graceful degradation when [dependency] is unavailable
  Given [external dependency] is not responding
  When a user [performs the action]
  Then [degraded but acceptable behavior]
  And an alert is raised
```

**Prompt to User:** "These are the non-functional expectations. Are these thresholds right? Anything else we should test for?"

### Step 5: Converge or Loop

SM checks Definition of Ready checklist. If gaps remain:
- Missing examples → Paul proposes more, User confirms
- Unknown feasibility → create a /spike item
- Ambiguous terms → align on glossary definition

**Prompt to User:** "This item [meets / doesn't yet meet] Definition of Ready. [Gap summary]. Ready to move forward, or should we explore more?"

## Outputs

When the loop exits (item is Ready):

```
backlog/ready/<feature-slug>/
  feature.md              — Gherkin scenarios (functional + NFR inline)
  examples.md             — Concrete examples discussed during refinement
  risks.md                — Dmitri's technical risks + unknowns
  dependencies.md         — What this depends on
  definition-of-ready.md  — Checklist (all checked)
```

## Invocation

```bash
/refine                        — Refine the top unrefined backlog item
/refine <backlog-item-slug>    — Refine a specific item
/refine --status               — Show refinement state of all backlog items
```
