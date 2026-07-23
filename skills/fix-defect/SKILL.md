---
name: fix-defect
description: Defect Fix workflow — reproduce, root-cause, write regression test FIRST, fix, validate. Abbreviated loops for speed without sacrificing quality.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /fix-defect — Defect Fix Workflow

The **Defect Fix** workflow is an abbreviated composition of loops optimized for fixing bugs quickly without sacrificing traceability or test coverage. The key principle: **write the regression test first** (prove the bug exists), then fix, then validate.

## Loop Composition (Abbreviated)

```
Reproduce → Root-Cause → /test-and-develop (regression-first) → /deploy-and-validate → /release
```

No full /refine or /design — but the defect STILL gets:
- A Gherkin scenario (the regression test)
- Full traceability (scenario → test → fix)
- 100% coverage maintained
- Full deployment validation

## The Workflow

```
┌────────────────────────────────────────────────────────────┐
│  /fix-defect                                               │
│                                                            │
│  1. REPRODUCE (Paul leads)                                 │
│     ┌────────────────────────────────────────────────┐     │
│     │ Paul: Write a failing test that PROVES the bug │     │
│     │                                                │     │
│     │ Scenario: [Defect description]                 │     │
│     │   Given [precondition that triggers bug]       │     │
│     │   When [action that causes the defect]         │     │
│     │   Then [expected behavior — currently fails]   │     │
│     │                                                │     │
│     │ → User: "This test reproduces the defect.     │     │
│     │   Confirms the bug? Expected behavior right?"  │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  2. ROOT-CAUSE (Dmitri leads)                              │
│     ┌────────────────────────────────────────────────┐     │
│     │ Dmitri: Trace the defect to root cause         │     │
│     │ - Where in the code does it go wrong?         │     │
│     │ - Why? (not just what)                        │     │
│     │ - Are there related defects (same root cause)?│     │
│     │                                                │     │
│     │ → User: "Root cause: [explanation].            │     │
│     │   Fix approach: [proposal]. Agree?"            │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  3. TEST-AND-FIX (Paul + Dmitri pair, User navigates)      │
│     ┌────────────────────────────────────────────────┐     │
│     │ Abbreviated /test-and-develop:                 │     │
│     │                                                │     │
│     │ Paul: Regression test exists (failing) ✅       │     │
│     │ Paul: Add unit test for fix (failing)          │     │
│     │ → User: "Unit test targets root cause?"       │     │
│     │                                                │     │
│     │ Dmitri: Fix implementation (tests go green)    │     │
│     │ → User: "Fix looks right? Minimal change?"    │     │
│     │                                                │     │
│     │ Paul: Run FULL regression suite                │     │
│     │ → User: "No regressions. Fix is clean."       │     │
│     │                                                │     │
│     │ SM: Traceability + coverage still 100%?       │     │
│     └────────────────────────────────────────────────┘     │
│                                                            │
│  4. /deploy-and-validate (full — same as new feature)      │
│     dev → test → staging (User approves promotions)        │
│                                                            │
│  5. /release (full — same as new feature)                  │
│     Production deploy + smoke + feedback                   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Key Principles (XP + BDD for Defects)

- **Regression test FIRST**: If you can't reproduce it in a test, you can't prove you fixed it
- **Minimal fix**: Change the least code possible — this isn't refactoring time
- **Root cause, not symptom**: Fix WHY it's broken, not just WHERE
- **No coverage drop**: Fix must not reduce coverage (usually increases it)
- **Traceability**: Defect scenario links to test links to fix (same rules as new code)
- **Full deploy validation**: Bugs often have environment-specific aspects — validate everywhere

## Defect Severity and Process Adaptation

| Severity | Process Adjustment |
|---|---|
| **Critical (prod down)** | Skip User approval on dev/test promotion (expedite). Full validation still required for staging/prod. |
| **High (major function broken)** | Full process, but prioritized above other work |
| **Medium (degraded behavior)** | Full process, queued normally |
| **Low (cosmetic/minor)** | Can batch with other work in next iteration |

Even critical defects get:
- A regression test (written first)
- Traceability (scenario → test → fix)
- Full production validation (smoke tests)

## Outputs

```
backlog/done/<defect-slug>/
  defect.md             — Reproduction scenario + root cause
  regression-test.md    — The test that proves the fix
  traceability.md       — Scenario → test → fix trace
  status.md             — "fixed and released on <date>"
```

## Invocation

```bash
/fix-defect "Users getting 500 when submitting payment form"
/fix-defect --critical "Production payment processing halted"
/fix-defect --list                 — Show open defects
/fix-defect --status               — Show fix progress
```
