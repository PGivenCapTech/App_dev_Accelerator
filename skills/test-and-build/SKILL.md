---
name: test-and-build
description: Team skill — Paul builds tests first (harness, data, skeletons), Dmitri implements against them. SM enforces traceability + 100% coverage throughout.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /test-and-build — Test-First Development (Team Skill)

The **TestAndBuild** skill is executed by Paul and Dmitri together, with SM enforcing quality gates. Paul builds test infrastructure first, then Dmitri implements production code that makes the tests pass. Traceability and 100% coverage are enforced throughout.

## Who Participates

| Agent | Role in TestAndBuild |
|---|---|
| **Paul** | LEADS FIRST: test harness, data factories, step skeletons, unit test stubs |
| **Dmitri** | FOLLOWS: implements production code that makes Paul's tests pass |
| **SM** | Enforces: traceability matrix updated, coverage at 100%, no orphan code |
| **Igor** | On-call: adjusts scenarios if Paul/Dmitri discover issues |

## Prerequisites

- `/plan` completed with user approval
- `backlog/active/<slug>/requirement.md` exists (Igor's feature file)
- `backlog/active/<slug>/tests.md` exists (Paul's test strategy)

## The Process

### Phase 1: Paul Builds Test Infrastructure (FIRST)

Paul creates all test artifacts before Dmitri writes any production code:

**1a. Test Harness Setup** (if new infrastructure needed)
- Framework configuration
- Base test classes
- Test database setup/teardown
- API test client
- Event capture/spy infrastructure

**1b. Test Data Factories**
- Builder factories for domain aggregates in this feature
- Realistic domain-appropriate test data
- Fixture sets for scenarios (empty, populated, edge states)

**1c. Step Definition Skeletons** (failing tests — the contract)
- One class per feature area
- Method signatures matching Igor's Gherkin steps
- Bodies: `throw PendingException()` or equivalent
- Event assertion helpers pre-wired

**1d. Unit Test Stubs**
- Test class per production class that will exist
- Test methods for every public method that will exist
- Bodies: `fail("Not yet implemented")` or equivalent
- These define the production API contract

**1e. Integration Test Skeletons**
- API-level tests matching scenarios
- Database integration tests
- Event publishing verification tests

**Deliverable:** A failing test suite that defines the complete contract Dmitri must satisfy.

### Phase 2: Dmitri Implements (Against Paul's Tests)

Dmitri writes production code with one goal: **make Paul's tests pass**.

**2a. Domain Model**
- Entities, aggregates, value objects
- Must match Paul's data factory shapes

**2b. Service Layer**
- Business logic satisfying Igor's scenarios
- Domain event publishing
- Must pass Paul's step definitions

**2c. API Layer**
- Controllers/handlers
- Must pass Paul's integration tests

**2d. Infrastructure**
- Repositories, event publishers, external integrations
- Must pass Paul's unit tests

**Constraint:** Every commit Dmitri makes should turn at least one test from red to green.

### Phase 3: Paul Completes (After Dmitri's Code Exists)

**3a. Fill Unit Tests**
- Now that production code exists, Paul writes comprehensive unit tests
- 100% line coverage
- 100% branch coverage
- Edge cases, null handling, boundary conditions

**3b. NFR Tests**
- Performance benchmarks
- Security checks
- Data integrity assertions

**3c. Regression Run**
- Full suite (all features, not just current)
- No regressions from previous iterations

### Phase 4: SM Verifies Gates (Continuous)

SM checks throughout (not just at the end):

```
After Phase 1:  "Paul's skeletons ready. Contract defined. Dmitri, begin."
During Phase 2: "Dmitri has N/M tests green. Coverage at X%. Trace at Y%."
After Phase 2:  "All skeletons pass. Paul, complete unit tests + NFRs."
After Phase 3:  "Full verification:"
                □ All BDD scenarios pass
                □ All integration tests pass  
                □ All unit tests pass
                □ Coverage = 100%
                □ Traceability = 100% (every scenario → test → code)
                □ No orphan code
                □ No regressions
```

If any gate fails → SM identifies the gap and assigns the fix before proceeding.

### Phase 5: Traceability Matrix Complete

SM verifies `backlog/active/<slug>/traceability.md` is filled:

```markdown
| Requirement (Scenario) | Step Def | Integration Test | Unit Tests | Code |
|---|---|---|---|---|
| Scenario: X | XSteps:L14 | XIT:L23 | XServiceTest:L45,L67 | XService:L23 |
```

Every cell must be filled. Every code file must appear. No gaps = ready for `/deploy`.

## Outputs

After `/test-and-build` completes:

```
src/test/           — Complete test suite (Paul)
src/main/           — Production code (Dmitri)
backlog/active/<slug>/
  traceability.md   — 100% complete
  status.md         — "built — all gates pass"
Coverage report     — 100% line + branch
```

## Invocation

```
/test-and-build                    — Execute for current active iteration
/test-and-build <feature-slug>     — Execute for specific feature
/test-and-build --status           — Show current progress (tests green, coverage %)
```
