# Leading Practices

Practices learned through delivery that the team adopts going forward. Each originated from a real situation — the "Why" explains the incident or insight that produced it.

## Domain Modeling

### Regulatory-Qualified Domain Terms

**Practice:** If a domain term is driven by an external regulatory standard, include the regulatory body name in the field/class name.

**Example:** `oshaRecordable` (OSHA 29 CFR 1904), not just `recordable`.

**Why:** Multiple regulatory frameworks may define similar concepts (OSHA recordable, EPA reportable, MSHA recordable). A bare term like `recordable` is ambiguous when frameworks overlap. Naming the regulatory body eliminates interpretation at read-time.

**How to apply:** When introducing a domain term, ask: "Is this defined by an external standard?" If yes, prefix with the standard's owning body. This applies to field names, enum values, event names, and API contract fields.

---

## Process Discipline

### Never Skip Process Steps

**Practice:** Always follow the full flow (refine → design → develop), even when the content feels already covered or "obvious."

**Why:** Skipping steps creates invisible gaps. A domain model issue was caught during TDD that would have been caught earlier in /design — but only because the team went back and ran the design step properly. The controls exist to catch mistakes; "obvious" features still have non-obvious edges.

**How to apply:** SM enforces this by default. If a team member suggests skipping a step ("we already know the design"), SM redirects: "Let's run it — it's fast when there's nothing to find, and it catches things when there is." The cost of running a clean step is minutes; the cost of missing something is hours of rework.

### Never Skip /refine — Concrete Evidence

**Practice:** Every story goes through three-amigos refinement (Igor scenarios + Paul testability + Dmitri feasibility) before implementation. No "feels obvious" exceptions.

**Why:** A subsequent engagement reinforced the above lesson with concrete evidence. Two dashboard stories skipped /refine. The user flagged it. Retroactive validation against Gherkin scenarios found three functional gaps: a collapsible error trace missing, a status badge not handled, and incomplete coverage text. 15 minutes of refinement would have caught all three before implementation.

**How to apply:** SM blocks /design and /test-and-develop until /refine is recorded. Igor's scenarios, Paul's test strategy, and Dmitri's feasibility assessment must all exist. If someone says "this is obvious, let's skip it" — that's the signal to run it, not skip it.

### Apply /fix-defect Even for Internal Issues

**Practice:** When a defect is found during development or demo prep (not just in production), apply the full defect workflow: reproduction scenario, root cause, regression tests, traceability.

**Why:** A defect found internally has the same root cause as one found in production — it just got caught earlier. If you skip the process for "minor" or "internal" issues, you miss the regression test that prevents it from recurring, and you normalize cutting corners.

**How to apply:** Any bug, regardless of when or where it's found, gets: (1) a failing test that reproduces it, (2) a root cause explanation, (3) a traceability record linking scenario → test → fix.

---

## Code Review

### Run Code Review After Tests Go Green

**Practice:** After Dmitri's tests pass, SM runs `/code-review` on the diff before presenting to the User. The "Right solution?" gate includes automated review findings, not just test results.

**Why:** An implementation was accepted purely because all tests passed. Nobody reviewed the actual code for quality, architecture alignment, naming conventions, or simplification opportunities. Tests prove correctness against a contract — they don't prove the implementation is well-structured.

**How to apply:** After every story where Dmitri writes code: (1) SM runs the built-in `/code-review` on the changes. (2) SM presents findings + implementation to User: "Tests pass. Code review found [N] items. Right solution?" (3) Critical/moderate findings route through `/refactor` or `/test-and-develop`. (4) Low findings are addressed inline or deferred.

---

## Refinement

### Cross-Review During /refine, Not After

**Practice:** Igor, Paul, and Dmitri cross-review each other's work during /refine (before implementation), not just at the exit gate.

**Why:** When cross-review happened during refinement, it caught issues early — zero requirement rework on those stories. When review happened after implementation, functional gaps were baked in and became rework. Late review is damage assessment; early review is prevention.

**How to apply:** SM blocks Dmitri's implementation until Igor's scenarios AND Paul's test strategy both exist and are cross-reviewed by all three. Cross-review at exit remains as DoD, but the high-value review is the early one.

---

## Sprint Planning

