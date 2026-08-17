---
name: design-event-integration
description: Event-driven integration design loop — topology, event contracts, failure handling, idempotency, and schema evolution for EventBridge, Kafka, SNS/SQS, or similar.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /design-event-integration — Event-Driven Integration Design Loop

The **Design Event Integration** loop designs the event-driven communication between systems. Event-driven integration has fundamentally different concerns than REST API calls: ordering, idempotency, dead letters, schema evolution, fan-out, filtering, and eventual consistency. This loop produces a complete integration design with contracts, failure handling, and test coverage.

## Context Check (Before Starting)

Before starting, verify:
- `docs/engagement/systems-of-record.md` — Integration targets identified (producers + consumers)
- Feature or system `/design` output — Data contracts and domain events already modeled
- `docs/engagement/environments.md` — Event bus technology chosen (EventBridge, Kafka, SNS/SQS, Azure Service Bus)

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Infrastructure + Implementation** | Dmitri | Builds bus config, producers, consumers, monitoring |
| **Event contracts + scenarios** | Igor | Defines event schemas, writes integration scenarios in Gherkin |
| **Failure scenarios + testing** | Paul | Validates idempotency, ordering, DLQ behavior, schema compat |
| **Navigator** | User | Approves event topology, delivery guarantees, failure policies |

## Integration Contract (Entry Criteria)

Every event integration design starts with:

```
Producer(s):       [Systems that emit events]
Consumer(s):       [Systems that react to events]
Event Bus:         [Technology — EventBridge / Kafka / SNS+SQS / Azure Service Bus]
Ordering:          [Required? Partition key strategy? Or unordered acceptable?]
Delivery:          [At-least-once (default) / Exactly-once (if supported)]
Schema Strategy:   [JSON Schema / Avro / Protobuf — versioning approach]
Volume:            [Expected events/day — normal and peak]
Latency:           [Acceptable end-to-end delay — seconds? minutes?]
```

