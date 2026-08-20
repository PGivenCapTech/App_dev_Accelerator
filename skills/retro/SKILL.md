---
name: retro
description: Retrospective loop — team reviews its own operating model (DoR, DoD, interaction patterns, loop handoffs, guardrails) and proposes concrete adjustments for improved performance.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /retro — Retrospective (Inspect & Adapt)

The **Retro** loop is how the team improves itself. After each iteration (or on-demand), the agents review their own operating model — Definition of Ready, Definition of Done, interaction patterns, loop handoffs, guardrails, and context — and propose concrete changes for the next iteration.

**This is not a feelings check.** It's a structured analysis of what worked, what didn't, and what specific change will improve performance. Every observation must produce either an action (change something) or a validation (confirm something is working — keep it).

## When to Run

| Trigger | Scope |
|---|---|
| After `/release` (iteration complete) | Full retro — all dimensions |
| Mid-iteration (something feels off) | Focused retro — specific pain point |
| After `/fix-defect` (for systemic issues) | Root-cause retro — why did this escape? |
| On-demand | Whatever the User wants to examine |

## Participants

| Role | Agent | Reviews |
|---|---|---|
| **Facilitator** | SM | Structures the retro, tracks actions, enforces follow-through |
| **Process** | Igor | DoR effectiveness, refinement quality, scenario clarity |
| **Quality** | Paul | DoD effectiveness, test strategy, coverage value, NFR targeting |
| **Technical** | Dmitri | Loop handoffs, tooling friction, environment/pipeline issues, token efficiency |
| **Navigator** | User | Approves changes, provides perspective the agents can't see |

## What Gets Reviewed

### 1. Definition of Ready Effectiveness

**Igor + Paul review:**
- Did any item reach `/design` or `/test-and-develop` that wasn't actually ready?
- What was missing? (Ambiguous scenarios, missing NFRs, undiscovered dependencies)
- Were there criteria in DoR that added no value? (Checked but never caught anything)
- Should criteria be added based on what surprised us?

**Evidence sources:**
- Items that were sent back from design to refinement
- Unknowns discovered during development that should have been caught in refinement
- Spikes triggered mid-build (should have been triggered pre-design)

**Output:** Proposed changes to `docs/definition-of-ready.md`

### 2. Definition of Done Effectiveness

**Paul + SM review:**
- Did any DoD criterion catch a real problem this iteration? (Validates its existence)
- Did any criterion create friction without catching anything? (Candidate for removal or relaxation)
- Did anything escape to production that DoD should have caught? (Gap — add a criterion)
- Are verification scripts working correctly? (False passes? false blocks?)

**Evidence sources:**
- Deployment blocks triggered (and whether they were real problems or false positives)
- Production incidents (did DoD miss something?)
- Time spent on DoD verification vs. value delivered by the catch

**Output:** Proposed changes to `docs/definition-of-done.md`

### 3. Interaction Model & Approval Gates

