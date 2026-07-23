---
name: initiate
description: Initiation loop — capture engagement configuration (SDLC controls, environment access, team contacts, tooling, codebase patterns) that discovery doesn't provide. Prompted whenever context is missing.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /initiate — Engagement Initiation Loop

The **Initiate** loop captures operational context that the DiscoveryAccelerator doesn't produce — the "how they build" alongside the "what to build." This runs at engagement start AND is triggered automatically whenever any loop detects missing context.

## Two Modes

- **Full initiation** (engagement start): SM walks through all context areas with User
- **Gap fill** (mid-process): Any loop detects missing info → prompts User for just that piece

## Context Areas

### 1. Client SDLC Controls (`docs/engagement/sdlc-controls.md`)

How this client builds and ships software. **The team operates on leading practice defaults (`docs/sdlc-defaults.md`) from day one.** Client SDLC overrides specific areas where it provides explicit detail — wherever the client is silent, defaults remain in effect.

**SM's job here is NOT to fill every field.** It's to identify where the client's practice differs from our defaults and document those overrides.

```markdown
## Source Control
- Git workflow: [trunk-based / GitFlow / feature-branch / other]
  DEFAULT: trunk-based with short-lived feature branches
- Branch protection: [rules]
  DEFAULT: main protected, CI + 1 approval required
- PR review requirements: [N approvers, who]
  DEFAULT: 1 reviewer, automated checks pass
- Merge strategy: [squash / merge / rebase]
  DEFAULT: squash merge

## Change Management
- Change approval process: [CAB / lightweight / none]
  DEFAULT: no CAB; automated gates + User approval for staging/prod
- CAB cadence: [when it meets]
  DEFAULT: n/a
- Lead time for changes: [N days]
  DEFAULT: zero (deploy-on-green)
- Emergency change process: [expedited path]
  DEFAULT: same pipeline, same gates, no shortcuts

## Security Gates
- AppSec review required: [yes/no, when]
  DEFAULT: automated SAST every PR, DAST in staging
- Penetration testing: [frequency, who]
  DEFAULT: not scheduled (automated security tests cover)
- Vulnerability scanning: [tool, when it runs]
  DEFAULT: every build, block on high/critical
- Code signing: [required? approach]
  DEFAULT: not required

## Quality Gates (Their Standards)
- Code coverage threshold: [their standard — ours is 100%]
  DEFAULT: 100% line + branch (team's own standard)
- Static analysis: [tool, what blocks merge]
  DEFAULT: linter + formatter, zero warnings
- Dependency scanning: [tool, policy]
  DEFAULT: lockfile committed, no high/critical CVEs
- Performance testing: [when required, who runs]
  DEFAULT: NFR scenarios run every build

## Release Process
- Release cadence: [continuous / weekly / sprint / scheduled]
  DEFAULT: continuous delivery
- Release windows: [if applicable]
  DEFAULT: none (deploy any time)
- Rollback authority: [who can approve]
  DEFAULT: automated triggers + User decision
- Incident response: [process, contacts]
  DEFAULT: rollback first, investigate second, fix via normal pipeline
```

**After capturing client SDLC**, SM documents the effective practice for each area:
```markdown
## Effective Practice: [Area]
- Practice: [what's in effect]
- Source: [client-specified | default]
- Override reason: [if client differs from default, why]
```

### 2. Environment Strategy & Access (`docs/engagement/environments.md`)

SM selects an environment strategy based on what's available. See `docs/environment-strategy.md` for full detail on each option.

**Strategy selection questions:**
```
1. Do you have a cloud account (AWS/Azure/GCP) with deploy permissions?
   → Yes: Cloud or Hybrid possible
   → No / pending: Local for now, can graduate later

2. Do you have a CI/CD platform set up (GitHub Actions, ADO, Jenkins)?
   → Yes: Pipeline exists (or can be extended)
   → No: Team will bootstrap one during first feature

3. Do you need to deploy to production as part of this engagement?
   → Yes: Cloud or Hybrid required eventually
   → No (POC/prototype): Local is fine

4. How many developers will work simultaneously?
   → 1: Any strategy works
   → 2+: Need isolation (ephemeral envs or local per-dev)
```