## The Loop

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Define Event Contracts                                      │
│     Igor models:                                                │
│     - Event catalog (name, schema, producer, consumers)         │
│     - Topology diagram (producer → bus → consumers)             │
│     - Filtering rules (which consumers see which events)        │
│     - Ordering guarantees (partition key or unordered)           │
│     - Schema versioning (major/minor, compatibility rules)      │
│                                                                 │
│     Events are FACTS — past tense naming:                       │
│       TaskCompleted, TemplatePublished, PropertyConfigured      │
│                                                                 │
│     User approves: "This topology is correct"                   │
│                                                                 │
│  2. Design Failure Handling                                     │
│     Paul + Dmitri model:                                        │
│     - Dead letter queues: what happens on delivery failure      │
│     - Retry policies: backoff, max attempts, circuit breaker    │
│     - Idempotency: how consumers handle duplicate delivery      │
│     - Poison messages: events that can never process            │
│     - Alerting: who gets notified, when, how                    │
│                                                                 │
│     User approves: "These failure policies are acceptable"      │
│                                                                 │
│  3. Igor Writes Integration Scenarios (Gherkin)                 │
│                                                                 │
│     Happy path:                                                 │
│       Given [event published by producer]                       │
│       When [consumer processes the event]                       │
│       Then [state updated correctly]                            │
│                                                                 │
│     Consumer unavailable:                                       │
│       Given [consumer is down]                                  │
│       When [event is published]                                 │
│       Then [event queued, delivered when consumer recovers]     │
│                                                                 │
│     Duplicate delivery:                                         │
│       Given [event already processed (idempotency key exists)]  │
│       When [same event delivered again]                         │
│       Then [no side effects, no duplicate state change]         │
│                                                                 │
│     Schema evolution:                                           │
│       Given [producer publishes event with schema v2]           │
│       When [consumer running schema v1 receives it]             │
│       Then [consumer handles gracefully (ignores new fields)]   │
│                                                                 │
│     Poison message:                                             │
│       Given [malformed event or unprocessable payload]          │
│       When [max retry attempts exceeded]                        │
│       Then [event moved to DLQ, alert fired, no data loss]     │
│                                                                 │
│     Ordering violation:                                         │
│       Given [events A then B published in order]                │
│       When [consumer receives B before A]                       │
│       Then [handled correctly — either reorder or tolerate]     │
│                                                                 │
│  4. Paul Tests                                                  │
│     - Delivery guarantees under failure (kill consumer mid-batch)│
│     - Ordering violations (do they cause incorrect state?)      │
│     - Throughput at expected volume AND 10x peak                │
│     - DLQ monitoring fires alerts correctly                     │
│     - Schema compatibility: add field (backward), remove field  │
│       (forward) — verify consumers handle both                  │
│     - Idempotency under concurrent duplicate delivery           │
│                                                                 │
│  5. Dmitri Implements                                           │
│     - Event schemas (versioned, registered in schema registry   │
│       if available)                                             │
│     - Bus configuration (rules, filters, DLQ, retry policies)  │
│     - Producer library:                                         │
│       • Publish with correlation ID + timestamp + source        │
│       • Schema validation before publish                        │
│       • Retry on bus unavailability                             │
│     - Consumer library:                                         │
│       • Idempotent handler pattern (check before process)       │
│       • Structured error handling (retryable vs terminal)       │
│       • Metrics emission (processed, failed, latency)           │
│     - Monitoring:                                               │
│       • Event lag (time from publish to process)                │
│       • DLQ depth (alert on non-zero)                           │
│       • Processing error rate                                   │
│       • Consumer throughput vs publish rate                     │
│                                                                 │
│  6. User Validates                                              │
│     □ Topology matches system reality                           │
│     □ Failure policies are acceptable for the business          │
│     □ Monitoring covers all failure modes                       │
│     □ Schema evolution plan won't break consumers               │
└─────────────────────────────────────────────────────────────────┘
```

## Integration Patterns

| Pattern | When to Use | Example |
|---|---|---|
| **Fire-and-forget** | Producer doesn't need to know if consumer succeeded | Task completed → analytics event to Snowflake |
| **Request-reply over events** | Async request with correlation ID, response on separate topic | HOT requests property status → OPERA replies with config status |
| **Saga coordination** | Events trigger workflow steps across services | Template published → sync event → each project evaluates → applies or skips |
| **Event sourcing** | Events are the source of truth, state derived | All task state changes as events → rebuild project state from event log |
| **CDC (Change Data Capture)** | Database changes published as events | PostgreSQL → Debezium → EventBridge → Snowflake (real-time warehouse sync) |
| **Fan-out** | One event, multiple independent consumers | ProjectMilestoneReached → notify teams + update dashboard + trigger next phase |

## Event Schema Standards

### Envelope (Required on Every Event)

```json
{
  "id": "uuid-v4",
  "source": "hot-platform/scheduling-service",
  "type": "com.hyatt.hot.TaskCompleted",
  "specversion": "1.0",
  "time": "2026-08-17T14:30:00Z",
  "datacontenttype": "application/json",
  "correlationId": "uuid-v4 (traces back to originating action)",
  "schemaVersion": "1.2.0",
  "data": { ... }
}
```

Use CloudEvents spec where possible — portable across bus technologies.

### Schema Compatibility Rules

| Change | Backward Compatible? | Forward Compatible? | Allowed? |
|---|---|---|---|
| Add optional field | ✅ | ✅ | Always |
| Add required field | ❌ | ✅ | Only with new event type version |
| Remove field | ✅ | ❌ | Deprecate first, remove after all consumers updated |
| Rename field | ❌ | ❌ | Never — add new, deprecate old |
| Change field type | ❌ | ❌ | Never — new event type |

## Rules

- **Events are facts** — past tense naming: `TaskCompleted`, `TemplatePublished`, `PropertyConfigured`. Never imperative (`CompleteTask`).
- **Schema must be backward-compatible** — add fields freely, never remove or rename without versioning.
- **Every consumer must be idempotent** — duplicate delivery is a feature of at-least-once systems, not a bug.
- **DLQ must be monitored and alerted** — a growing DLQ is silent data loss. Non-zero depth = investigation.
- **Never rely on ordering unless explicitly guaranteed** — if ordering matters, use partition keys and document why.
- **Correlation ID on every event** — traces a business action across multiple events and services.
- **No business logic in the bus** — filtering and routing only. Transform in the consumer.
- **Test with the bus, not mocks** — integration tests use LocalStack / testcontainers / embedded bus. Mocking the bus hides real failure modes.

## Outputs

```
docs/integration/
  event-topology.md          — Diagram: producers → bus → consumers
  event-catalog.md           — All events: name, schema, producer, consumers, SLA
  failure-handling.md        — DLQ policies, retry config, alerting thresholds
  schema-registry.md         — Versioned schemas, compatibility guarantees
src/
  events/schemas/            — Event schema definitions (JSON Schema / Avro)
  events/producers/          — Producer implementations (publish + validate)
  events/consumers/          — Consumer implementations (idempotent handler)
  events/monitoring/         — Metrics, alerts, DLQ watchers
tests/
  integration/events/        — Integration tests (real bus, real failure modes)
  contract/events/           — Schema compatibility tests
```

## Invocation

```bash
# Design integration between HOT and external systems
/design-event-integration "HOT task completion events to ServiceNow and Snowflake"

# Design internal event-driven communication
/design-event-integration "Template publish triggers sync workflows for all active projects"

# Design CDC pipeline
/design-event-integration "Real-time project data sync from PostgreSQL to Snowflake via CDC"

# Review existing event integration
/design-event-integration --review "Audit the current EventBridge topology for failure gaps"
```