**SM + User review:**
- Were there too many approval prompts? (User bottlenecked, slowing the team)
- Were there too few? (Something got built that shouldn't have, or User felt out of the loop)
- Did the right agent ask the right question at the right time?
- Were any approvals rubber-stamped? (Sign they're not adding value at that point)
- Did the User have enough context to make informed decisions at each gate?

**Evidence sources:**
- Gates where User always said "yes" without discussion (maybe not needed there)
- Gates where User said "wait, that's not right" (validates the gate)
- Points where User felt surprised by what was built (gate was missing or insufficient)
- Time User spent waiting between approval requests (flow efficiency)

**Output:** Proposed changes to approval gates in `CLAUDE.md` or loop definitions

### 4. Loop Handoffs & Flow

**Dmitri + SM review:**
- Where did work stall between loops? (Waiting for context, waiting for approval, unclear who goes next)
- What context got lost in transitions? (Refinement decisions forgotten during design, design intent lost during development)
- Were any loops skipped or abbreviated when they shouldn't have been?
- Were any loops run that added no value for this type of work?

**Evidence sources:**
- Time gaps between loop completions
- Questions asked during development that were already answered during refinement
- Rework caused by lost context
- Loops that produced artifacts nobody referenced later

**Output:** Proposed changes to loop definitions, handoff protocols, or workflow composition

### 5. SDLC Defaults & Practices

**Dmitri + Paul review:**
- Which defaults worked well? (Confirm — keep)
- Which defaults did the team work around? (Override needed or practice needs fixing)
- Which client overrides helped? Which created friction?
- Is the pipeline too slow? Too brittle? Missing a stage?

**Evidence sources:**
- Pipeline failures and their causes
- Practices the team deviated from (and whether the deviation was better)
- Build/test/deploy time trends

**Output:** Proposed changes to `docs/sdlc-defaults.md` or `docs/engagement/sdlc-controls.md`

### 6. Engagement Context & Systems of Record

**SM reviews:**
- Assumptions that were validated (remove the "ASSUMED" flag)
- Assumptions that were wrong (what was the impact? what do we know now?)
- Gaps that kept resurfacing (should have been captured earlier)
- Context that was captured but never used (wasted effort in initiation)
- System integrations that worked smoothly vs. ones that created toil

**Evidence sources:**
- Gap-fill prompts triggered during loops (what was missing when)
- Assumptions that reached production unvalidated (risk)
- Integration failures or sync issues with external systems

**Output:** Updates to `docs/engagement/` files, integration adjustments

### 7. Estimation & Planning

**SM + Igor review:**
- S/M/L estimates vs. actual effort — are we calibrated?
- Did iteration scope hold, or was it too ambitious / too conservative?
- Were dependencies identified early enough?
- Did priorities shift mid-iteration? Why?

**Evidence sources:**
- Planned vs. completed features
- Features that grew in scope during development
- Blocked items and how long they stayed blocked

**Output:** Calibration notes for next iteration planning

### 8. Token Efficiency & Waste

**SM + Dmitri review:**
- What percentage of tokens delivered productive value (implementation, design, testing)?
- What consumed tokens without delivering value (debugging, re-orientation, ceremony, rework)?
- Was the top waste category preventable? What specific change would prevent it next iteration?
- Did context compaction cause rework (re-reading files, re-deriving decisions)?
- Were there repeated manual ceremonies that should be automated (snapshot regeneration, boilerplate setup)?

**Evidence sources:**
- Session length vs. features completed (tokens-per-feature trend)
- Debugging loops — how many cycles before root cause found?
- Repeated tool calls for the same information (context loss indicator)
- Manual steps performed identically more than twice (automation candidate)
- Same bug class surfacing across multiple sessions (prevention failure)

**Token burn categories:**
| Category | Healthy | Warning | Action |
|---|---|---|---|
| Productive implementation | >60% | <40% | Process is adding too much overhead |
| Debugging state pollution | <5% | >15% | Add isolation guards, better diagnostics |
| Context loss / re-orientation | <10% | >20% | Better memory, docs, or session management |
| Ceremony / boilerplate | <10% | >15% | Automate the repeated steps |
| Rework from missed requirements | <5% | >10% | DoR gap — add criterion |
| Exploration / dead ends | <15% | >25% | Better diagnostic heuristics |

**Output:** Specific automation or process change to reduce top waste category

### 9. User Engagement & Steering Quality

**SM reviews:**
- At how many gates did the User accept the team's recommendation without modification?
- At how many gates did the User redirect, modify, or reject?
- Did the User initiate any scope changes, questions, or concerns unprompted?
- Were approval gates surfacing real decisions, or were they rubber-stamp checkpoints?
- Is the User actively shaping the work or passively accepting AI recommendations?

**Evidence sources:**
- Count of approval gates presented vs. accepted/modified/rejected
- User-initiated messages that changed direction (not just "yes")
- Points where User provided domain knowledge the team couldn't derive
- Gates where User always said "yes" (candidate for simplification)
- Features where User pushed back and the result was better for it

**Why this matters:** AI-assisted teams can drift toward the AI driving all decisions while the human rubber-stamps. This is dangerous — the AI lacks business context, judgment about risk appetite, and awareness of organizational politics. A healthy ratio means the User is genuinely steering, not just approving. If engagement drops below 10%, SM should proactively surface harder decisions to the User rather than resolving them internally.

**Output:** Adjustment to approval gates (simplify low-value ones, add gates at real decision points), or escalation to User that their engagement is too low/high

## The Retro Process

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  1. SM sets the scope                                       │
│     "Full retro (all dimensions) or focused on [area]?"    │
│     → User confirms scope                                  │
│                                                             │
│  2. Each agent reviews their dimensions                     │
│     (Read artifacts, git history, status changes,          │
│      deployment logs, test results)                        │
│                                                             │
│  3. Each agent presents observations WITH evidence          │
│     NOT: "I think refinement was slow"                     │
│     YES: "Feature X was sent back from design because      │
│      [specific gap]. This cost [time]. If DoR had          │
│      [criterion], we'd have caught it in refinement."      │
│                                                             │
│  4. Each observation produces a CONCRETE proposal           │
│     NOT: "We should communicate better"                    │
│     YES: "Add to DoR: 'Data migration impact assessed'    │
│      because we missed it twice this iteration"            │
│                                                             │
│  5. SM consolidates proposals into categories:              │
│     ✅ KEEP: [what worked — explicitly validate]           │
│     🔄 CHANGE: [what to modify — specific diff]           │
│     ➕ ADD: [what's missing — specific addition]           │
│     ➖ REMOVE: [what to stop — specific removal]          │
│                                                             │
│  6. User reviews and approves/adjusts each proposal         │
│     "Here are the proposed changes. Approve each?"        │
│     → User can approve all, reject some, modify others    │
│                                                             │
│  7. SM applies approved changes                             │
│     → Updates DoR, DoD, loop definitions, context docs    │
│     → Commits with message: "retro: [summary of changes]" │
│     → Notes rejected proposals (may revisit next retro)   │
│                                                             │
│  8. SM documents the retro                                  │
│     → Writes to docs/retros/<iteration-N>.md              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Retro Output Format

```markdown
# Retrospective — Iteration [N]

Date: [date]
Features completed: [list]
Scope: [full / focused on X]
Sessions: [number of context windows this iteration spanned]

## Iteration Metrics

### Token Efficiency

| Category | Est. % of Tokens | Root Cause | Preventable? |
|---|---|---|---|
| Productive implementation | [%] | N/A — value delivery | No |
| Debugging state pollution | [%] | [specific cause] | [Yes — how] |
| Context loss / re-orientation | [%] | Session compaction, re-reading files | Partially — better memory/docs |
| Ceremony / boilerplate | [%] | [repeated manual steps] | [Yes — automate] |
| Rework from missed requirements | [%] | [what was missed in refinement] | [Yes — DoR gap] |
| Exploration / dead ends | [%] | [wrong hypothesis pursued] | Partially — better diagnostics |

**Efficiency ratio:** [productive %] of tokens delivered value.
**Top waste:** [single biggest non-productive category and its root cause].

### Refinement-to-Rework Ratio

| Metric | Value |
|---|---|
| Items that passed DoR | [N] |
| Items requiring mid-build clarification or scope change | [N] |
| Rework ratio | [N/N = %] |
| "Wait, we didn't think about X" moments | [count, list briefly] |

**Target:** <20% rework ratio. Above 20% = DoR is not catching enough.

### Test-to-Green Ratio

| Feature/Scenario | Test Runs to Green | Root Cause of Failures |
|---|---|---|
| [Scenario name] | [N] | [underspecified contract / environment / state pollution / real bug] |

**Average:** [N:1]. **Target:** <2:1.

### Regression Introduction Rate

| Metric | Value |
|---|---|
| Features added this iteration | [N] |
| Full-suite breaks caused by new features | [N] |
| Regression rate | [N/N = %] |
| Root causes | [list: state pollution, schema drift, missing reset, etc.] |

**Target:** 0%. Any non-zero value gets a root-cause action item.

### Ceremony-to-Automation Conversion

| Metric | Value |
|---|---|
| Manual ceremonies identified (cumulative all iterations) | [N] |
| Manual ceremonies automated (cumulative) | [N] |
| Conversion rate | [%] |
| New ceremonies identified this iteration | [list] |
| Ceremonies automated this iteration | [list] |

**Process debt = identified - automated.** Should trend toward zero.

### Context Window Utilization

| Metric | Value |
|---|---|
| Sessions (context windows) this iteration | [N] |
| Features completed | [N] |
| Sessions per feature | [ratio] |
| Re-orientation events (re-reading same files, re-deriving same decisions) | [count] |

**Target:** ≤2 sessions per feature. Higher = break features smaller or improve handoff.

### Cycle Time by Phase

| Phase | Est. % of Effort | Expected | Delta |
|---|---|---|---|
| /refine | [%] | 10% | [+/-] |
| /design | [%] | 10% | [+/-] |
| /test-and-develop (productive) | [%] | 60% | [+/-] |
| /test-and-develop (debugging) | [%] | 5% | [+/-] |
| /deploy-and-validate | [%] | 10% | [+/-] |
| Unplanned work (not in any loop) | [%] | 5% | [+/-] |

**If debugging > productive implementation → systemic isolation problem.**

### User Engagement

| Metric | Value |
|---|---|
| Approval gates presented to User | [N] |
| User accepted without modification | [N] |
| User modified/redirected | [N] |
| User rejected/pushed back | [N] |
| User-initiated scope changes | [N] |
| User-initiated questions or concerns | [N] |
| Engagement ratio (modified + rejected + initiated) / total gates | [%] |

**What this measures:** Is the User actively steering, or passively accepting recommendations? A healthy team has the User adjusting 20-40% of proposals. Below 10% suggests rubber-stamping (gates aren't surfacing real decisions). Above 60% suggests the team is misaligned with User expectations.

| Engagement Level | Ratio | Interpretation |
|---|---|---|
| Highly engaged | 30-50% | User is actively shaping the work — ideal |
| Engaged | 20-30% | Team is mostly aligned, User steers at key moments |
| Passive | 10-20% | User may be trusting too much or disengaged — probe |
| Rubber-stamping | <10% | Gates aren't surfacing real decisions — simplify or escalate |
| Misaligned | >60% | Team proposals consistently miss — improve discovery/refinement |

## Historical Trend (update each retro)

_Copy this iteration's metrics into `docs/retros/metrics-history.md` to track trends._

| Metric | Iter 1 | Iter 2 | Iter 3 | ... | Trend |
|---|---|---|---|---|---|
| Token efficiency ratio | — | — | [%] | | ↑↓→ |
| Refinement-to-rework ratio | — | — | [%] | | ↑↓→ |
| Test-to-green ratio | — | — | [N:1] | | ↑↓→ |
| Regression introduction rate | — | — | [%] | | ↑↓→ |
| Ceremony automation conversion | — | — | [%] | | ↑↓→ |
| Sessions per feature | — | — | [N] | | ↑↓→ |
| Debugging % of cycle time | — | — | [%] | | ↑↓→ |
| User engagement ratio | — | — | [%] | | ↑↓→ |

**Arrows:** ↑ = improving, ↓ = degrading, → = stable. Flag any metric that degrades two iterations in a row.

## KEEP (Validated — Working Well)

| What | Evidence | Decision |
|---|---|---|
| [Practice/gate/process] | [Proof it added value] | Keep as-is |

## CHANGE (Modify — Specific Diff)

| What | Problem | Proposed Change | Evidence | Approved |
|---|---|---|---|---|
| DoR criterion X | Didn't catch [gap] | Reword to: "[new wording]" | Feature Y was sent back | ✅ / ❌ |
| Approval gate Z | User rubber-stamped 100% | Move from per-unit to per-scenario | Gate never caught anything | ✅ / ❌ |

## ADD (Missing — New Addition)

| What | Why | Proposed Addition | Evidence | Approved |
|---|---|---|---|---|
| DoD criterion | [X] escaped to prod | "Data migration reversibility verified" | Incident on [date] | ✅ / ❌ |
| Context area | Kept asking mid-build | Capture [field] during /initiate | 3 gap-fills for same info | ✅ / ❌ |

## REMOVE (Stop — Not Adding Value)

| What | Why Remove | Evidence | Approved |
|---|---|---|---|
| Approval gate X | Never caught anything in N iterations | 0 rejections out of M approvals | ✅ / ❌ |
| DoR criterion Y | Always auto-satisfied, never surfaced issues | N/A — it's dead weight | ✅ / ❌ |

## REJECTED (Not Now — May Revisit)

| Proposal | Reason for Rejection | Revisit When |
|---|---|---|
| [Proposal] | User: "[reason]" | Next retro / never |

## Actions Applied

| Action | File Changed | Commit |
|---|---|---|
| Added DoD criterion: "[X]" | docs/definition-of-done.md | [sha] |
| Removed approval gate at [step] | skills/test-and-develop/SKILL.md | [sha] |
| Updated engagement context | docs/engagement/[area].md | [sha] |
```

## Historical Metrics Tracking

Every retro appends its metrics to `docs/retros/metrics-history.md`. This file is the team's memory — it shows whether process changes are working or whether the same problems keep recurring.

**SM is responsible for:**
1. Copying this iteration's metric values into the history file
2. Calculating trend arrows (↑ improving, ↓ degrading, → stable)
3. Flagging any metric that degrades two iterations in a row (requires an action item)
4. Noting which process changes correlate with metric improvements

**What to track historically:**

| Metric | Source | Healthy | Warning |
|---|---|---|---|
| Token efficiency ratio | Token Burn Analysis | >60% | <40% |
| Refinement-to-rework ratio | Items reworked / items built | <20% | >30% |
| Test-to-green ratio | Avg test runs to pass | <2:1 | >4:1 |
| Regression introduction rate | Suite breaks / features added | 0% | >20% |
| Ceremony automation conversion | Automated / identified | >80% | <50% |
| Sessions per feature | Context windows / features | ≤2 | >4 |
| Debugging % of cycle time | Debug effort / total effort | <10% | >25% |
| User engagement ratio | (modified + rejected + initiated) / total gates | 20-40% | <10% or >60% |

**Two-iteration degradation rule:** If any metric worsens for two consecutive iterations, SM must escalate it as a retro action item with root-cause analysis. The team cannot allow silent degradation.

## Rules

- **Evidence-based only** — no observation without proof it happened
- **Concrete proposals only** — no vague "improve communication" suggestions
- **User approves every change** — the team proposes, the User decides
- **Applied immediately** — approved changes are committed before the next iteration starts
- **Cumulative** — retro history in `docs/retros/` shows evolution over time
- **Metrics are longitudinal** — every retro updates `docs/retros/metrics-history.md`; trends matter more than individual values
- **No sacred cows** — any process element can be challenged (including approval gates, DoR criteria, loop structure)
- **Keep is as important as Change** — explicitly validating what works prevents drift

## What Can Be Changed by Retro

| Artifact | Changeable | How |
|---|---|---|
| `docs/definition-of-ready.md` | Add/remove/modify criteria | Direct edit |
| `docs/definition-of-done.md` | Add/remove/modify criteria | Direct edit |
| `CLAUDE.md` / copilot-instructions | Modify approval gates, interaction patterns | Direct edit |
| `skills/*/SKILL.md` / `.github/prompts/` | Modify loop behavior, add/remove steps | Direct edit |
| `docs/sdlc-defaults.md` | Propose changes (accelerator-level) | Flagged for accelerator update |
| `docs/engagement/*.md` | Update context, validate assumptions | Direct edit |
| Workflow composition | Change which loops are included/skipped | Edit workflow skills |

**Note:** Changes to `docs/sdlc-defaults.md` affect ALL teams using the accelerator. These proposals are flagged rather than applied directly — they go to the accelerator maintainer.

## Invocation

```bash
/retro                               — Full retrospective (all dimensions)
/retro --focused "interaction model"  — Focus on specific area
/retro --focused "DoR"               — Focus on Definition of Ready
/retro --focused "DoD"               — Focus on Definition of Done
/retro --focused "pipeline"          — Focus on CI/CD and deployment
/retro --root-cause <incident>       — Root-cause analysis for specific issue
/retro --history                     — Show past retro decisions and their outcomes
```