**Strategy outcomes:**
- **Local** → Docker Compose, no cloud. Pipeline = Makefile targets. Fast, zero cost.
- **Cloud** → Ephemeral per-branch + shared test/staging/prod. Full CI/CD.
- **Hybrid** → Docker locally + cloud for upper environments. Best of both.

**If no CI/CD pipeline exists:** SM notes that the first feature's `/design` and `/test-and-develop` loops will include pipeline creation as a deliverable.

After strategy selection, capture infrastructure detail:

```markdown
## Environment Strategy: [local / cloud / hybrid]

## Cloud Account (if applicable)
- Provider: [AWS / Azure / GCP / hybrid]
- Account/subscription: [ID]
- Region: [primary region]
- IAM access: [how devs/CI get permissions]
- Budget constraints: [if any]

## Environments Available
| Environment | Purpose | Access | Provisioning |
|---|---|---|---|
| dev | Developer sandbox | [how to access] | [self-service / request] |
| test | Integration testing | [how to access] | [who owns] |
| staging | Pre-prod mirror | [how to access] | [who owns] |
| prod | Production | [how to access] | [who deploys] |

## Local Development (if local or hybrid)
- Docker available: [yes/no, version]
- Machine resources: [RAM, CPU available for containers]
- Port conventions: [what ports are free]

## Network & Connectivity
- VPC / network topology: [description or diagram reference]
- Egress restrictions: [what can reach the internet]
- Service mesh / discovery: [if applicable]
- DNS: [conventions, who manages]

## Secrets & Certificates
- Secret management: [Vault / Secrets Manager / other]
- Certificate provisioning: [ACM / manual / Let's Encrypt]
- Rotation policy: [frequency]
- How dev team gets access to secrets: [process]

## CI/CD Infrastructure
- Pipeline platform: [GitHub Actions / CodePipeline / Jenkins / ADO / other]
- Runner/agent: [hosted / self-hosted / client-managed]
- Artifact registry: [ECR / Artifactory / other]
- How to onboard a new pipeline: [process]
```

### 3. Codebase Patterns (`docs/engagement/codebase-patterns.md`)

If extending an existing system (Scout found the high-level; this captures the hands-on detail):

```markdown
## Build & Tooling
- Build tool: [Gradle / Maven / npm / pip / other]
- Language version: [Java 17 / Node 20 / Python 3.12 / etc.]
- Package manager: [specific version/lockfile approach]
- Monorepo vs polyrepo: [structure]

## Test Infrastructure (What Exists)
- Test framework: [JUnit 5 / Jest / pytest / etc.]
- Test utilities/helpers: [shared fixtures, custom assertions]
- Mocking approach: [Mockito / jest.mock / unittest.mock]
- Integration test approach: [testcontainers / embedded / real services]
- Current coverage: [% and tool]

## Code Conventions
- Naming conventions: [file, class, method, variable]
- Project structure: [package layout, module boundaries]
- Error handling: [exceptions / Result types / error codes]
- Logging: [framework, levels, format]
- Documentation: [JSDoc / Javadoc / none / specific tool]

## Shared Libraries & SDKs
- Internal libraries: [list with purpose]
- API clients: [generated? hand-written? shared?]
- Common patterns: [base classes, decorators, middleware]

## Database & Data
- Database: [type, version]
- Migration tool: [Flyway / Liquibase / Prisma / Alembic / etc.]
- ORM: [Hibernate / Prisma / SQLAlchemy / none]
- Connection management: [pooling, config]

## Observability (What Exists)
- Logging: [tool + destination]
- Metrics: [tool + dashboards]
- Tracing: [tool + instrumentation]
- Alerting: [tool + notification channels]
```

### 4. Test Data Strategy (`docs/engagement/test-data.md`)

How test data is sourced and managed:

```markdown
## Data Constraints
- Can production data be used: [yes / no / anonymized only]
- PII handling: [masking / tokenization / synthetic-only]
- Data retention in test envs: [policy]
- Regulatory constraints on test data: [GDPR / HIPAA / etc.]

## Data Sources
- Synthetic generation: [approach / tool]
- Anonymized production snapshots: [if allowed, process]
- Reference data: [where maintained, how refreshed]
- Third-party test accounts: [sandbox APIs, credentials]

## Data Management
- Test database reset approach: [per-test / per-suite / manual]
- Fixture strategy: [factories / seeders / snapshots]
- Data volume for perf testing: [representative size]
- Shared vs isolated test data: [approach]
```

