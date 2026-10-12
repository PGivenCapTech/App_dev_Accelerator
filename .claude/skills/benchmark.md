---
name: benchmark
description: Benchmark loop — structured quantitative performance validation against defined thresholds. Produces measurements and a verdict, not opinions.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /benchmark — Benchmark Loop (Performance Validation)

The **Benchmark** loop is a structured performance investigation that answers "does this meet our quantitative targets?" It produces **measurements, a degradation profile, and a go/no-go verdict** — not production code. Benchmarks are created during `/refine` or `/spike` when performance is the primary unknown.

Different from `/spike`: a spike answers yes/no to a hypothesis. A benchmark answers **how much, how fast, at what scale, and where does it break.**

## Context Check (Before Starting)

Before starting a benchmark, verify:
- `docs/engagement/environments.md` — Where will the benchmark run? (local Docker, cloud instance, dedicated load-test environment)
- `docs/engagement/codebase-patterns.md` — Existing performance tooling (k6, Artillery, JMeter, custom harness)
- `docs/engagement/observability.md` — How to capture metrics (OpenTelemetry, CloudWatch, Prometheus)

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Harness builder** | Dmitri | Builds reproducible benchmark harness, instruments measurement |
| **Scenario designer** | Paul | Defines scenarios, thresholds, kill criteria, validates measurement methodology |
| **Navigator** | User | Approves targets, reviews results, makes go/no-go call |

## Benchmark Contract (Entry Criteria)

Every benchmark starts with a contract — approved by User before measurement begins:

```
Component:       [What's being measured — engine, API, query, workflow]
Scenarios:       [Specific operations under specific conditions]
Data Profile:    [Realistic data — volume, shape, distribution. NOT synthetic toy data]
Targets:
  - P50: [target]    — Median user experience
  - P95: [target]    — Tail latency (most users)
  - P99: [target]    — Worst case (acceptable)
Kill Threshold:  [Below this = no-go, regardless of other factors]
Environment:     [Where it runs — hardware, network, containerization]
Duration:        [How long each scenario runs — minimum for statistical significance]
Warm-up:        [Cycles to discard before measurement — JIT, cache priming]
```

**User approves the contract before Dmitri builds anything.** Targets set the bar; kill threshold sets the floor.

