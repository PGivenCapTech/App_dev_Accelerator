---
name: demo
description: Demo loop — on-demand showcase of what's been built. Adapts format to audience (technical, product, executive). Invocable at any point in the lifecycle.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /demo — Demonstrate What's Been Built

The **Demo** loop produces a showcase of working software tailored to the audience. It's invocable at any point — after refinement (show scenarios), after development (show it working), after deployment (show it in an environment), or after release (show production). The format and depth adapt to who's watching.

## When to Use

| Trigger | What's Available to Show | Typical Audience |
|---|---|---|
| After `/refine` | Scenarios, examples, acceptance criteria | Product owner, stakeholders |
| After `/design` | Architecture, API contracts, event flows | Technical leads, architects |
| After `/test-and-develop` | Working feature, test evidence, traceability | Engineering team, product |
| After `/deploy-and-validate` | Feature running in environment, performance data | Broader stakeholders |
| After `/release` | Production feature, metrics, business outcome | Executives, sponsors, clients |
| On-demand | Whatever currently exists | Whoever needs to see it |

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Presenter** | SM | Structures the demo, narrates the story |
| **Technical depth** | Dmitri | Architecture decisions, how it works under the hood |
| **Quality evidence** | Paul | Test results, coverage, NFR performance |
| **Business value** | Igor | What problem it solves, for whom, what outcomes |
| **Navigator** | User | Directs focus, identifies audience, approves output |

## The Loop

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  1. SM asks about the demo                                  │
│     "Who is the audience?"                                 │
│     "What feature(s) are we showing?"                      │
│     "What environment can we demonstrate in?"              │
│     "What's the key message / outcome you want?"           │
│                                                             │
│  2. SM selects format based on audience                     │
│     → Technical team: live walkthrough + script            │
│     → Product/PM: scenario evidence + outcomes             │
│     → Executive/sponsor: deck + business value             │
│     → Client delivery: full package (deck + evidence)      │
│     → User approves format                                 │
│                                                             │
│  3. Team assembles the demo content                         │
│     Igor: business narrative (problem → solution → outcome)│
│     Paul: quality evidence (tests, coverage, NFRs)         │
│     Dmitri: technical walkthrough (architecture, API)      │
│     SM: structures into chosen format                      │
│                                                             │
│  4. SM presents draft to User                               │
│     "Here's the demo package. Anything to adjust?"        │
│     → User approves / adjusts focus / adds context        │
│                                                             │
│  5. Finalize and deliver                                    │
│     → Write output artifacts to backlog/<slug>/demo/       │
│     → User: "Ready to present."                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Audience Formats

### Technical Team (Engineering, Architects)

**Format:** Live walkthrough script + API examples

**Content:**
```
DEMO SCRIPT — Technical

Feature: [name]
Environment: [where to show it]
Duration: ~15 minutes

1. CONTEXT (2 min)
   - What problem, for whom
   - Key design decisions (why this approach)

2. LIVE WALKTHROUGH (8 min)
   - Scenario 1: [happy path] — show the API call, response, events published
   - Scenario 2: [edge case] — show error handling, validation
   - Scenario 3: [NFR] — show performance under load / resilience on failure

3. UNDER THE HOOD (3 min)
   - Architecture diagram
   - Event flow
   - Key code paths (not line-by-line — structural)

4. QUALITY EVIDENCE (2 min)
   - Test suite: X scenarios, Y unit tests, all green
   - Coverage: 100%
   - Traceability: 100%
   - NFR results: [P95 latency, error rates, etc.]

Supporting artifacts:
  - API call examples (curl/httpie commands)
  - Event flow diagram
  - Test execution summary
```

### Product / PM (Product Owners, Business Analysts)

**Format:** Scenario walkthrough + outcome evidence

**Content:**
```
DEMO SCRIPT — Product

Feature: [name]
Business outcome: [what this enables]
Duration: ~10 minutes

1. THE PROBLEM (2 min)
   - Who experiences it (persona)
   - What they can't do today
   - Business impact of not solving

2. THE SOLUTION (5 min)
   - Scenario by scenario (Given/When/Then → show it working)
   - For each: "As [persona], I can now [action], which means [outcome]"
   - Show real data flowing through real scenarios

3. EDGE CASES HANDLED (2 min)
   - What could go wrong → show the system handles it gracefully
   - Security: unauthorized access prevented
   - Resilience: dependency failure handled

4. CONFIDENCE (1 min)
   - All acceptance criteria met (show green scenarios)
   - Performance meets targets
   - Ready for [environment/users]

Supporting artifacts:
  - Scenario-by-scenario evidence (pass/fail with details)
  - Before/after comparison (what changed for the user)
  - Business metric impact (if measurable)
```

