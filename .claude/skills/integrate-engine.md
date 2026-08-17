---
name: integrate-engine
description: Commercial library/engine integration loop — map domain to library, build adapter layer, write contract tests that verify YOUR expectations of the library's behavior. For Bryntum, Temporal, Cerbos, Stripe, Auth0, or any licensed SDK.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /integrate-engine — Commercial Library Integration Loop

The **Integrate Engine** loop is for wrapping a commercial library or engine into your application. This is fundamentally different from writing new code — you're bridging someone else's domain model to yours, building an adapter that isolates your code from the library's internals, and writing contract tests that verify YOUR assumptions about the library's behavior.

Use this when integrating: scheduling engines (Bryntum), workflow engines (Temporal), policy engines (Cerbos/OPA), payment providers (Stripe), auth providers (Auth0/Cognito), analytics SDKs (ThoughtSpot), or any significant third-party dependency.

## Context Check (Before Starting)

Before starting an integration, verify:
- `docs/engagement/codebase-patterns.md` — Existing patterns, dependency injection approach, module structure
- Library documentation — Official docs, API reference, examples (fetch/bookmark before starting)
- License terms — Commercial license procured? Open source? What are the redistribution/usage constraints?
- Domain model — From `/design` output: what are OUR concepts that need to map to this library?

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Domain mapper** | Igor | Maps our ubiquitous language to library concepts; documents divergence |
| **Implementer** | Dmitri | Builds adapter layer, configuration, error handling at boundary |
| **Contract tester** | Paul | Tests OUR expectations of the library — not the library itself |
| **Navigator** | User | Validates mapping correctness, approves adapter surface |

## Integration Contract (Entry Criteria)

Every integration starts with:

```
Library:          [Name + version (e.g., Bryntum Gantt 6.x, Temporal SDK 1.x)]
Purpose:          [What capability does it provide to our system?]
Domain concepts:  [Our concepts that need to map to the library]
Library concepts: [The library's model we'll interact with]
Divergence:       [Where our model and the library's model don't align]
Constraints:      [License terms, deployment requirements, performance targets]
Boundary:         [Where does our code end and the library begin?]
```

## The Loop

```
┌─────────────────────────────────────────────────────────────┐
│  1. DOMAIN MAPPING (Igor)                                   │
│     Map our concepts → library concepts                     │
│     Document divergences explicitly                         │
│     User approves: "This mapping is correct"                │
│                                                             │
│  2. ADAPTER DESIGN (Dmitri)                                 │
│     Define adapter interface (our types, our methods)       │
│     Library imports ONLY inside adapter implementation      │
│     Configuration externalized (env vars, config files)     │
│     Error translation (library errors → our error types)    │
│     User approves: "This boundary is clean"                 │
│                                                             │
│  3. CONTRACT TESTS (Paul)                                   │
│     Tests verify OUR expectations of the library            │
│     Boundary tests at claimed limits                        │
│     Upgrade safety tests (catch breaking changes)           │
│     User approves: "These cover our actual usage"           │
│                                                             │
│  4. IMPLEMENTATION (Dmitri + Paul pairing)                  │
│     Implement adapter against contract tests (TDD)          │
│     Configuration wiring                                    │
│     Integration test against real library instance          │
│     User approves: "This works for our use case"            │
│                                                             │
│  5. VALIDATION                                              │
│     Verify no library types leaked into domain layer        │
│     Verify adapter is the ONLY import point                 │
│     Verify contract tests run in CI                         │
│     Verify license compliance documented                    │
└─────────────────────────────────────────────────────────────┘
```

## Step Detail

### 1. Domain Mapping (Igor)

Igor produces a mapping table:

```markdown
| Our Concept | Library Concept | Notes / Divergence |
|---|---|---|
| Task | SchedulerEvent | Library calls everything an "event" not "task" |
| Template | Project (static) | Library has no template concept — we model as a project that gets cloned |
| Dependency | DependencyModel | 1:1 mapping, same semantics |
| Calendar | CalendarModel | Library supports all our calendar types |
| Constraint | ConstraintType enum | Direct mapping (ASAP, ALAP, MSO, MFO, SNET, SNLT, FNET, FNLT) |
| ... | ... | ... |
```

**Divergence handling:** For every divergence, Igor documents:
- What our model needs that the library doesn't natively support
- Proposed resolution (adapter logic, workaround, or feature we build ourselves)
- Risk level (low = trivial adapter logic, high = fighting the library)

### 2. Adapter Design (Dmitri)

The adapter is the ONLY seam between our code and the library:

```
┌──────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│   Domain Layer       │     │   Adapter Layer      │     │   Library            │
│   (our types,        │────▶│   (translates)       │────▶│   (their types,      │
│    our interfaces)   │     │                      │     │    their APIs)       │
│                      │◀────│                      │◀────│                      │
│   NEVER imports      │     │   ONLY place that    │     │   Treated as         │
│   library types      │     │   imports library    │     │   black box          │
└──────────────────────┘     └──────────────────────┘     └──────────────────────┘
```

**Adapter responsibilities:**
- Type translation (our types ↔ library types)
- Configuration (how the library is initialized, licensed, connected)
- Error translation (library exceptions → our error hierarchy)
- Lifecycle management (startup, shutdown, health check)
- Performance boundary (timeouts, circuit breakers if appropriate)

**Dmitri defines the adapter interface using OUR types:**