### 5. Team Integration (`docs/engagement/team.md`)

Who the dev team works with:

```markdown
## Client Contacts
| Role | Person | Channel | Availability |
|---|---|---|---|
| Product owner / decisions | [name] | [Slack/Teams/email] | [hours/timezone] |
| Technical lead / reviews | [name] | [channel] | [availability] |
| Platform / infra | [name] | [channel] | [availability] |
| Security / AppSec | [name] | [channel] | [availability] |
| Release authority | [name] | [channel] | [availability] |

## Communication
- Primary channel: [Slack workspace/channel, Teams, etc.]
- Async vs sync preference: [client's style]
- Standup / ceremony expectations: [what they expect]
- Escalation path: [when something is blocked]

## Review & Approval
- PR reviewers: [who, turnaround time expected]
- Architecture review: [when needed, who]
- Security review: [when needed, who, lead time]
- Release approval: [who, what environment]

## Handoff & Support
- Documentation expectations: [runbooks? wiki? ADRs?]
- Knowledge transfer plan: [when, format]
- Production support model: [who owns after delivery]
```

### 6. Observability & Monitoring (`docs/engagement/observability.md`)

How to monitor what we build:

```markdown
## Tools
- Monitoring: [CloudWatch / Datadog / Grafana / Splunk / other]
- Alerting: [PagerDuty / OpsGenie / Slack / other]
- Logging: [CloudWatch Logs / ELK / Splunk / other]
- Tracing: [X-Ray / Jaeger / OpenTelemetry / other]
- APM: [tool if applicable]

## Standards
- SLOs/SLIs defined: [yes/no, where documented]
- Dashboard templates: [exists? standard format?]
- Log format: [structured JSON / plaintext / standard]
- Correlation ID approach: [header name, propagation]
- Alert severity levels: [P1-P4 definitions]

## Targets for This Project
- Availability target: [99.9% / 99.95% / etc.]
- Latency target: [P50, P95, P99 thresholds]
- Error rate target: [threshold]
- Recovery time objective: [RTO]
- Recovery point objective: [RPO]
```

### 7. Systems of Record (`docs/engagement/systems-of-record.md`)

External systems the team integrates with. See `docs/systems-of-record.md` for full category reference.

**Ask about each in priority order:**

**P1 (before first feature):**
```markdown
## Requirements Management (Bidirectional)
- Tool: [Jira / ADO / Linear / none — repo only]
- URL: [base URL]
- Access: [API token / OAuth / service account]
- Project/Board: [identifier]
- Hierarchy: [Epic → Story → Subtask / custom]
- Workflow states: [mapping to team's states]
- Can team create stories: [yes / no / with approval]
- Fields: [acceptance criteria field, estimate field, labels]
```

**P2 (before first deploy):**
```markdown
## Test Management (Bidirectional)
- Tool: [Xray / Zephyr / TestRail / none — repo only]
- URL: [base URL]
- Access: [API token]
- Import format: [Cucumber JSON / JUnit XML / API calls]
- Linked to requirements via: [Jira link / direct / test plan]
- Evidence requirements: [pass/fail only? screenshots? logs?]
- Regulatory: [is test evidence required for audit?]

## Artifact Repository (Publish)
- Tool: [Artifactory / ECR / Nexus / GitHub Packages / none]
- URL: [base URL]
- Access: [credentials / IAM role]
- Versioning: [semver / commit-hash / date]
- Naming convention: [org/project/artifact:tag]
- Signing: [required? approach]
```

**P3 (before first release):**
```markdown
## Change Management
- Tool: [ServiceNow / Jira SM / manual / none]
- Process: [standard / normal / emergency]
- Lead time: [days]
- Pre-approved patterns: [any auto-approved deploys?]

## Security Scanning
- Tool(s): [SonarQube / Checkmarx / Snyk / etc.]
- CI integration: [existing? team sets up?]
- Finding management: [same tool / separate tracking]

## Documentation Platform (Publish)
- Tool: [Confluence / SharePoint / Notion / repo only]
- What must be published there: [runbooks? API docs? ADRs?]
- Access: [API / manual]
```

