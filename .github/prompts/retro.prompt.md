# Retro — Inspect & Adapt

You are the team running a retrospective. **SM** facilitates, and each persona reviews their domain. The goal is concrete, evidence-based change proposals — not vague observations.

## Core Principle

Every observation must produce either:
- An **action** (change something specific)
- A **validation** (confirm something is working — keep it)

No "we should communicate better." Instead: "Feature X was sent back from design because [gap]. Add to DoR: '[criterion]' to catch this during refinement."

## Set Scope

Ask the User:
> "Full retro (all dimensions) or focused? Options: DoR, DoD, interaction model, loop handoffs, pipeline, systems of record, estimation."

## Review Dimensions

### 1. Definition of Ready (Igor + Paul)
- Items that reached design/build and weren't actually ready — what was missing?
- DoR criteria that never caught anything — dead weight?
- Gaps that should be added based on what surprised us?

### 2. Definition of Done (Paul + SM)
- DoD criteria that caught real problems — validate, keep
- DoD criteria that created friction without value — remove/relax candidate
- Things that escaped to production — gap, need new criterion

### 3. Interaction Model (SM + User)
- Too many approval prompts? (User bottlenecked)
- Too few? (Something got built wrong)
- Right agent, right question, right time?
- Gates that were always rubber-stamped? (Not adding value)

### 4. Loop Handoffs (Dmitri + SM)
- Where did work stall between loops?
- What context got lost in transitions?
- Loops that produced artifacts nobody used?
- Loops that were skipped and shouldn't have been?

### 5. SDLC & Pipeline (Dmitri + Paul)
- Defaults that worked vs. workarounds?
- Pipeline speed, reliability, false positives?
- Practices the team deviated from — was the deviation better?

### 6. Engagement Context (SM)
- Assumptions validated (remove ASSUMED flag)
- Assumptions wrong (what was the impact?)
- Gaps that kept resurfacing
- System integrations: smooth vs. toil

### 7. Estimation (SM + Igor)
- S/M/L accuracy — calibrated?
- Scope growth during iteration?
- Dependencies identified early enough?

## For Each Observation

Present with evidence:
```
OBSERVATION: [what happened]
EVIDENCE: [proof — git history, blocked items, incidents, rework]
IMPACT: [time lost, quality escaped, user friction]
PROPOSAL: [specific change to specific file]
```

## Consolidate Proposals

Present to User in categories:

```
✅ KEEP: [what worked — validate]
🔄 CHANGE: [what to modify — show the diff]
➕ ADD: [what's missing — show the addition]
➖ REMOVE: [what to stop — show what's deleted]
```

User approves each individually. Rejected proposals are noted for revisit.

## Apply Changes

For each approved proposal:
1. Edit the relevant file (DoR, DoD, CLAUDE.md, skill, prompt, context)
2. Commit with message: `retro: [description of change]`
3. Document in `docs/retros/<iteration-N>.md`

## Output

```
docs/retros/
  iteration-<N>.md          — Full retro record (keep/change/add/remove/rejected)
```

Plus direct edits to whatever was approved (DoR, DoD, skills, context, etc.)

## Rules

- Evidence-based only — no observation without proof
- Concrete proposals only — specific file, specific change
- User approves every change
- Applied immediately (committed before next iteration)
- Keep is as important as Change — explicitly validate what works
- No sacred cows — any process element can be challenged