## The Loop

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DEFINE — Paul + User agree on contract                      │
│     - What scenarios? (realistic operations, not micro-benchmarks│
│       unless explicitly scoped)                                  │
│     - What targets? (P50/P95/P99 latency, throughput, memory)   │
│     - What kill threshold? (absolute floor — below = no-go)     │
│     - What data profile? (realistic volume + shape)             │
│     User approves: "These are the right targets."               │
│                                                                  │
│  2. INSTRUMENT — Dmitri builds the harness                      │
│     - Data generation (realistic, seeded, reproducible)         │
│     - Measurement instrumentation (not wall-clock — use         │
│       high-resolution timers, percentile collectors)            │
│     - Isolation (no other load, controlled environment)         │
│     - Automation (single command to run full suite)             │
│     - CI integration (can run as part of pipeline)              │
│     Paul reviews: "Methodology is sound?"                       │
│                                                                  │
│  3. MEASURE — Run scenarios, collect data                       │
│     - Warm-up phase (discard first N iterations)                │
│     - Steady-state measurement (minimum duration for            │
│       statistical significance)                                  │
│     - Stress measurement (2x, 5x, 10x target load)             │
│     - Record: raw data, percentiles, resource utilization       │
│                                                                  │
│  4. ANALYZE — Paul evaluates results                            │
│     - Compare to targets (pass/fail per scenario)               │
│     - Identify degradation curve (where does performance bend?) │
│     - Identify bottleneck (CPU? memory? I/O? algorithm?)        │
│     - Statistical confidence (enough samples? stable results?)  │
│                                                                  │
│  5. VERDICT — Present to User                                   │
│     □ PASS — All targets met. Proceed.                          │
│     □ PASS WITH CAVEATS — Targets met under conditions.         │
│       Document constraints.                                      │
│     □ ITERATE — Below targets but bottleneck identified.        │
│       Optimize and re-measure. (Max 2 iterations before         │
│       escalating to architectural review.)                       │
│     □ FAIL — Below kill threshold. Architecture needs rethink.  │
│                                                                  │
│  User decides next step.                                         │
└─────────────────────────────────────────────────────────────────┘
```

## Benchmark Types

### Latency Benchmark
- **Question:** How fast is a single operation?
- **Measures:** P50, P95, P99 response time under defined concurrency
- **Example:** "Full CPM recalculation of 45K tasks with hybrid constraints"

### Throughput Benchmark
- **Question:** How many operations per second can the system handle?
- **Measures:** Operations/second at steady state, degradation under increasing load
- **Example:** "Task status updates per second across 100 concurrent users"

### Scale Ceiling Benchmark
- **Question:** At what data volume does performance degrade unacceptably?
- **Measures:** Target metric (latency, throughput) at increasing data volumes (1x, 2x, 5x, 10x)
- **Example:** "CPM calculation at 10K, 25K, 45K, 100K tasks — find the knee"

### Degradation Profile Benchmark
- **Question:** How does performance degrade as load/volume increases?
- **Measures:** Performance curve from nominal to breaking point
- **Example:** "Incremental recalculation time as dependency depth increases from 5 to 50 levels"

### Resource Benchmark
- **Question:** What resources does the system consume at target scale?
- **Measures:** CPU, memory, disk I/O, network at steady-state load
- **Example:** "Memory footprint of 45K-task project loaded in ChronoGraph engine"

## Rules

- **Realistic data:** Use production-representative data shapes, not uniform synthetic distributions. If production data isn't available, model it (power-law dependencies, clustered assignments, regional calendar variations).
- **Reproducible:** Seeded random generation. Containerized environment. Same command = same results (within statistical variance).
- **CI-runnable:** The benchmark harness must run in CI for regression detection. Thresholds become automated gates.
- **No wall-clock approximation:** Use high-resolution timers (`performance.now()`, `process.hrtime.bigint()`, dedicated profiling). Wall-clock includes GC pauses, scheduling jitter, and other noise.
- **Statistical rigor:** Minimum sample size for percentile stability. Report confidence intervals. Discard warm-up. Identify and flag outliers.
- **Isolated:** No competing workloads during measurement. Dedicated environment or isolated containers with resource limits matching production.
- **Document the environment:** Results are meaningless without hardware context. Record: CPU model, core count, memory, disk type, container limits, OS, runtime version.

## Outputs

```
backlog/benchmarks/<benchmark-slug>/
  contract.md         — Scenarios, targets, kill thresholds (User-approved)
  harness/            — Benchmark code (reproducible, CI-runnable)
  data/               — Generated test data (or generation scripts)
  results/
    raw/              — Raw measurement data (CSV/JSON)
    summary.md        — Percentiles, charts, resource utilization
  report.md           — Verdict + analysis + recommendations
    - Pass/Fail per scenario
    - Degradation curve description
    - Bottleneck identification
    - Recommendations (proceed / optimize / rethink)
  ci-config.yml       — Regression detection configuration (thresholds as gates)
```

## Integration with Other Loops

| From | To | Handoff |
|---|---|---|
| `/refine` | `/benchmark` | "We identified a performance unknown — benchmark it before design" |
| `/spike` | `/benchmark` | "Spike confirmed feasibility — now benchmark to quantify" |
| `/benchmark` | `/design` | "Benchmark passed — proceed to design with known performance envelope" |
| `/benchmark` | `/spike` | "Benchmark failed — spike an alternative approach" |
| `/benchmark` (CI) | `/test-and-develop` | "Regression detected — fix before merge" |

## Invocation

```bash
/benchmark "Can ChronoGraph handle 45K tasks with full CPM in under 5 seconds?"
/benchmark --type scale "Find the task count ceiling for incremental recalculation < 500ms"
/benchmark --type degradation "Profile portal response time from 100 to 5000 concurrent users"
/benchmark --list                  — Show active benchmarks
/benchmark --rerun <slug>          — Re-run existing benchmark (after optimization)
/benchmark --ci <slug>             — Generate CI regression gate from benchmark results
```
