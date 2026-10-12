---
version: 1
last_updated: 2026-07-23
updated_by: system
---

# SDLC Leading Practice Defaults

These defaults represent the team's baseline operating practices. They are **always in effect** — the client's SDLC overrides specific areas where it provides explicit detail, but wherever the client's SDLC is silent, these defaults apply.

This is not a fallback for "skip." This is how the team operates unless told otherwise.

## How Defaults and Client SDLC Interact

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  For each practice area:                                │
│                                                         │
│  1. Default is IN EFFECT from day one                   │
│                                                         │
│  2. Client SDLC captured via /initiate                  │
│     → Does it address this area at this detail level?   │
│                                                         │
│  3a. YES, explicitly → Client's practice overrides      │
│      SM notes: "Client specifies: [X]. Overrides       │
│      default: [Y]."                                    │
│                                                         │
│  3b. NO, or only partially → Default remains           │
│      SM notes: "Client SDLC silent on [area].          │
│      Operating on default: [practice]."                │
│                                                         │
│  4. SM documents effective practice in                   │
│     docs/engagement/sdlc-controls.md                    │
│     (marking each as "client-specified" or "default")  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Source Control

| Practice | Default |
|---|---|
| Strategy | Trunk-based development with short-lived feature branches (< 2 days) |
| Branch naming | `feature/<scenario-slug>`, `fix/<defect-slug>`, `refactor/<scope>` |
| Merge strategy | Squash merge to main (clean linear history) |
| Commit message | References the scenario it satisfies: `feat(scenario-slug): description` |
| Branch lifecycle | Delete after merge; no long-lived branches other than main |

## Branch Protection

| Practice | Default |
|---|---|
| Main branch | Protected — no direct push |
| Required checks | CI pipeline passes (build + test + coverage + traceability) |
| Required reviews | 1 approval minimum (team member, not the author) |
| Stale review dismissal | On — new pushes dismiss previous approvals |
| Force push | Disabled on main |
| Linear history | Enforced (squash merge) |

## Code Review

| Practice | Default |
|---|---|
| Reviewers | 1 minimum; Paul reviews Dmitri's code, Dmitri reviews Paul's test infrastructure |
| Focus | Correctness, testability, simplicity; not style (automated) |
| Turnaround | Same session — reviews don't queue |
| Blocking findings | Must be resolved before merge (not "will fix later") |
| Automated checks required | Lint, format, type-check, all tests, coverage, traceability |

## Security

| Practice | Default |
|---|---|
| Dependency scanning | Every build; block on high/critical CVEs |
| SAST (static analysis security) | Every PR; zero findings above medium |
| Secrets detection | Pre-commit hook + CI check; block on any detected secret |
| Container scanning | Every image build (if containerized); no critical vulnerabilities |
| DAST (dynamic) | Run against staging before production promotion |
| Supply chain | Lockfiles committed; reproducible builds; no floating versions |
| Auth patterns | Least privilege; short-lived tokens; no shared credentials |

## Static Analysis & Code Quality

| Practice | Default |
|---|---|
| Linting | Enforced in CI; zero warnings (warnings are errors) |
| Formatting | Automated (Prettier/Black/google-java-format); enforced pre-commit |
| Type checking | Strict mode (no `any`, no implicit `null`) where language supports |
| Complexity | Flag methods > 10 cyclomatic complexity for refactoring |
| Dead code | Flag and remove; verified by traceability (orphan code = gap) |

## Change Management

| Practice | Default |
|---|---|
| Dev/Test deployment | Automatic on green build — no approval needed |
| Staging deployment | User approval required |
| Production deployment | User approval required + all DoD criteria met |
| CAB/change board | None — the automated quality gates ARE the change control |
| Emergency changes | Same pipeline, same gates; no shortcuts. Fix fast, not sloppy |
| Audit trail | Git history + CI logs + deployment records = complete audit |

## Release Process

