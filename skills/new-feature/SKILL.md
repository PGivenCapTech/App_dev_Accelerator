---
name: new-feature
description: New Feature workflow — composes all loops for net-new functionality. /refine → /spike (if needed) → /design → /test-and-develop → /deploy-and-validate → /release.
allowed-tools: [Read, Write, Edit, Bash, Agent]
user-invocable: true
---

# /new-feature — New Feature Workflow

The **New Feature** workflow composes the full loop sequence for building net-new functionality. It's the standard path for features coming from the discovery backlog.

## Loop Composition

```
/refine → /spike (if unknowns) → /design → /test-and-develop → /deploy-and-validate → /release
```

All loops run in full with all gates:

```
┌────────────────────────────────────────────────────────────┐
│  /new-feature                                              │
│                                                            │
│  ┌──────────┐   unknowns?   ┌──────────┐                  │
│  │  /refine │──── yes ──────►│  /spike  │                  │
│  │          │                │          │                  │
│  │ 3 amigos │◄── resolved ──│ evidence │                  │
│  │ + User   │                └──────────┘                  │
│  │          │── ready ──┐                                  │
│  └──────────┘           │                                  │
│                         ▼                                  │
│                   ┌──────────┐                              │
│                   │  /design │                              │
│                   │          │                              │
│                   │ Dmitri + │                              │
│                   │ Paul +   │                              │
│                   │ Igor +   │                              │
│                   │ User     │                              │
│                   └────┬─────┘                              │
│                        │ approved                           │
│                        ▼                                    │
│                   ┌─────────────────┐                       │
│                   │ /test-and-develop│                       │
│                   │                 │                       │
│                   │ Paul + Dmitri   │                       │
│                   │ + User (nav)    │                       │
│                   │                 │                       │
│                   │ Ping-pong TDD   │                       │
│                   │ per scenario    │                       │
│                   └────────┬────────┘                       │
│                            │ all green, 100% trace + cov   │
│                            ▼                                │
│                   ┌─────────────────────┐                   │
│                   │ /deploy-and-validate │                   │
│                   │                     │                   │
│                   │ dev → test → staging │                   │
│                   │ validate each level  │                   │
│                   │ User approves promos  │                   │
│                   └──────────┬──────────┘                   │
│                              │ staging validated            │
│                              ▼                              │
│                   ┌──────────┐                              │
│                   │ /release │                              │
│                   │          │                              │
│                   │ prod +   │                              │
│                   │ smoke +  │                              │
│                   │ feedback │                              │
│                   └──────────┘                              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## When to Use

- New functionality from the discovery backlog
- Capability that doesn't exist yet in the system
- New bounded context or domain area
- Features requiring full NFR treatment (perf, security, resilience)

## What Makes This Different from /fix-defect and /refactor

| Aspect | /new-feature | /fix-defect | /refactor |
|---|---|---|---|
| Refine | Full (three amigos) | Minimal (reproduce + define fix) | Light (scope the change) |
| Spike | If unknowns exist | Rarely (root cause analysis instead) | Sometimes (approach validation) |
| Design | Full | Minimal (targeted fix design) | Full (new structure design) |
| Test & Develop | Full BDD outside-in | Regression test first, then fix | Tests first (prove behavior preserved) |
| Deploy & Validate | Full | Full | Full |
| Release | Full with feedback | Full | Full |
| NFR scenarios | New NFRs defined | Existing NFRs maintained | Existing NFRs maintained + improved |

## Invocation

```bash
/new-feature                        — Start with top backlog item
/new-feature <backlog-item-slug>    — Start with specific item
/new-feature --status               — Show where current feature is in the workflow
/new-feature --resume               — Resume from last approved gate
```