### Capacity-Bound Planning with Process Overhead

**Practice:** Sprint plans commit to what the team can complete with full process (/refine → /test-and-develop → cross-review → code review → commit). Additional stories are labeled as explicit stretch goals.

**Why:** A sprint planned 16 stories without accounting for process overhead. Each story requires 4-6 rounds of substantive work when following full process. Without capacity math the team cut process corners (skipping /refine) and accumulated a monolithic commit.

**How to apply:** Estimate 4-6 rounds per story (1 /refine + 2-4 /test-and-develop + 1 cross-review). Multiply by story count. Compare against available capacity (context window, calendar days, team bandwidth). Commit to what fits. Label the rest as stretch. Show the math in the plan.

### DoD Is Constant, Acceptance Criteria Come from /refine

**Practice:** Sprint plans never restate Definition of Done criteria. Sprint exit criteria are sprint-level concerns (review, retro, artifacts updated). Story acceptance criteria emerge from /refine.

**Why:** A sprint's exit criteria section was 20 items mixing DoD restated, story-level acceptance criteria, and process enforcement gates. Analysis showed 11 items were DoD (already enforced), 9 were story AC (should come from /refine), and 0 were actually sprint-specific. This conflation created drift risk and pre-decided /refine outcomes.

**How to apply:** Sprint plan references DoD once ("all stories must meet DoD"). Sprint exit criteria contain only: sprint review completed, sprint retro completed, artifacts updated, all committed stories meet DoD + their acceptance criteria. Nothing else.

### Commit Per Story, Not Per Sprint

**Practice:** Commit after each story goes green, with the story ID in the commit message. Monolithic sprint-level commits are forbidden.

**Why:** A single 288-file, 53K-line commit made PR review impossible (GitHub times out on large diffs), broke git bisect, lost the "why" (one commit message for 16 stories), and blocked cherry-picking individual fixes.

**How to apply:** SM calls the commit point after each story's cross-review and code review pass. Commit message format: `type(scope): description (story-id)`. SM blocks accumulation across stories.

---

## Testing

### Test Evidence Pipeline Is Production Code

**Practice:** Test reporters, aggregation scripts, and dashboard JSON generation are treated as production code — they get 100% coverage, they fail loudly on invalid state, and they are never left with TODO stubs.

**Why:** Reporters had TODO comments where GWT extraction should be (empty arrays for steps). An aggregation script silently reported 0% coverage when files were missing instead of failing. A test evidence dashboard showed stale counts. The dashboard's thesis is "trust through transparency" — serving inaccurate data undermines that thesis completely.

**How to apply:** Reporter and aggregation code goes through /refine and /test-and-develop like any other story. Aggregation scripts must exit non-zero on missing or stale data. No silent defaults (0% is never an acceptable fallback for missing coverage). Regenerate dashboard JSON as part of sprint close and verify counts match the actual test suite.

### Challenge Test Growth Rate

**Practice:** When test count grows faster than scenario count, SM asks "what behavior does this test validate?" not just "did coverage go up?"

**Why:** A sprint grew test count 2.7x for ~160 scenarios (4+ tests per scenario average). Rapid growth driven by coverage targets risks padding — tests that exercise lines without validating behavior. Tests that test mocks instead of behavior create false confidence.

**How to apply:** During cross-review, Paul explains what each test validates in behavior terms. "This test proves that when a member switches profiles, the composition service returns different spokes" — good. "This test imports the module to cover the import line" — challenge it. SM flags test-to-scenario ratios above 5:1 for review.

---

## Architecture

### Service Size Gate

**Practice:** Production service classes stay under 200 lines. Multi-concern services are decomposed before merge, not deferred.

**Why:** A composition service grew to 340 lines coupling data aggregation, entitlement-based authorization, and consent verification. Each concern has different change drivers. Coupling them means every change touches one large file with high blast radius.

**How to apply:** During /design, Dmitri identifies responsibility boundaries. If a class will exceed 200 lines, split it during the same story. Constructor injection makes decomposition straightforward. SM checks post-implementation and blocks commit if exceeded.

### Browser-Verify Before Demo-Ready

**Practice:** Any user-visible flow must be verified in a running browser with services running, not just by code-level tests. "Code tests pass" and "it works in the browser" are different claims.