```typescript
// This interface uses ONLY our domain types — no library imports
interface SchedulingEngine {
  calculateSchedule(project: OurProject): ScheduleResult;
  recalculateIncremental(project: OurProject, changedTask: OurTask): ScheduleResult;
  whatIf(project: OurProject, changes: ScheduleChange[]): ScenarioResult;
}
```

### 3. Contract Tests (Paul)

Contract tests verify OUR expectations — they don't test the library's internals:

**What contract tests ARE:**
- "When I give the library X, I expect Y back"
- "At N items, the library responds within T milliseconds"
- "When the library encounters an error, it throws/returns Z"
- "These specific API methods exist and accept these parameters"

**What contract tests are NOT:**
- Unit tests of the library's internal logic
- Tests of scenarios we'll never encounter
- Performance benchmarks (use `/benchmark` for that)

**Three categories:**

```
1. BEHAVIOR CONTRACTS
   "Given [our input mapped to library format],
    When [library operation invoked],
    Then [output maps back to our expected result]"

2. BOUNDARY CONTRACTS
   "Given [input at library's claimed limit (e.g., 100K items)],
    When [operation invoked],
    Then [completes without error within acceptable time]"

3. UPGRADE SAFETY CONTRACTS
   "Given [we depend on this specific behavior],
    When [library is updated to next minor/major version],
    Then [this test catches any breaking change in behavior we rely on]"
```

**Upgrade safety is critical:** When the library releases a new version, these tests tell you immediately whether your integration still works — before you deploy to production.

### 4. Implementation (Dmitri + Paul pairing)

Standard TDD pairing against the contract tests:
- Paul's contract tests are RED (adapter not implemented yet)
- Dmitri implements adapter until GREEN
- Refactor for clarity
- Integration test against real library instance (not mocked)

### 5. Validation Checklist

Before exiting the loop:

```
□ No library types imported outside adapter layer (grep/lint enforced)
□ Adapter interface uses only domain types
□ Contract tests run in CI pipeline
□ Contract tests cover: behavior, boundaries, upgrade safety
□ Configuration externalized (no hardcoded library config)
□ Error handling at boundary (library errors don't leak)
□ License compliance documented in docs/engagement/
□ Health check includes library status
□ README/ADR documents why this library, version pinned, upgrade path
```

## Integration Types (Guidance by Category)

### Scheduling Engine (Bryntum, DHTMLX)
- Map: Tasks → Events, Dependencies → Links, Calendars → CalendarModels
- Key adapter concern: incremental recalculation API, constraint type support
- Key contract: performance at target task count, correctness of CPM calculation
- Watch for: reactive graph lifecycle, memory management at scale

### Workflow Engine (Temporal, Step Functions)
- Map: Use cases → Workflows, Steps → Activities, Events → Signals
- Key adapter concern: workflow definition registration, signal handling, query interface
- Key contract: durability (workflow survives restart), determinism (replay safety)
- Watch for: versioning strategy, worker deployment, testing with test server

### Policy Engine (Cerbos, OPA, Cedar)
- Map: Roles → Principals, Resources → Resources, Actions → Actions, Rules → Policies
- Key adapter concern: policy loading, decision caching, audit logging
- Key contract: given [principal + resource + action] → allow/deny matches expectation
- Watch for: policy update propagation, performance under load, deny-by-default

### Payment Provider (Stripe, Adyen)
- Map: Orders → PaymentIntents, Customers → Customers, Events → Webhooks
- Key adapter concern: idempotency, webhook verification, PCI scope
- Key contract: charge succeeds, refund succeeds, webhook signature valid
- Watch for: test mode vs live mode, webhook replay, currency handling

### Auth Provider (Auth0, Cognito, Azure AD)
- Map: Users → Identities, Roles → Groups/Scopes, Sessions → Tokens
- Key adapter concern: token validation, refresh flow, SSO configuration
- Key contract: valid token → identity extracted, expired token → rejection
- Watch for: token rotation, logout propagation, multi-tenant isolation

### Analytics SDK (ThoughtSpot, Looker, Metabase)
- Map: Views → Dashboards, Filters → Parameters, Data → Connections
- Key adapter concern: embedding authentication, filter passing, responsive sizing
- Key contract: embed loads with correct context, filters apply, SSO works
- Watch for: CSP headers, iframe security, mobile responsiveness

## Rules

- **Adapter is the ONLY seam** — if you grep the codebase for library imports and find them outside the adapter module, something is wrong
- **Domain layer is pure** — domain logic never references library types, even transitively
- **Contract tests run in CI** — every build verifies the library still behaves as expected
- **License compliance** — documented, reviewed, terms respected (redistribution, attribution, usage limits)
- **Version pinned** — exact version in lockfile; upgrades are deliberate, tested, not accidental
- **Fallback plan documented** — what happens if the library is EOL'd, acquired, or breaks? Can we swap the adapter implementation without touching domain code? (This is WHY the adapter exists)

## Outputs

```
backlog/active/<feature-slug>/
  integration-design.md     — Domain mapping table + adapter interface + divergence notes
  contract-tests/           — Test suite (behavior + boundary + upgrade safety)
  adapter/                  — Implementation (the only place that imports the library)

docs/decisions/
  adr-<slug>.md             — Why this library, alternatives considered, upgrade path
```

## Invocation

```bash
/integrate-engine "Integrate Bryntum Gantt as the scheduling engine"
/integrate-engine "Add Temporal.io for workflow orchestration"
/integrate-engine "Wire up Cerbos as the policy decision point"
/integrate-engine "Integrate ThoughtSpot embedded analytics"
```