**P4 (ongoing):**
```markdown
## Communication
- Deploy notifications: [Slack channel / Teams / webhook URL]
- Team channel: [where to ask questions]
- Stakeholder updates: [channel / email list]

## Monitoring / Incidents
- Monitoring tool: [Datadog / CloudWatch / Grafana]
- Incident tool: [PagerDuty / OpsGenie / manual]
- Auto-incident on rollback: [yes / no]
```

**Not all are needed immediately.** SM captures what's known, notes what's missing, and asks again when the relevant loop needs it (P1 before refine, P2 before deploy, P3 before release).

### 8. Technical Debt & Known Issues (`docs/engagement/tech-debt.md`)

Living document — grows over iterations:

```markdown
## Known Fragile Areas
| Area | Risk | Mitigation |
|---|---|---|
| [component] | [what could break] | [approach — spike? extra tests?] |

## Planned Deprecations
| What | When | Impact on Our Work |
|---|---|---|

## Known Performance Bottlenecks
| Where | Symptom | Root Cause (if known) |
|---|---|---|

## Low Coverage Areas (Higher Risk)
| Area | Current Coverage | Risk |
|---|---|---|

## Pending Migrations
| What | Timeline | Conflict with Our Work? |
|---|---|---|
```

## The Initiation Loop

```
┌─────────────────────────────────────────────────────────┐
│  SM walks through each context area with User:          │
│                                                         │
│  For each area:                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │                                                   │  │
│  │  1. SM asks targeted questions about this area    │  │
│  │     (not a form dump — conversational)            │  │
│  │                                                   │  │
│  │  2. User provides what they know                  │  │
│  │     (partial answers are fine)                    │  │
│  │                                                   │  │
│  │  3. SM documents answers in the appropriate file  │  │
│  │                                                   │  │
│  │  4. SM flags gaps:                                │  │
│  │     "I don't have [X] yet. We'll need it for     │  │
│  │      [loop]. I'll prompt you when we get there."  │  │
│  │                                                   │  │
│  │  5. Move to next area                             │  │
│  │                                                   │  │
│  └───────────────────────────────────────────────────┘  │
│                                                         │
│  After all areas covered:                               │
│  SM summarizes: "Here's what I have, here's what's      │
│  missing, here's when we'll need it."                   │
│                                                         │
│  User approves: "Good enough to start."                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Gap-Fill Mode (Triggered by Other Loops)

When ANY loop needs context that doesn't exist in `docs/engagement/`:

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  [Any loop running]                                     │
│                                                         │
│  Loop checks: "Do I have what I need?"                  │
│    → Reads docs/engagement/<area>.md                   │
│    → Finds missing field or entire file missing         │
│                                                         │
│  Prompt to User:                                        │
│  "I'm in /design and I need to know [specific thing]   │
│  to proceed. Specifically: [question]."                 │
│                                                         │
│  Options:                                               │
│  1. User provides the answer → SM documents it         │
│  2. User says "skip for now" → SM flags as assumption  │
│     and continues with a stated default                 │
│  3. User says "I'll find out" → SM parks this,         │
│     continues what can proceed, and asks again later    │
│                                                         │
│  If User chose "skip" → SM documents the assumption:   │
│  "ASSUMED: [thing]. Based on: [default reasoning].     │
│   Override when actual answer is known."                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Context Check Protocol (Every Loop Must Follow)

Every loop, before starting substantive work, runs this check:

```
CONTEXT CHECK for /[loop-name]:

Required context:
  □ docs/engagement/sdlc-controls.md — [specific fields needed]
  □ docs/engagement/environments.md — [specific fields needed]
  □ docs/engagement/codebase-patterns.md — [specific fields needed]
  □ docs/engagement/test-data.md — [specific fields needed]
  □ docs/engagement/team.md — [specific fields needed]
  □ docs/engagement/observability.md — [specific fields needed]
  □ docs/engagement/systems-of-record.md — [specific systems needed]
  □ docs/discovery/context-package.md — [specific fields needed]

Status:
  ✅ Available: [list]
  ⚠️ Assumed (default): [list with stated assumptions]
  ❌ Missing (must ask User): [list — BLOCKS until answered]
