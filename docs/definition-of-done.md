---
version: 4
last_updated: 2026-10-12
updated_by: SM
custom_criteria: [accessibility-wcag-2.1-aa, runner-verification]
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
| Integration tests exercise real module wiring — no silent mock substitution via env-var absence or factory bypass | SM review + factory tests |
| Dynamic provider factories (e.g., `selectCmsClient`) are testable and tested for each configuration path | CI pipeline (test stage) |
| Test author verifies execution in actual test runner before reporting results -- runner output (pass/fail counts) accompanies test deliverable. Tests not runner-verified are treated as unwritten. | SM reviews runner evidence before accepting test deliverable |

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

### 5. Accessibility — WCAG 2.1 AA

| Rule | Verification |
|---|---|
| All interactive elements keyboard-navigable (WCAG 2.1.1 Keyboard) | `verify-accessibility.sh` + manual |
| All form controls have programmatic labels and correct role/state/value (WCAG 4.1.2 Name, Role, Value) | `verify-accessibility.sh` + axe-core |
| No `disabled` attribute on informational/readOnly fields — `aria-readonly` pattern enforced (WCAG 1.3.1 Info and Relationships) | `verify-accessibility.sh` + component tests |
| Color contrast meets AA ratio: 4.5:1 for normal text, 3:1 for large text and UI components (WCAG 1.4.3 Contrast) | axe-core automated scan |
| Focus order is logical and predictable (WCAG 2.4.3 Focus Order) | `verify-accessibility.sh` + manual |
| axe-core automated scan passes with zero violations in component tests | CI pipeline (test stage) |
| Manual screen reader verification completed on new UI flows (VoiceOver minimum) | Paul review checklist |

**If any accessibility criterion is not met → deployment is blocked. No exceptions.**

### 6. Cross-Review Completed

| Rule | Verification |
|---|---|
| Igor validates domain language and scenario alignment | SM verifies cross-review evidence |
| Paul validates test quality, coverage strategy, and assertion meaningfulness | SM verifies cross-review evidence |
| Dmitri validates implementation correctness, architecture, and maintainability | SM verifies cross-review evidence |
| All three perspectives documented before story is marked done | SM review |
| Cross-review includes test execution — reviewer runs `npm test` (or relevant command) and verifies tests pass, not just that test code reads correctly | SM verifies runner output in cross-review evidence |

**If cross-review is not completed → deployment is blocked. No exceptions.**

### 7. Code Review Completed

| Rule | Verification |
|---|---|
| Formal code review using `/code-review` skill run on story diff | SM verifies review ran |
| Static analysis, security, correctness, and pattern adherence checked | `/code-review` output |
| Critical and moderate findings resolved before commit | SM review of findings |
| Low findings addressed inline or documented with rationale | SM review |

**If code review is not completed → deployment is blocked. No exceptions.**

### 8. Per-Story Commits

| Rule | Verification |
|---|---|
| Each story committed separately with story ID in commit message | SM reviews git log |
| Commit message format: `type(scope): description (story-id)` | SM review |
| No monolithic multi-story commits | SM reviews git log at sprint close |
| Commit serves as context compression point and traceability anchor | SM review |

**If stories are not committed individually → deployment is blocked. No exceptions.**

### 9. Service Size Gate

| Rule | Verification |
|---|---|
| Production classes stay under 200 lines | Automated check or SM review |
| Multi-concern services decomposed before merge, not deferred | SM review during /test-and-develop |
| Measured on non-test, non-config source files | Automated check |

**If any production class exceeds 200 lines → deployment is blocked. No exceptions.**

### 10. Browser Smoke Test (UI Stories)

| Rule | Verification |
|---|---|
| User-visible flows verified in running browser with services up | Paul + Dmitri verification |
| Verification runs against Docker or deployed environment, not just code tests | SM reviews evidence |
| Issues found during verification fixed and regression-tested | SM review |

**If user-visible flows are not browser-verified → deployment is blocked. No exceptions.**

## Verification Summary

All criteria above are verified by automated scripts and CI gates:

```
scripts/
  verify-traceability.sh       — Checks bidirectional trace: scenario ↔ test ↔ code
  verify-coverage.sh           — Checks 100% line + branch coverage
  verify-no-skips.sh           — Checks no skipped/ignored/pending tests
  verify-no-exclusions.sh      — Checks no coverage exclusion annotations
  verify-nfr-representation.sh — Checks all NFRs have corresponding test scenarios
  verify-accessibility.sh      — Checks WCAG 2.1 AA compliance: axe-core zero violations, no disabled on readOnly, aria patterns correct
```

These scripts run:
- Pre-commit (local)
- On every CI build
- As a gate before environment promotion
- SM runs manually before authorizing release

## SDLC-Derived Criteria

_These are added automatically when `/initiate` captures client SDLC controls. Each maps a client process requirement into a completion check._

When `docs/engagement/sdlc-controls.md` is populated, SM derives additional criteria from:

