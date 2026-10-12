---
version: 4
last_updated: 2026-10-12
updated_by: SM
sdlc_enhancements: []
custom_criteria: [accessibility-wcag-2.1-aa, test-file-convention]
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
| 11 | Accessibility acceptance criteria defined — applicable WCAG 2.1 AA success criteria identified, keyboard navigation flows specified, screen reader expectations documented | Igor + Paul |
| 12 | Assistive technology personas considered — screen reader user, keyboard-only user, low-vision user behaviors addressed in scenarios | Igor |
| 13 | Color contrast requirements specified for any new UI elements (4.5:1 normal text, 3:1 large text and UI components per WCAG 1.4.3) | Paul |
| 14 | Interactive component patterns reference WAI-ARIA Authoring Practices — correct roles, states, and properties identified before implementation | Paul + Dmitri |
| 15 | /refine completed — Igor scenarios + Paul test strategy + Dmitri implementation questions documented. No exceptions regardless of perceived simplicity. | SM (gate enforcement) |
| 16 | Test automation approach specified — GWT capture mechanism identified, no TODO stubs in test infrastructure, data factory requirements documented. Frontend test files must be placed in `__tests__/` subdirectories matching the Vitest config glob pattern. BFF test files must match Jest config pattern. SM verifies test file location as part of test strategy review. | Paul |
| 17 | Integration strategy documented — for stories involving external APIs, the story specifies: mock vs. live, stub contract source, and how integration will be verified | Dmitri + Paul |
| 18 | Scope alignment verified — story traces to an in-scope product line. Stories referencing out-of-scope products are blocked until scope is clarified with User. | Igor + SM |

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
| 19 | Glossary current -- all domain terms used in the story exist in docs/discovery/glossary.md with canonical definitions. New terms added before story enters development. Update protocol: if /refine introduces a new domain term not in the glossary, Igor proposes the definition and SM adds it to `docs/discovery/glossary.md` before /design begins. New terms must not block the story -- add and continue. Change log at bottom of glossary tracks additions. | Igor + SM | Sprint 2 retro (I-2) | 2026-09-29 |
| 20 | Traceability manifest validated by script before story start. SM runs verification script to confirm the traceability manifest is consistent and current before a story enters development. Gaps in the manifest block story start until resolved. | SM | Sprint 3 retro | 2026-09-30 |

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
