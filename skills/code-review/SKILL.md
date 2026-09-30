---
name: code-review
description: Code Review loop — request PR review, receive and triage findings, route fixes through /refactor or /test-and-develop. Structured intake for review feedback with backlog item creation and severity-based prioritization.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /code-review — Code Review Loop

The **Code Review** loop handles the full lifecycle of PR review feedback — from requesting the review through triaging findings to routing fixes through the right workflow. This replaces ad hoc review handling with a repeatable, evidence-based process.

## When to Run

| Trigger | What Happens |
|---|---|
| After `/deploy-and-validate` pushes to remote | Request review from designated reviewer(s) |
| When review comments arrive | Triage findings into backlog items |
| After triage | Route fixes through `/refactor` or `/test-and-develop` |

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Facilitator** | SM | Triages findings, routes to correct workflow, tracks resolution |
| **Process** | Igor | Assesses blast radius, identifies related findings to batch |
| **Quality** | Paul | Evaluates test coverage gaps exposed by findings |
| **Technical** | Dmitri | Assesses implementation effort, identifies root causes |
| **Navigator** | User | Approves triage priorities, approves fix approach |

## Execution Model (MANDATORY)

**Three review dimensions means three agents.** A single agent simulating the other two review perspectives is NOT a comprehensive code review — it is one perspective wearing three hats.

SM orchestrates /code-review by launching **separate agents** for each dimension:

```
Phase 1 — Independent review (parallel):
  Agent: igor-product-owner   → Process review: blast radius assessment, related findings to batch, domain language compliance
  Agent: paul-tester          → Quality review: test coverage gaps exposed by changes, assertion meaningfulness, missing edge case tests
  Agent: dmitri-developer     → Technical review: implementation correctness, architecture alignment, root cause analysis, simplification opportunities

Phase 2 — Cross-review (parallel):
  Each agent reads the other two agents' findings and responds:
  Igor reviews Paul's coverage gaps and Dmitri's technical findings for process implications
  Paul reviews Igor's blast radius assessment and Dmitri's findings for testing implications
  Dmitri reviews Igor's process findings and Paul's coverage gaps for implementation implications

Phase 3 — SM synthesizes:
  SM merges and deduplicates findings
  SM categorizes by severity (critical/moderate/low)
  SM presents consolidated review to User
```

**Anti-pattern:** Launching one agent to perform all three review dimensions. This produces one perspective's blind spots replicated across all dimensions.

## The Loop

```
┌──────────────────────────────────────────────────────────────┐
│  /code-review                                                │
│                                                              │
│  1. REQUEST REVIEW (SM)                                      │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ SM: Identify reviewer(s) from team context           │ │
│     │ Dmitri: Push branch, create/update PR                │ │
│     │ SM: Request review via `gh pr edit --add-reviewer`   │ │
│     │                                                      │ │
│     │ → User: "Review requested from [reviewer].           │ │
│     │   PR: [url]"                                         │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  2. RECEIVE FINDINGS (SM + Team)                             │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ SM: Pull review comments from PR                     │ │
│     │ SM: Categorize each finding:                         │ │
│     │   - Critical (breaks build/runtime)                  │ │
│     │   - Moderate (incorrect behavior, weak tests)        │ │
│     │   - Low (style, naming, minor improvement)           │ │
│     │                                                      │ │
│     │ Igor: Group related findings (same code path,        │ │
│     │   same root cause) into single work items            │ │
│     │                                                      │ │
│     │ → User: "N findings received. Here's the triage:"   │ │
│     │   [table of findings with severity and grouping]     │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  3. TRIAGE & PRIORITIZE (SM → User approves)                 │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ SM creates backlog items for each finding/group      │ │
│     │                                                      │ │
│     │ SM recommends priority:                              │ │
│     │   Fix now: Blocks demo, affects correctness,         │ │
│     │     or low-effort high-value                         │ │
│     │   Defer: No current fixture triggers it,             │ │
│     │     cosmetic, or requires significant design work    │ │
│     │                                                      │ │
│     │ → User: "Recommended: fix [N] now, defer [M].       │ │
│     │   Approve priorities?"                               │ │
│     │ → User approves / adjusts                            │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  4. ROUTE FIXES (SM decides workflow)                        │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ SM evaluates each "fix now" item:                    │ │
│     │                                                      │ │
│     │ Is this new behavior?                                │ │
│     │   → Yes: route to /test-and-develop                  │ │
│     │     (Red → Green → Refactor)                         │ │
│     │                                                      │ │
│     │ Is this fixing existing behavior?                    │ │
│     │   → Yes: route to /refactor                          │ │
│     │     (Green → Refactor → Still Green)                 │ │
│     │                                                      │ │
│     │ Is this a trivial cleanup (dead code, typo)?         │ │
│     │   → Yes: Dmitri fixes inline, no test cycle needed   │ │
│     │                                                      │ │
│     │ → User: "Routing: [item] → [workflow]. Approve?"     │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  5. FIX CYCLE (per workflow)                                 │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ Execute the routed workflow for each item:           │ │
│     │   /refactor or /test-and-develop                     │ │
│     │                                                      │ │
│     │ After all fixes complete:                            │ │
│     │   Dmitri: /sync (fetch, rebase, resolve, test)       │ │
│     │   Dmitri: commit and push                            │ │
│     │                                                      │ │
│     │ → User: "All [N] findings addressed. Tests green.    │ │
│     │   Pushed to PR. Ready for re-review or merge."       │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
│  6. VERIFY RESOLUTION (SM)                                   │
│     ┌──────────────────────────────────────────────────────┐ │
│     │ SM: Confirm each finding is addressed:               │ │
│     │   - Code change matches the finding                  │ │
│     │   - Test covers the fix (if applicable)              │ │
│     │   - No regressions (full suite green)                │ │
│     │                                                      │ │
│     │ SM: Reply to PR comments with resolution notes       │ │
│     │   (or confirm addressed in commit message)           │ │
│     │                                                      │ │
│     │ → User: "All findings resolved. PR ready for         │ │
│     │   re-review or merge approval."                      │ │
│     └──────────────────────────────────────────────────────┘ │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Routing Decision Guide

| Finding Type | Example | Workflow | Why |
|---|---|---|---|
| Incorrect existing behavior | "Savings capped at 10 providers" | `/refactor` | Existing code, wrong result |
| Weak/wrong tests | "Excerpt match too loose" | `/refactor` | Strengthening existing tests |
| Missing behavior | "Denied claims not handled" | `/test-and-develop` | New behavior needed |
| Dead code / unused import | "Provider type never used" | Inline fix | No test cycle needed |
| Incorrect labeling | "In-Network for savings" | `/refactor` | Existing code, wrong output |
| Missing documentation | "No demo script for X" | Inline fix | No test cycle needed |

## Already-Addressed Findings

When pulling review comments, check whether the finding was already fixed (by the team or another reviewer's commit). If so:
- Mark as resolved in the triage table
- Don't create a backlog item
- Note in the resolution summary

## Outputs

```
backlog/done/<review-slug>/
  triage.md             — Findings table with severity, grouping, routing
  status.md             — "all findings addressed on <date>"
```

## Invocation

```bash
/code-review                          — Full loop (request → triage → fix → verify)
/code-review --request                — Request review only
/code-review --triage                 — Receive and triage findings only
/code-review --status                 — Show open findings and their status
```