### Executive / Sponsor (C-suite, Client Leadership)

**Format:** Presentation deck + summary

**Content:**
```
DEMO DECK — Executive

Slides:

1. TITLE
   [Feature name] — [one-line business outcome]

2. THE PROBLEM
   [Persona] can't [action] because [constraint]
   Impact: [business cost / risk / missed opportunity]

3. WHAT WE BUILT
   [2-3 bullet capabilities, no jargon]
   Screenshot or diagram of the user experience

4. LIVE DEMONSTRATION (optional — or link to recording)
   Show the golden path: user does [action], system responds with [outcome]

5. QUALITY & CONFIDENCE
   - Fully tested (N scenarios, 100% coverage)
   - Performance validated (P95 < Xms under Y load)
   - Security reviewed
   - Deployed to [environment], ready for [next step]

6. BUSINESS IMPACT
   - [Metric]: before [X] → after [Y] (or projected)
   - [Risk mitigated]: [description]
   - [Efficiency]: [time/cost saved]

7. NEXT STEPS
   - What's coming next
   - Decisions needed from [audience]
   - Timeline

Supporting artifacts:
  - Slide deck (markdown or PowerPoint-ready)
  - Executive summary (one-pager)
  - Demo recording link (if applicable)
```

### Client Delivery (Full Package)

**Format:** Everything — deck + script + evidence + recording notes

**Content:**
Combines executive deck + technical walkthrough + quality evidence into a delivery package:

```
demo/
  deck.md                    — Presentation slides (markdown)
  demo-script.md             — Step-by-step walkthrough
  evidence/
    test-results.md          — Full test execution summary
    coverage-report.md       — Coverage metrics
    nfr-results.md           — Performance, security, resilience evidence
    traceability-summary.md  — Requirement ↔ test ↔ code mapping
  api-examples.md            — Curl/httpie commands to exercise the feature
  architecture.md            — Diagrams and key decisions
  business-impact.md         — Outcome metrics and value delivered
```

## Content Sources (What the Team Reads)

The demo is assembled from existing artifacts — the team doesn't create new content from scratch:

| Content Needed | Source |
|---|---|
| Business narrative | `backlog/ready/<slug>/feature.md` (scenarios, personas) |
| Technical design | `backlog/ready/<slug>/design.md`, `event-flow.md`, `api-contract.md` |
| Test evidence | CI results, `backlog/active/<slug>/traceability.md` |
| NFR results | Test reports from `/deploy-and-validate` |
| Architecture | `backlog/ready/<slug>/component-diagram.md` |
| Business outcome | Discovery context, Igor's original feature description |
| Environment status | `backlog/active/<slug>/status.md`, `monitoring/<env>-baseline.md` |

## Output

```
backlog/<state>/<slug>/demo/
  demo-script.md             — Walkthrough script (always produced)
  deck.md                    — Presentation (if executive/client audience)
  evidence/                  — Quality artifacts (if product/executive audience)
  api-examples.md            — API calls (if technical audience)
  architecture.md            — Diagrams (if technical audience)
  business-impact.md         — Value summary (if executive audience)
```

## Demo Do's and Don'ts

**Do:**
- Show WORKING software (not slides about software)
- Use real scenarios from the feature file (Given/When/Then)
- Show actual test results (not "we tested it")
- Tailor depth to audience (executives don't need curl commands)
- State what's NOT done yet (avoid overselling)
- Connect features to business outcomes (why it matters)

**Don't:**
- Demo in an environment that's unstable (verify health first)
- Show implementation details to business audiences (they don't care)
- Skip edge cases (they show maturity and thoroughness)
- Make claims without evidence (show the test, show the metric)
- Demo features that aren't fully tested (quality gate violation)
- Present someone else's work without attribution

## Invocation

```bash
/demo                                — Demo the most recently completed feature
/demo <feature-slug>                 — Demo a specific feature
/demo --audience technical           — Format for engineering team
/demo --audience product             — Format for product/PM
/demo --audience executive           — Format for C-suite/sponsors
/demo --audience client              — Full delivery package
/demo --env staging                  — Demo against specific environment
/demo --dry-run                      — Assemble content without finalizing (review first)
```