**Why:** Demo-critical flows passed all code-level tests but were never run in an actual browser with Docker services. "It should work" was the evidence level. Code tests prove individual pieces work; browser verification proves the integration works as a system.

**How to apply:** During /design, the team identifies which flows need browser verification. Run the stack, walk through the flow, fix what breaks, capture evidence. Never declare "demo-ready" without browser evidence.

---

## Domain Language

### Maintain a Living Glossary

**Practice:** Maintain `docs/discovery/glossary.md` with canonical domain terms. All scenarios, code, and documentation use glossary-consistent terminology.

**Why:** An engagement had no formal glossary. Out-of-scope product references persisted in the traceability manifest. Domain terms drifted across sprints without a single source of truth. An evaluator reading the traceability matrix saw scope confusion.

**How to apply:** SM creates the glossary during /initiate or first /refine. Igor flags new terms during refinement. The glossary includes a "superseded terms" section (deny list) for terms that should not appear.

### Scope Alignment on Every Story

**Practice:** Every story traces to an in-scope product line. Out-of-scope references are either removed or explicitly annotated with rationale.

**Why:** Out-of-scope product references survived multiple sprints because no one checked story-level scope alignment. The traceability manifest — the artifact evaluators inspect most closely — contained contradictory scope signals.

**How to apply:** During /refine, Igor confirms the story maps to an in-scope product line. During cross-review, Igor sweeps for out-of-scope terminology. If an out-of-scope reference is legitimate (e.g., RFP context), it gets an explicit annotation explaining why it's there.

---

## Initiation

### Audit .gitignore During /initiate

**Practice:** When initiating on a repo bootstrapped from a template, SM reviews `.gitignore` for rules that conflict with the actual project's directory structure.

**Why:** A template's `.gitignore` included rules that would have blocked tracking ALL source code in the target project. It was caught by a developer, but should have been caught during initiation.

**How to apply:** During `/initiate`, after the repo structure is known, SM runs `cat .gitignore` and checks: "Do any ignore rules conflict with directories this project will use?" Remove or adjust conflicting rules before the first commit.

### Lightweight DoR Check for Infrastructure Stories

**Practice:** All stories — including infrastructure/scaffolding — get a lightweight Definition of Ready check before work starts.

**Why:** Infrastructure stories were treated as "just setup" and skipped the DoR check. A `.gitignore` conflict proved that even scaffolding tasks can have hidden context dependencies.

**How to apply:** Before starting any story, SM confirms: "Does the team have what it needs to build AND verify this?" For infra stories, this includes: template files that need modification, environment prerequisites, and tooling assumptions.

---

## Team Autonomy

### SM Answers Persona-Driven Data Questions

**Practice:** When the team asks "what data does the persona need to see here?", SM can answer directly from discovery context without escalating to the User every time.

**Why:** These questions have answers already captured in discovery (personas, user journeys, data needs). Blocking on the User for every display decision slows the team unnecessarily. SM has access to discovery context and can make the default call — the User course-corrects if needed.

**How to apply:** SM reads the persona definitions, user journey maps, and data requirements from `docs/discovery/`. If the answer is clearly derivable from discovery, SM answers directly. If it requires interpretation or a judgment call beyond discovery scope, SM escalates to the User.

---

## Code Review (Added: Epic 1 Retro)

### Run Code Review After Tests Go Green

**Practice:** After Dmitri's tests pass, SM runs `/code-review` on the diff before presenting to the User. The "Right solution?" gate includes automated review findings, not just test results.

**Why:** During Epic 1, Dmitri's implementation was accepted purely because 18/18 tests passed. Nobody reviewed the actual code for quality, architecture alignment, naming conventions, or simplification opportunities. Tests prove correctness against a contract — they don't prove the implementation is well-structured.

**How to apply:** After every story where Dmitri writes code: (1) SM runs the built-in `/code-review` on the changes. (2) SM presents findings + implementation to User: "Tests pass. Code review found [N] items. Right solution?" (3) Critical/moderate findings route through `/refactor` or `/test-and-develop`. (4) Low findings are addressed inline or deferred.

---

## Initiation (Added: Epic 1 Retro)

### Audit .gitignore During /initiate