| Practice | Default |
|---|---|
| Cadence | Continuous delivery — every green main commit is deployable |
| Strategy | Blue/green with automated rollback |
| Feature flags | Available for progressive rollout; cleanup required within 2 sprints |
| Rollback trigger | Automated: error rate > 5% for 5 min, P99 > 3x baseline, health check failures > 3 |
| Rollback mechanism | Instant traffic swap (< 30s); database migrations must be forward-compatible |
| Smoke tests | Run against production immediately after deploy |
| Canary period | 10 minutes of monitoring before declaring release successful |

## Incident Response

| Practice | Default |
|---|---|
| First action | Rollback (automated or manual) — restore service first |
| Investigation | After service is restored; never debug live under pressure |
| Fix process | Reproduce as failing test → fix → normal pipeline (no hotfix bypass) |
| Communication | User notified immediately; status updates until resolved |
| Post-incident | Root cause documented in `docs/engagement/tech-debt.md` |

## Dependency Management

| Practice | Default |
|---|---|
| Lockfiles | Always committed; builds must be reproducible |
| Version policy | Pin exact versions (no ranges in production dependencies) |
| Updates | Automated PRs (Dependabot/Renovate); reviewed and tested normally |
| CVE policy | High/critical: address within 48 hours. Medium: next iteration. Low: backlog |
| Transitive deps | Scanned same as direct; no "it's not our code" excuse |

## Documentation

| Practice | Default |
|---|---|
| Architecture decisions | ADRs in `docs/adr/` — short, context + decision + consequences |
| API documentation | Generated from code (OpenAPI / GraphQL schema); never hand-maintained |
| Runbooks | Required for production services; live in repo alongside code |
| Wiki/Confluence | Not used — documentation lives in the repo or it rots |
| Feature documentation | Gherkin scenarios ARE the living documentation |

## Secrets & Configuration

| Practice | Default |
|---|---|
| Storage | Cloud secrets manager (AWS Secrets Manager default) |
| In code | Never — not even in test fixtures or example configs |
| Injection | Environment variables or secrets mount at runtime |
| Rotation | 90-day default; automated where possible |
| Detection | Pre-commit hook scans for patterns (API keys, tokens, passwords) |
| Test secrets | Separate from production; clearly marked as non-production |

## Observability

| Practice | Default |
|---|---|
| Logging | Structured JSON; correlation ID on every request; no PII in logs |
| Metrics | RED method (Rate, Errors, Duration) for every service |
| Tracing | Distributed tracing (OpenTelemetry); trace context propagated across services |
| Alerting | On symptoms (error rate, latency), not causes; escalation path defined |
| Dashboards | One per service; shows golden signals; accessible to whole team |
| Health checks | `/health` endpoint on every service; checks dependencies |

## CI/CD Pipeline

| Practice | Default |
|---|---|
| Trigger | Every push to main; every PR update |
| Stages | Build → Test → Coverage gate → Traceability gate → Security scan → Deploy |
| Speed target | < 10 minutes for full pipeline (optimize continuously) |
| Flaky tests | Zero tolerance — fix or delete immediately (no retry loops) |
| Pipeline as code | Defined in repo (GitHub Actions default); versioned with the code |
| Artifacts | Immutable; tagged with commit SHA; stored in registry |
| Environments | Same artifact deployed to all environments (config differs, binary doesn't) |

## How SM Uses This Document

1. **At engagement start** (`/initiate`): SM starts with these defaults as the operating baseline
2. **When client provides SDLC**: SM compares client's detail against each section — overrides where client is explicit, retains defaults where client is silent
3. **Documents effective practice**: `docs/engagement/sdlc-controls.md` shows what's actually in effect, with provenance (default vs client-specified)
4. **Derives DoR/DoD criteria**: Both from client overrides AND from defaults that are in effect
5. **During development**: SM enforces the effective practices — whether they came from defaults or client

## Updating Defaults

These defaults evolve. If the team discovers a better practice during an engagement, SM can propose an update. But defaults change at the accelerator level (this file), not per-engagement. Per-engagement deviations are captured as client overrides in `docs/engagement/sdlc-controls.md`.
