---
name: design-composition
description: Composition engine design loop — model composable units (templates, modules, policies), define selection rules, resolve cross-unit dependencies, and validate before instantiation. For systems where configurable artifacts are conditionally assembled into a coherent whole.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /design-composition — Composition Engine Design Loop

The **Composition** loop designs systems where configurable, composable units are conditionally selected and assembled into a coherent whole. This covers template tree stitching, Terraform module composition, policy bundles, configurable product packages, modular onboarding flows — any domain where "pick the right pieces and wire them together" is the core problem.

## Context Check (Before Starting)

Before starting composition design, verify:
- `docs/engagement/codebase-patterns.md` — Existing composition patterns (don't reinvent)
- Domain model from `/design` or `/ingest` — What are the composable units?
- Selection criteria identified — What attributes drive which units are selected?
- Cross-unit interface points identified — Where do units connect to each other?

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Data model + algorithm** | Archie | Unit schema, resolution algorithm, performance model |
| **Composition scenarios** | Igor | Gherkin scenarios covering selection, wiring, edge cases |
| **Validation + edge cases** | Paul | Stress-tests: maximum, empty, circular, conflicting |
| **Implementation** | Dmitri | Unit model, condition evaluator, resolver, instantiation engine |
| **Approves rules** | User | Confirms composition logic matches business intent |

## Composition Contract (Entry Criteria)

Every composition design starts with:

```
Unit definition:     [What is a composable unit? What's inside it?]
Internal structure:  [Relationships within a unit — e.g., tasks with dependencies]
External interfaces: [What a unit exports for other units to depend on]
Selection criteria:  [What attributes determine which units are chosen]
Resolution method:   [How cross-unit dependencies are wired — explicit, convention, auto]
Instantiation:       [How a composed set becomes a live instance]
```

## The Loop

```
┌─────────────────────────────────────────────────────────────────┐
│  1. MODEL THE COMPOSABLE UNITS (Archie)                         │
│     - Internal structure (what's inside a unit)                  │
│     - External interfaces (exports: what others can depend on)  │
│     - Metadata / attributes (used for selection + wiring)       │
│     - Versioning model (immutable snapshots? mutable drafts?)   │
│     User approves: "This is what a unit looks like"             │
│                                                                 │
│  2. MODEL THE COMPOSITION RULES (Archie + Igor)                 │
│     - Condition evaluation: how are units selected?             │
│       (decision table / rule engine / DSL / attribute matching) │
│     - Cross-unit dependency resolution: how are units wired?    │
│       (explicit wiring / naming convention / auto-detect)       │
│     - Validation: what makes a composition invalid?             │
│       (cycles, unresolved refs, conflicting constraints)        │
│     - Instantiation: how does a composed set become real?       │
│       (clone + wire + calculate dates/assignments)              │
│     User approves: "These rules match how we select + compose"  │
│                                                                 │
│  3. WRITE COMPOSITION SCENARIOS (Igor)                          │
│     Gherkin scenarios covering:                                 │
│     - Happy path: attributes → correct units selected + wired   │
│     - Conflict: overlapping conditions → precedence resolved    │
│     - Update: unit version changes → diff + conflict detection  │
│     - Maximum: all conditions match → all units, no conflicts   │
│     - Empty: no conditions match → error or default behavior    │
│     - Circular: cross-unit deps form a cycle → detected + error │
│     User approves: "These scenarios cover our real cases"       │
│                                                                 │
│  4. STRESS-TEST (Paul)                                          │
│     - Maximum composition (all units selected simultaneously)   │
│     - Empty composition (nothing matches — fail gracefully?)    │
│     - Circular cross-unit dependencies (detection required)     │
│     - Condition conflicts (deterministic resolution required)   │
│     - Performance at scale (100+ units, 1000+ cross-deps)       │
│     - Partial recomposition (one unit updated mid-flight)       │
│     "Does this break under real-world conditions?"              │
│                                                                 │
│  5. IMPLEMENT (Dmitri)                                          │
│     - Unit data model (schema, storage, versioning)             │
│     - Condition evaluator (rule engine or decision table)       │
│     - Dependency resolver (topological sort + cross-unit wiring)│
│     - Instantiation engine (template → live instance)           │
│     - Validation layer (runs before instantiation — fail fast)  │
│     All tests from steps 3-4 pass before moving on.            │
│                                                                 │
│  6. USER VALIDATES                                              │
│     □ Composition logic matches business intent                 │
│     □ Selection rules are auditable (non-technical can review)  │
│     □ Edge cases handled gracefully (not silently swallowed)    │
│     □ Performance acceptable at expected scale                  │
│     □ Proceed to /test-and-develop for full implementation      │
└─────────────────────────────────────────────────────────────────┘
```

## Composition Patterns

Different domains call for different composition shapes:

### Additive (Select and Merge)
Units are independently selected and merged into a flat collection. No hierarchy. Cross-unit dependencies resolved by matching export names.
- **Example:** Feature flags selected based on user segment → merged into active feature set

### Hierarchical (Parent Constrains Child)
Parent units define the boundary; child units are selected within that boundary. Parent attributes propagate down.
- **Example:** Regional template selects from brand-specific sub-templates

### Conditional (Attribute-Driven Selection)
A decision table or rule engine evaluates project attributes against unit conditions. Multiple units can match. Precedence rules handle conflicts.
- **Example:** Hotel attributes (region × brand × type) → template selection

### Override (Base + Specialization)
A base unit provides defaults. Specialized units override specific elements while inheriting the rest.
- **Example:** Base onboarding flow + regional overrides for regulatory steps

### Versioned (Immutable Snapshots with Diff)
Units are immutable once published. New versions are new snapshots. Recomposition of an existing instance requires diff calculation and conflict detection.
- **Example:** Template v3.2 published → existing projects on v3.1 offered the diff

## Rules

- **Deterministic:** Same inputs (attributes + unit library) → same composed output. Every time. No randomness, no ordering sensitivity.
- **Explicit dependencies:** Cross-unit dependencies must be explicitly declared (exports/imports), not inferred from naming or position. Implicit dependencies are invisible bugs.
- **Validate before instantiate:** The composition engine validates the composed graph BEFORE creating live instances. Fail fast. Never create a partial, invalid instance.
- **Immutable publications:** Once a unit version is published, it never mutates. Changes = new version. This is non-negotiable for auditability and diff calculation.
- **Auditable selection:** A non-technical stakeholder must be able to review WHY specific units were selected. Decision tables > opaque rule engines > code.
- **Graceful degradation:** When composition fails (no match, conflict, cycle), the error message must say WHAT failed and WHY — not just "composition failed."

## Outputs

```
backlog/active/<feature-slug>/
  composition-design.md    — Unit model, rule model, resolution algorithm, patterns chosen
  composition.feature      — Gherkin scenarios (selection, wiring, edge cases, failures)
  validation-suite/        — Edge case tests (max, empty, circular, conflict, scale)
  implementation/          — Unit schema, evaluator, resolver, instantiation engine
```

### composition-design.md Structure

```markdown
# Composition Engine Design

## Unit Model
- What is a unit? (schema)
- Internal structure (relationships within)
- External interfaces (exports for cross-unit deps)
- Versioning (immutable snapshots, version numbering)

## Selection Rules
- Input attributes (what drives selection)
- Rule format (decision table / rule engine / DSL)
- Conflict resolution (precedence, merge, error)
- Default behavior (when nothing matches)

## Dependency Resolution
- Cross-unit dependency format (export name → import reference)
- Resolution algorithm (topological sort, multi-pass, lazy)
- Cycle detection (algorithm, error reporting)
- Unresolved reference handling (error / warning / skip)

## Instantiation
- Template → instance transformation
- Date/assignment calculation during instantiation
- Validation gates before instance creation

## Scale Characteristics
- Expected unit count (today, in 2 years)
- Expected cross-unit dependency density
- Expected composition frequency (per hour, per day)
- Performance targets (composition time at scale)
```

## Invocation

```bash
# Design a composition engine for a new domain
/design-composition "Template tree stitching: 164 templates, conditional on region × brand × type, cross-template dependencies"

# Design composition for infrastructure modules
/design-composition "Terraform module composition: base VPC + conditional add-ons based on workload type"

# Design composition for configurable onboarding
/design-composition "Customer onboarding flow: base steps + industry-specific modules + compliance add-ons"

# Redesign/extend an existing composition engine
/design-composition "Add versioned recomposition to existing template engine — diff + conflict detection for in-flight projects"
```