**Practice:** When initiating on a repo bootstrapped from a template, SM reviews `.gitignore` for rules that conflict with the actual project's directory structure.

**Why:** The accelerator template's `.gitignore` included `src/`, `infra/`, `pipeline/`, and `monitoring/` rules intended for the template repo itself. These would have blocked tracking ALL source code in the spike project. Dmitri caught it, but it should have been caught during initiation.

**How to apply:** During `/initiate`, after the repo structure is known, SM runs `cat .gitignore` and checks: "Do any ignore rules conflict with directories this project will use?" Remove or adjust conflicting rules before the first commit.

### Lightweight DoR Check for Infrastructure Stories

**Practice:** All stories — including infrastructure/scaffolding — get a lightweight Definition of Ready check before work starts.

**Why:** Infrastructure stories were treated as "just setup" and skipped the DoR check. The `.gitignore` conflict proved that even scaffolding tasks can have hidden context dependencies.

**How to apply:** Before starting any story, SM confirms: "Does the team have what it needs to build AND verify this?" For infra stories, this includes: template files that need modification, environment prerequisites, and tooling assumptions.

---

## Sprint Planning (Added: Sprint 2 Retro)

### Capacity-Bound Planning with Process Overhead

**Practice:** Sprint plans commit to what the team can complete with full process (/refine → /test-and-develop → cross-review → code review → commit). Additional stories are labeled as explicit stretch goals.

**Why:** Sprint 2 planned 16 stories without accounting for process overhead. Each story requires 4-6 rounds of substantive work when following full process. Planning 6 stories into one context window without capacity math led to process shortcuts (skipping /refine on TD.8/TD.9) and a monolithic 288-file commit.

**How to apply:** Estimate 4-6 rounds per story (1 /refine + 2-4 /test-and-develop + 1 cross-review). Multiply by story count. Compare against available capacity (context window, calendar days, team bandwidth). Commit to what fits. Label the rest as stretch. Show the math in the plan.

### DoD Is Constant, Acceptance Criteria Come from /refine

**Practice:** Sprint plans never restate Definition of Done criteria. Sprint exit criteria are sprint-level concerns (review, retro, artifacts updated). Story acceptance criteria emerge from /refine.

**Why:** Sprint 2's exit criteria section was 20 items mixing DoD restated, story-level acceptance criteria, and process enforcement gates. This conflated three different concerns, created drift risk, and pre-decided /refine outcomes. Analysis showed 11 items were DoD, 9 were story AC, and 0 were actually sprint-specific.

**How to apply:** Sprint plan references DoD once ("all stories must meet DoD"). Sprint exit criteria contain only: sprint review completed, sprint retro completed, artifacts updated, all committed stories meet DoD + their acceptance criteria. Nothing else. Story-level acceptance criteria live in the story's refinement output, not the sprint plan.

### Commit Per Story, Not Per Sprint

**Practice:** Commit after each story goes green, with the story ID in the commit message. Monolithic sprint-level commits are forbidden.

