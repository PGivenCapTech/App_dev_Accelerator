---
name: plan
description: Team skill — SM leads iteration planning with Igor. Decomposes backlog, proposes iteration structure, gets user approval, produces feature files + test plans.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /plan — Iteration Planning (Team Skill)

The **Plan** skill is executed by the team together, led by SM with Igor. It takes the next priority items from the backlog and produces an approved iteration plan with feature files and test plans ready for `/test-and-build`.

## Who Participates

| Agent | Role in Planning |
|---|---|
| **SM** | Leads: selects features, proposes structure, manages gates |
| **Igor** | Decomposes backlog items into Gherkin features |
| **Paul** | Reviews testability, proposes test strategy |
| **Dmitri** | Flags feasibility concerns, estimates effort |

## The Process

### Step 1: SM Proposes Iteration

SM reviews `backlog/backlog.md` and proposes:
- Which features to include in this iteration
- Estimated scope (days)
- Dependencies and risks
- Iteration structure (what's parallel, what's sequential)

**>>> GATE: Present to user for approval <<<**

Prompt: "Here's the proposed iteration: [features, structure, estimate]. **Approve, adjust, or reprioritize?**"

### Step 2: Igor Decomposes (after user approves plan)

For each approved feature:
- Read discovery backlog item + Anu's analysis + Archie's architecture
- Decompose into Gherkin scenarios (happy path, edge cases, NFRs)
- Tag with traceability markers
- Write feature files to `src/test/resources/features/`

### Step 3: Paul Proposes Test Strategy (parallel with Igor)

For each approved feature:
- Identify test harness needs (new infrastructure or existing)
- Define data factory requirements
- Outline step definition approach
- Identify NFR thresholds to test against
- Document in `backlog/active/<slug>/tests.md`

### Step 4: Dmitri Reviews Feasibility

- Read Igor's scenarios + Paul's test strategy
- Flag anything technically infeasible
- Propose alternatives if needed
- Confirm effort estimate

### Step 5: SM Presents Iteration Contents

**>>> GATE: Present to user for approval <<<**

Prompt: "Igor has [N] scenarios across [M] features. Paul's test plan: [summary]. Dmitri confirms feasibility. Key decisions: [list]. **Does this match your intent? Approve to start /test-and-build?**"

## Outputs

After `/plan` completes with user approval:

```
backlog/active/<slug>/
  requirement.md      — Igor's feature file (Gherkin)
  tests.md            — Paul's test strategy + harness plan
  implementation.md   — Dmitri's feasibility notes
  traceability.md     — Empty template (filled during /test-and-build)
  status.md           — "planned — approved by user on <date>"
```

## Invocation

```
/plan                          — Plan next iteration (SM selects from backlog)
/plan <feature-slug>           — Plan specific feature
/plan --review                 — Review current iteration plan status
```
