---
version: 1
last_updated: 2026-07-23
updated_by: system
sdlc_enhancements: []
custom_criteria: []
---

# Definition of Ready

A backlog item is **Ready** when ALL criteria below are met. SM enforces this gate — nothing enters `/design` or `/test-and-develop` unless it passes.

This document is enhanced automatically when client SDLC controls are captured via `/initiate`. Those enhancements appear in the "SDLC-Derived Criteria" section and are mandatory from that point forward.

## Core Criteria (Non-Negotiable)

These represent the team's baseline for what "ready to build" means.

| # | Criterion | Verified By |
|---|---|---|
| 1 | Behavior described in concrete examples (Given/When/Then) | Igor + Paul |
| 2 | Happy path scenarios defined | Igor |
| 3 | Edge cases and error scenarios identified | Paul |
| 4 | NFR scenarios identified (performance, security, resilience) | Paul + Dmitri |
| 5 | Unknowns surfaced and resolved (or sent to /spike) | Three Amigos |
| 6 | Domain terms used consistently (glossary alignment) | Igor |
| 7 | Acceptance criteria testable without interpretation | Paul |
| 8 | Dependencies identified and unblocked | Dmitri |
| 9 | Effort estimate agreed (S/M/L) | Team |
| 10 | User approves: "This is ready to design" | User |

## SDLC-Derived Criteria

_These are added automatically when `/initiate` captures client SDLC controls. Each maps a client process requirement into a readiness check._

When `docs/engagement/sdlc-controls.md` is populated, SM derives additional criteria from:

| Client SDLC Area | Derived DoR Criterion |
|---|---|
| **PR review requirements** | Reviewers identified and available for this feature |
| **Security gates** | Security review lead time factored into estimate; AppSec contact notified if feature touches auth/data |
| **Change management** | CAB submission timeline identified if release window applies |
| **Release cadence** | Feature sized to fit within one release window |
| **Architecture review** | Architecture review scheduled if feature introduces new components |
| **Dependency scanning** | Third-party dependencies identified and pre-approved |

**How this works:**
1. User provides SDLC controls via `/initiate`
2. SM reads `docs/engagement/sdlc-controls.md`
3. SM adds applicable criteria to the table below
4. From that point forward, `/refine` enforces them

| # | SDLC-Derived Criterion | Source | Added |
|---|---|---|---|
| | | | |

## Engagement-Specific Criteria

_User: add your additional Ready criteria below. Each becomes mandatory for all subsequent refinements._

| # | Criterion | Verified By | Added By | Date |
|---|---|---|---|---|
| | | | | |

## How to Add Criteria

Tell SM: "Add to Definition of Ready: [your criterion]"

SM will:
1. Add it to the appropriate table above
2. Determine who verifies it (Igor, Paul, Dmitri, or User)
3. Apply it from the NEXT refinement forward (not retroactively to items already Ready)
4. `/refine` loop will enforce it going forward

## How Loops Use This Document

| Loop | How DoR is Used |
|---|---|
| `/refine` | Exit gate — item cannot leave refinement until ALL criteria are checked |
| `/design` | Entry gate — SM verifies item meets DoR before allowing design to start |
| `/test-and-develop` | Entry gate — SM blocks development on items that skipped refinement |
| `/spike` | Items failing DoR on "unknowns surfaced" get sent here first |

## Relationship to Definition of Done

DoR and DoD form a quality sandwich:
- **DoR** gates what ENTERS development (prevents waste from building unclear requirements)
- **DoD** gates what EXITS development (prevents shipping incomplete work)

Both are enhanced by client SDLC controls — DoR gets upstream process requirements (reviews scheduled, approvals lined up), DoD gets downstream quality requirements (coverage thresholds, security sign-off, change approval obtained).