**Why:** Sprint 2 was a single 288-file, 53K-line commit. This made PR review impossible (GitHub times out on large diffs), broke git bisect (can't isolate which story introduced a bug), lost the "why" (one commit message for 16 stories), and blocked cherry-picking individual fixes.

**How to apply:** SM calls the commit point after each story's cross-review and code review pass. Commit message format: `type(scope): description (story-id)`. SM blocks accumulation across stories.

---

## Refinement (Added: Sprint 2 Retro)

### Never Skip /refine — Concrete Evidence

**Practice:** Every story goes through three-amigos refinement (Igor scenarios + Paul testability + Dmitri feasibility) before implementation. No "feels obvious" exceptions.

**Why:** Sprint 2 reinforced the Sprint 1 lesson with concrete evidence. TD.8 (Scenario Evidence Drill-Down) and TD.9 (Requirements Coverage Matrix) skipped /refine. The user flagged it. Retroactive validation against the Gherkin scenarios found three functional gaps: collapsible error trace missing, Failing status badge not handled, and partial "X of Y" coverage text incomplete. 15 minutes of refinement would have caught all three before implementation.

**How to apply:** SM blocks /design and /test-and-develop until /refine is recorded. Igor's scenarios, Paul's test strategy, and Dmitri's feasibility assessment must all exist. If someone says "this is obvious, let's skip it" — that's the signal to run it, not skip it.

### Cross-Review During /refine, Not After

**Practice:** Igor, Paul, and Dmitri cross-review each other's work during /refine (before implementation), not just at the exit gate.

**Why:** For platform stories (2.1-2.4), cross-review during refinement caught issues early — zero requirement rework. For dashboard stories (TD.8/TD.9), review happened after implementation. By then, functional gaps were baked in and became rework. Late review is damage assessment; early review is prevention.

**How to apply:** SM blocks Dmitri's implementation until Igor's scenarios AND Paul's test strategy both exist and are cross-reviewed by all three. Cross-review at exit remains (DoD #11) but the high-value review is the early one.

---

## Testing (Added: Sprint 2 Retro)

### Test Evidence Pipeline Is Production Code

**Practice:** Test reporters, aggregation scripts, and dashboard JSON generation are treated as production code — they get 100% coverage, they fail loudly on invalid state, and they are never left with TODO stubs.

**Why:** Sprint 2's reporters had TODO comments where GWT extraction should be (empty arrays for givenSteps/whenSteps/thenSteps). The aggregation script silently reported 0% coverage when coverage files were missing instead of failing. The dashboard showed 527 tests when the actual count was 665. The test evidence dashboard's thesis is "trust through transparency" — serving inaccurate data undermines that thesis completely.

**How to apply:** Reporter and aggregation code goes through /refine and /test-and-develop like any other story. Aggregation scripts must exit non-zero on missing or stale data. No silent defaults (0% is never an acceptable fallback for missing coverage). Regenerate dashboard JSON as part of sprint close, and verify counts match `npm run test:all`.

### Challenge Test Growth Rate

**Practice:** When test count grows faster than scenario count, SM asks "what behavior does this test validate?" not just "did coverage go up?"

**Why:** Sprint 2 grew from 242 to 665 tests (2.7x) for ~160 scenarios (4.15 tests per scenario average). Some growth is legitimate (unit + integration + acceptance layers). But rapid growth driven by coverage targets risks padding — tests that exercise lines without validating behavior. Tests that test mocks instead of behavior create false confidence.

**How to apply:** During cross-review, Paul explains what each test validates in behavior terms. "This test proves that when a member switches profiles, the composition service returns different spokes" — good. "This test imports the module to cover the import line" — challenge it. SM flags test-to-scenario ratios above 5:1 for review.

---

## Architecture (Added: Sprint 2 Retro)

### Service Size Gate

**Practice:** Production service classes stay under 200 lines. Multi-concern services are decomposed before merge, not deferred.

**Why:** Sprint 2's CompositionService grew to 340 lines coupling data aggregation, entitlement-based authorization, and HIPAA consent verification. Each concern has different change drivers (new data sources, new entitlement rules, new consent requirements). Coupling them means every change touches one large file with high blast radius.

**How to apply:** During /design, Dmitri identifies responsibility boundaries. If a class will exceed 200 lines, split it during the same story. Constructor injection makes decomposition straightforward. DoD #9 enforces the gate — SM checks post-implementation and blocks commit if exceeded.

### Browser-Verify Before Demo-Ready

**Practice:** Any user-visible flow must be verified in a running browser with Docker services, not just by code-level tests. "Code tests pass" and "it works in the browser" are different claims.

**Why:** Sprint 2's three demo moments (CMS edit, context toggle, registration-to-dashboard) passed all code-level tests but were never run in an actual browser with Docker services. "It should work" was the evidence level going into a $7.56M demo. Code tests prove individual pieces work; browser verification proves the integration works as a system.

**How to apply:** DoD #6 requires browser smoke test for UI stories. During /design, the team identifies which flows need browser verification. Story 3.6 pattern: run Docker stack, walk through the flow, fix what breaks, capture evidence. Never declare "demo-ready" without browser evidence.

---

## Domain Language (Added: Sprint 2 Retro)

### Maintain a Living Glossary

**Practice:** Maintain `docs/discovery/glossary.md` with canonical domain terms. All scenarios, code, and documentation use glossary-consistent terminology.

**Why:** Sprint 2 had no formal glossary. Life Insurance references persisted in the traceability manifest despite "Dental, LTD, STD only" scope. Domain terms drifted across sprints without a single source of truth. An evaluator reading the traceability matrix would see scope confusion.

**How to apply:** SM creates the glossary during /initiate or first /refine. Igor flags new terms during refinement. The glossary includes a "superseded terms" section (deny list) for terms that should not appear. DoR #16 checks glossary alignment before a story enters implementation.

### Scope Alignment on Every Story

**Practice:** Every story traces to an in-scope product line. Out-of-scope references are either removed or explicitly annotated with rationale.

**Why:** The engagement scope was "Dental, LTD, STD" but Life Insurance references survived multiple sprints because no one checked story-level scope alignment. The traceability manifest — the artifact evaluators inspect most closely — contained contradictory scope signals.

**How to apply:** DoR #17 requires scope alignment verification. During /refine, Igor confirms the story maps to an in-scope product line. During cross-review, Igor sweeps for out-of-scope terminology. If an out-of-scope reference is legitimate (e.g., RFP context), it gets an explicit annotation explaining why it's there.

---

## Sprint Execution (Added: Sprint 3 Retro)

### Smoke Tests as Parallel Track

**Practice:** Establish smoke test infrastructure early in the sprint. Add smoke tests incrementally as features land. Do not sequence all smoke tests as a single final story.

**Why:** Sprint 3 story 3.6 was final, meaning other stories were "done" before browser verification. If smoke tests had caught a breaking issue, stories would need reopening.

**How to apply:** SM plans smoke test infrastructure in Phase 1 of the sprint. Paul adds smoke test specs as each feature goes green. Final sprint day is for gap-filling, not first-time smoke testing.

### Resolve Chronic Deferrals

**Practice:** Items deferred from 2+ consecutive sprints must be either committed to the current sprint or explicitly rejected with documented rationale. No more "stretch-and-defer."

**Why:** Sprint 3 had 3 items (P-5 mockTestResults, D-4 composition caching, TC-4 dashboard JSON regen) that were deferred from Sprint 2 to Sprint 3 and partially deferred again. Chronic deferral creates permanent tech debt by inertia rather than by decision.

**How to apply:** SM reviews the backlog at sprint planning. Any item with 2+ sprint deferrals is flagged. User decides: commit or reject. "Stretch" is not an option for chronic deferrals.

---

## Testing (Added: EOB-1 Retro)

### Verify Tests in Actual Runner Before Reporting

**Practice:** The test author must run tests in the project's actual test runner (Vitest, Jest, Playwright) and provide runner output as evidence before reporting test results to the team. "I wrote the tests" is not equivalent to "the tests pass."

**Why:** EOB-1 delivery included 49 frontend tests reported as 82% passing. When the User ran them, ALL 49 failed -- tests were in the wrong directory (invisible to the runner), missing required wrappers (RouterTestWrapper), and had 9 assertion bugs. The gap between "written" and "verified running" cost a full rework cycle and damaged trust. A memory item ("verify tests actually run") existed but was not encoded as a gate, so it did not prevent recurrence.

**How to apply:** After writing tests, run the relevant package test command (e.g., `npm run test:frontend`). Verify the runner discovers and executes the new tests. Report the actual pass/fail count from the runner output. SM does not accept test deliverables without runner evidence. If the runner reports 0 tests found for new test files, that is a red flag -- check file placement and naming conventions. Memory items are reminders; DoD criteria are gates. Encode critical lessons as gates, not just reminders.

### Document Test Infrastructure Conventions Per Package

**Practice:** Maintain a "Test Infrastructure" section in `docs/engagement/codebase-patterns.md` documenting: test file location conventions, required test wrappers, common assertion patterns, and test run commands for each package.

**Why:** EOB-1 tests failed because the test author did not know (or did not check) that frontend tests must live in `__tests__/` subdirectories and must use `RouterTestWrapper`. These conventions existed in the codebase but were not documented -- they were tribal knowledge from Sprint 1/3 implementation.

**How to apply:** When a test infrastructure pattern is established (wrapper, directory convention, fixture factory), document it in `docs/engagement/codebase-patterns.md` immediately. During /refine, Paul references this document when planning test strategy. SM checks that the planned test approach aligns with documented conventions.
