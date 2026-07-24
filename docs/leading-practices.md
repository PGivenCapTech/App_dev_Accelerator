# Leading Practices

Practices learned through delivery that the team adopts going forward. Each originated from a real situation — the "Why" explains the incident or insight that produced it.

## Domain Modeling

### Regulatory-Qualified Domain Terms

**Practice:** If a domain term is driven by an external regulatory standard, include the regulatory body name in the field/class name.

**Example:** `oshaRecordable` (OSHA 29 CFR 1904), not just `recordable`.

**Why:** Multiple regulatory frameworks may define similar concepts (OSHA recordable, EPA reportable, MSHA recordable). A bare term like `recordable` is ambiguous when frameworks overlap. Naming the regulatory body eliminates interpretation at read-time.

**How to apply:** When introducing a domain term, ask: "Is this defined by an external standard?" If yes, prefix with the standard's owning body. This applies to field names, enum values, event names, and API contract fields.

---

## Process Discipline

### Never Skip Process Steps

**Practice:** Always follow the full flow (refine → design → develop), even when the content feels already covered or "obvious."

**Why:** Skipping steps creates invisible gaps. A domain model issue was caught during TDD that would have been caught earlier in /design — but only because the team went back and ran the design step properly. The controls exist to catch mistakes; "obvious" features still have non-obvious edges.

**How to apply:** SM enforces this by default. If a team member suggests skipping a step ("we already know the design"), SM redirects: "Let's run it — it's fast when there's nothing to find, and it catches things when there is." The cost of running a clean step is minutes; the cost of missing something is hours of rework.

### Apply /fix-defect Even for Internal Issues

**Practice:** When a defect is found during development or demo prep (not just in production), apply the full defect workflow: reproduction scenario, root cause, regression tests, traceability.

**Why:** A defect found internally has the same root cause as one found in production — it just got caught earlier. If you skip the process for "minor" or "internal" issues, you miss the regression test that prevents it from recurring, and you normalize cutting corners.

**How to apply:** Any bug, regardless of when or where it's found, gets: (1) a failing test that reproduces it, (2) a root cause explanation, (3) a traceability record linking scenario → test → fix.

---

## Team Autonomy

### SM Answers Persona-Driven Data Questions

**Practice:** When the team asks "what data does the persona need to see here?", SM can answer directly from discovery context without escalating to the User every time.

**Why:** These questions have answers already captured in discovery (personas, user journeys, data needs). Blocking on the User for every display decision slows the team unnecessarily. SM has access to discovery context and can make the default call — the User course-corrects if needed.

**How to apply:** SM reads the persona definitions, user journey maps, and data requirements from `docs/discovery/`. If the answer is clearly derivable from discovery, SM answers directly. If it requires interpretation or a judgment call beyond discovery scope, SM escalates to the User.