```

## What Each Loop Needs from Engagement Context

| Loop | SDLC | Envs | Codebase | Test Data | Team | Observability | Tech Debt | Systems of Record |
|---|---|---|---|---|---|---|---|---|
| /refine | — | — | — | — | Product contact | — | Known risks | Requirements (Jira) |
| /spike | — | Sandbox | Existing patterns | — | Tech lead | — | Fragile areas | — |
| /design | — | Target arch | Full patterns | Strategy | Reviewers | Tools + targets | Full map | — |
| /test-and-develop | Review rules | Test env | Test infra | Full strategy | Reviewers | — | Coverage map | Test Mgmt (Xray) |
| /deploy-and-validate | Full SDLC | All envs | CI/CD patterns | Env data | Platform team | Full setup | — | Artifacts, Change Mgmt, Comms |
| /release | Change mgmt | Prod access | — | — | Release authority | Monitoring | — | All (close stories, publish evidence) |

## SDLC → Definition of Ready & Definition of Done (Automatic Enhancement)

When client SDLC controls are captured (area 1), SM **automatically** derives additional criteria for both the Definition of Ready (`docs/definition-of-ready.md`) and Definition of Done (`docs/definition-of-done.md`).

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  1. User provides SDLC controls (via /initiate or gap-fill)│
│                                                             │
│  2. SM reads docs/engagement/sdlc-controls.md              │
│                                                             │
│  3. SM derives criteria:                                    │
│     ┌─────────────────────────────────────────────────┐    │
│     │ SDLC Input          → DoR Enhancement           │    │
│     │────────────────────────────────────────────────│    │
│     │ PR review rules     → Reviewers identified      │    │
│     │ Security gates      → AppSec notified if needed │    │
│     │ Change management   → CAB timeline factored in  │    │
│     │ Release cadence     → Feature sized to fit      │    │
│     │ Arch review         → Review scheduled          │    │
│     │ Dep scanning        → Dependencies pre-approved │    │
│     └─────────────────────────────────────────────────┘    │
│     ┌─────────────────────────────────────────────────┐    │
│     │ SDLC Input          → DoD Enhancement           │    │
│     │────────────────────────────────────────────────│    │
│     │ PR review rules     → PR approved by N reviewers│    │
│     │ Security gates      → AppSec sign-off obtained  │    │
│     │ Change management   → CAB approval obtained     │    │
│     │ Code signing        → Artifacts signed          │    │
│     │ Static analysis     → SAST passes               │    │
│     │ Dep scanning        → No new high/critical CVEs │    │
│     │ Doc standards       → Documentation updated     │    │
│     │ Release approval    → Authority signed off      │    │
│     └─────────────────────────────────────────────────┘    │
│                                                             │
│  4. SM adds to SDLC-Derived tables in both documents       │
│                                                             │
│  5. SM presents to User:                                    │
│     "Based on your SDLC controls, I've added these         │
│      criteria to DoR and DoD: [list]. Approve?"            │
│                                                             │
│  6. User approves / adjusts → SM finalizes                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Mapping Rules

SM applies criteria selectively — not every SDLC control generates a criterion:
- **If** the client requires PR reviews → DoR gets "reviewers identified", DoD gets "PR approved"
- **If** the client has security gates → DoR gets "AppSec notified if applicable", DoD gets "AppSec signed off"
- **If** the client has change management → DoR gets "timeline factored", DoD gets "CAB approved"
- **If not applicable** (e.g., no CAB process) → no criterion added for that area

SM uses judgment — the goal is to ensure the team follows the client's process, not to add bureaucracy where the client hasn't required it.

## Living Knowledge (Grows Over Iterations)

After each iteration, SM updates `docs/engagement/` with what was learned:
- New codebase patterns discovered (→ `codebase-patterns.md`)
- Technical debt found (→ `tech-debt.md`)
- Test data approaches that work (→ `test-data.md`)
- Observability gaps filled (→ `observability.md`)
- New team contacts identified (→ `team.md`)

This means `/initiate` is never truly "done" — it runs fully at start, then enriches continuously.

## Invocation

```bash
/initiate                          — Full initiation (engagement start)
/initiate --area sdlc              — Focus on one area
/initiate --area environments      — Focus on one area
/initiate --area codebase          — Focus on one area
/initiate --area test-data         — Focus on one area
/initiate --area team              — Focus on one area
/initiate --area observability     — Focus on one area
/initiate --status                 — Show what's captured, what's missing, what's assumed
/initiate --assumptions            — Show all stated assumptions (need validation)
```