| Client SDLC Area | Derived DoD Criterion |
|---|---|
| **PR review requirements** | PR approved by required reviewers before merge |
| **Security gates** | AppSec review completed and signed off (if feature touches auth/data) |
| **Change management** | CAB approval obtained (if required for target environment) |
| **Code signing** | Artifacts signed per client policy |
| **Static analysis** | Client's SAST tool passes with zero findings above threshold |
| **Dependency scanning** | No new high/critical vulnerabilities in dependencies |
| **Documentation standards** | Client-required documentation updated (runbooks, wiki, ADRs) |
| **Release approval** | Named release authority has signed off |

**How this works:**
1. User provides SDLC controls via `/initiate`
2. SM reads `docs/engagement/sdlc-controls.md`
3. SM adds applicable criteria to the table below
4. From that point forward, `/deploy-and-validate` and `/release` enforce them

| # | SDLC-Derived Criterion | Source | Verification | Added |
|---|---|---|---|---|
| | | | | |

## Engagement-Specific Criteria

_User: add your additional Done criteria below. Each becomes mandatory for all iterations._

<!--
Examples of criteria you might add:

- [ ] Dashboard/artifact JSON current — test counts match actual suite, coverage non-zero, aggregation fails on stale data
- [ ] External integrations exercised live — Camunda workflows deployed, CMS content fetched in running environment, not just mocked
- [ ] Accessibility (WCAG 2.1 AA) validated
- [ ] Architecture review completed and approved by [name]
- [ ] Security review signed off by AppSec team
- [ ] Documentation updated in [wiki/confluence/etc.]
- [ ] Demo recording created for stakeholders
- [ ] Performance baseline updated post-deploy
- [ ] Runbook updated for production support handoff
- [ ] API documentation (OpenAPI spec) current
- [ ] Database migration reversible
- [ ] Feature flag cleanup plan documented
- [ ] Client product owner sign-off received
-->

| # | Criterion | Verification | Added By | Date |
|---|---|---|---|---|
| 5 | Dashboard JSON current -- test counts match `npm run test:all` output, coverage values are non-zero and match actual coverage reports, aggregation script exits non-zero on stale or missing data. Dashboard JSON regenerated at sprint close. Regeneration via `npm run test:evidence` is MANDATORY at sprint close, not optional. SM verifies totalTests in JSON matches `npm run test:all` output before closing the sprint. Resolves Sprint 2 TC-4 permanently. | `npm run test:evidence` + SM verification | Sprint 2 retro (C2, C3, P-4) | 2026-09-29 |
| 6 | Browser smoke test -- all user-visible flows verified in Docker (docker-compose up), not just code-level tests. ALL identified demo moments must be smoke-tested. A partial pass (e.g., 2 of 3 demo moments) does not satisfy this criterion. SM maintains the list of demo moments and verifies each has a corresponding smoke test. Current demo moments: CMS edit, context toggle, registration-to-dashboard. | Paul + Dmitri run Docker stack, SM reviews evidence | Sprint 2 retro (C5, A1, D-2) | 2026-09-29 |
| 7 | Per-story commits -- each story committed separately with story ID in commit message. Monolithic multi-story commits are forbidden. Commit serves as context compression point and traceability anchor. | SM reviews git log at sprint close | Sprint 2 retro (C4, A3, D-5) | 2026-09-29 |
| 8 | 100% branch coverage -- not just line coverage. Every decision point (if/else, switch, ternary, guard clause, error handler) has at least one test exercising each branch. Branch coverage < 100% blocks deployment, same as line coverage. | Coverage tool report (branches column) + CI gate | Sprint 2 retro (P-6) | 2026-09-29 |
| 9 | Service size gate -- production classes must be under 200 lines. Classes exceeding this limit must be decomposed before the story is marked done. Measured on non-test, non-config source files. | SM review + automated check | Sprint 2 retro (D-1) | 2026-09-29 |
| 10 | External integrations exercised live -- for stories involving external service integration (Contentful, Camunda, SkyGen, GIFS), the integration must be exercised against a live or local instance, not just mocked. If live exercise is not possible, the limitation must be explicitly documented with rationale and User approval. | Paul + Dmitri verification, SM review | Sprint 2 retro (D-2, D-3) | 2026-09-29 |
| 11 | Cross-review completed -- Igor validates domain language and scenario alignment, Paul validates test quality and coverage, Dmitri validates implementation correctness. Role-based peer review from different perspectives before the story is marked done. | SM verifies cross-review evidence in story artifacts | Sprint 2 retro (TC-2) | 2026-09-30 |
| 12 | Code review completed -- formal code review using the /code-review skill before commit. Covers static analysis, security, correctness, and pattern adherence. | SM verifies /code-review ran and findings addressed | Sprint 2 retro (TC-2) | 2026-09-30 |
| 13 | GWT annotations required on domain/feature scenarios -- domain and feature test scenarios must have @given/@when/@then annotations describing behavior in business language. Infrastructure/utility tests are exempt but must document rationale (e.g., "infrastructure test, no GWT applicable"). Target: 50%+ GWT coverage on domain/feature tests. Verification: aggregation script reports GWT coverage metric. | Aggregation script + SM review | Sprint 3 retro (TC-1) | 2026-09-30 |

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
