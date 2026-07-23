---
version: 1
last_updated: 2026-07-23
updated_by: system
custom_criteria: []
---

# Definition of Done

This is the team's quality gate. **Nothing is released unless ALL criteria are met.** This document can be enhanced by the User — add custom criteria under "Engagement-Specific Criteria" and they become mandatory for all subsequent iterations.

## Core Criteria (Non-Negotiable)

These cannot be removed or weakened. They represent the baseline quality the accelerator enforces.

### 1. Traceability — 100%

| Rule | Verification |
|---|---|
| Every Gherkin scenario traces to at least one step definition | `verify-traceability.sh` |
| Every Gherkin scenario traces to at least one integration test | `verify-traceability.sh` |
| Every public method in production code has at least one unit test | `verify-traceability.sh` |
| Every production source file traces to at least one requirement (scenario) | `verify-traceability.sh` |
| No orphan code (code with no requirement trace) | `verify-traceability.sh` |
| Traceability matrix (`traceability.md`) is complete and current | SM review |
| Bidirectional: requirement → test → code AND code → test → requirement | `verify-traceability.sh` |

**If traceability < 100% → deployment is blocked. No exceptions.**

### 2. All Tests Passing and Automated

| Rule | Verification |
|---|---|
| All BDD/Gherkin scenarios pass | CI pipeline (test stage) |
| All integration tests pass | CI pipeline (test stage) |
| All unit tests pass | CI pipeline (build stage) |
| No pending, skipped, or ignored tests | CI pipeline + `verify-no-skips.sh` |
| No manual test steps — everything automated | SM review |
| Tests run in CI on every commit | Pipeline definition |
| Tests run in deployment pipeline per environment | Pipeline definition |
| Test results reported and archived | CI artifact storage |

**If any test is failing, skipped, or manual → deployment is blocked. No exceptions.**

### 3. All NFRs Represented as Tests and Passing

| Rule | Verification |
|---|---|
| Performance requirements expressed as Gherkin scenarios | SM review |
| Security requirements expressed as Gherkin scenarios | SM review |
| Resilience requirements expressed as Gherkin scenarios | SM review |
| Observability requirements expressed as Gherkin scenarios | SM review |
| All NFR scenarios have automated test implementations | CI pipeline |
| All NFR tests pass within defined thresholds | CI pipeline (NFR stage) |
| NFR thresholds are explicit (not "fast" — a number) | SM review |
| Cross-cutting NFR suite exists and passes | CI pipeline |
| Inline NFR scenarios per feature exist and pass | CI pipeline |

**If any NFR is not represented as an automated test → deployment is blocked. No exceptions.**

### 4. Unit Test Coverage — 100% Automated

| Rule | Verification |
|---|---|
| 100% line coverage on all production code | Coverage tool report |
| 100% branch coverage on all production code | Coverage tool report |
| Coverage measured automatically on every build | CI pipeline |
| Coverage report generated and archived | CI artifact storage |
| No `@Ignore`, `skip`, `xit`, `pragma: no cover`, or exclusion annotations | `verify-no-skips.sh` |
| No coverage exclusion comments or config overrides | `verify-no-exclusions.sh` |
| Coverage gate blocks merge if < 100% | Branch protection / CI gate |

**If coverage < 100% → deployment is blocked. No exceptions.**

## Verification Summary

All criteria above are verified by automated scripts and CI gates:

```
scripts/
  verify-traceability.sh       — Checks bidirectional trace: scenario ↔ test ↔ code
  verify-coverage.sh           — Checks 100% line + branch coverage
  verify-no-skips.sh           — Checks no skipped/ignored/pending tests
  verify-no-exclusions.sh      — Checks no coverage exclusion annotations
  verify-nfr-representation.sh — Checks all NFRs have corresponding test scenarios
```

These scripts run:
- Pre-commit (local)
- On every CI build
- As a gate before environment promotion
- SM runs manually before authorizing release

## Engagement-Specific Criteria

_User: add your additional Done criteria below. Each becomes mandatory for all iterations._

<!--
Examples of criteria you might add:

- [ ] Architecture review completed and approved by [name]
- [ ] Security review signed off by AppSec team
- [ ] Documentation updated in [wiki/confluence/etc.]
- [ ] Demo recording created for stakeholders
- [ ] Performance baseline updated post-deploy
- [ ] Runbook updated for production support handoff
- [ ] Accessibility (WCAG 2.1 AA) validated
- [ ] API documentation (OpenAPI spec) current
- [ ] Database migration reversible
- [ ] Feature flag cleanup plan documented
- [ ] Client product owner sign-off received
-->

| # | Criterion | Verification | Added By | Date |
|---|---|---|---|---|
| | | | | |

## How to Add Criteria

Tell SM: "Add to Definition of Done: [your criterion]"

SM will:
1. Add it to the table above
2. Determine verification method (automated script, manual review, or CI gate)
3. Apply it from the NEXT iteration forward (not retroactively)
4. All loops will enforce it going forward

## How Loops Use This Document

Every loop references this Definition of Done:

| Loop | When DoD is Checked |
|---|---|
| `/refine` | Scenarios must be TESTABLE against DoD (can we automate verification?) |
| `/design` | Design must ENABLE DoD (architecture supports full test automation) |
| `/test-and-develop` | SM verifies DoD CONTINUOUSLY as code lands (not just at end) |
| `/deploy-and-validate` | Pipeline ENFORCES DoD gates at every environment promotion |
| `/release` | SM confirms ALL DoD criteria met before authorizing production |

## What Happens When DoD is Not Met

```
SM: "Definition of Done NOT met. Blocking deployment."

Gaps:
  ❌ [Criterion]: [what's missing]
  ❌ [Criterion]: [what's missing]

Required actions:
  → [Agent]: [specific fix needed]
  → [Agent]: [specific fix needed]

Deployment unblocked when: all criteria ✅
```

No negotiation. No "we'll fix it next sprint." Done means Done.
