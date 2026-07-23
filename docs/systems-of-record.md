---
version: 1
last_updated: 2026-07-23
updated_by: system
---

# Systems of Record

The AI team generates and consumes artifacts that must stay synchronized with external systems. This document defines the categories of external systems, the sync direction, and what the team needs to integrate.

**Key principle:** The repo is the team's working space, but it's NOT always the system of record. When a client's Jira IS the system of record for requirements, the team's `backlog/` is a working copy that must sync back. When Xray IS the system of record for test evidence, Paul's local test results must publish there.

## Sync Patterns

| Pattern | Direction | Example | Implication |
|---|---|---|---|
| **Bidirectional** | ↔ | Jira ↔ backlog | Changes flow both ways; need conflict strategy |
| **Publish** | → | Test results → Xray | Team writes to external system |
| **Consume** | ← | Requirements ← Jira | Team reads from external system |
| **Notify** | → | Deploy status → Slack | One-way notification, no state sync |

## System Categories

### 1. Requirements Management (Bidirectional)

**Typical tools:** Jira, Azure DevOps, Linear, Shortcut, Rally

**What the team does with it:**
- **Consumes:** Pull stories/features that need refinement, understand hierarchy (epic → story → subtask), read acceptance criteria written by product
- **Publishes back:** Update stories with refined scenarios, link to feature files, update status (in progress → done), create new stories for gaps/tech debt discovered during development
- **Creates:** New stories for: gaps identified during refinement, technical debt, defects found, features split during design

**What SM needs to know:**
```
Tool: [Jira / ADO / Linear / etc.]
Project/Board: [key or URL]
Access: [API token / OAuth / service account]
Hierarchy: [Epic → Story → Subtask / Custom levels]
Workflow: [States and transitions — what maps to our statuses]
Fields that matter:
  - Story points / estimate field: [name]
  - Acceptance criteria field: [name or in description]
  - Labels/components: [how features are categorized]
  - Sprint/iteration field: [if applicable]
  - Link types: [how to link stories to each other]
Custom fields the team must populate: [list]
Who creates stories: [team allowed? or only PO?]
Naming conventions: [ticket prefixes, title format]
```

**Sync mapping:**
| Team Artifact | External System | Sync Trigger |
|---|---|---|
| `backlog/backlog.md` items | Jira stories | /ingest (pull), /refine (update), /release (close) |
| `backlog/ready/<slug>/feature.md` | Jira acceptance criteria field | /refine exit (push scenarios to story) |
| Feature status (active/done) | Jira workflow transitions | Status changes (push) |
| New backlog items (gaps, debt) | New Jira stories | /refine, /test-and-develop, /challenge (create) |
| Traceability links | Jira story links | /test-and-develop (link test evidence) |

### 2. Test Management (Bidirectional)

**Typical tools:** Xray (for Jira), Zephyr, TestRail, qTest, Azure Test Plans, PractiTest

**What the team does with it:**
- **Publishes:** Test case definitions (from Gherkin scenarios), test execution results, coverage reports, defect links
- **Consumes:** Existing test cases (to avoid duplication), test plan structure, regulatory-required test evidence format
- **Syncs:** Test status must reflect reality — if Paul's tests pass in CI, the test management tool must show green

**What SM needs to know:**
```
Tool: [Xray / Zephyr / TestRail / etc.]
Access: [API token / OAuth / service account]
Project: [key or URL]
Integration with requirements tool: [how tests link to stories]
Test hierarchy: [Test Plan → Test Set → Test Case / or flat]
Execution tracking: [manual runs? automated results import?]
Evidence requirements: [screenshots? logs? just pass/fail?]
Regulatory needs: [is test evidence required for audit? format?]
Import format: [Cucumber JSON? JUnit XML? custom API?]
Who can create test cases: [team allowed? restricted?]
Naming conventions: [test case ID format]
```

**Sync mapping:**
| Team Artifact | External System | Sync Trigger |
|---|---|---|
| Gherkin scenarios | Test cases (Xray/Zephyr) | /refine exit (create/update test cases) |
| Step definitions | Test case steps | /test-and-develop (update with automation detail) |
| CI test results | Test execution records | Every CI run (publish results) |
| Coverage report | Test plan coverage | /test-and-develop, /deploy-and-validate |
| NFR test results | Performance/security test evidence | /deploy-and-validate (publish) |
| Defects found | Defect records linked to test cases | /fix-defect (create/link) |

### 3. Artifact Repository (Publish)

**Typical tools:** Artifactory, Nexus, AWS ECR, GitHub Packages, Azure Container Registry, npm registry, Maven Central

**What the team does with it:**
- **Publishes:** Versioned build artifacts (JARs, Docker images, npm packages), release metadata
- **Consumes:** Base images, shared libraries, dependency versions

**What SM needs to know:**
```
Tool: [Artifactory / ECR / Nexus / GitHub Packages / etc.]
Repository/registry: [URL]
Access: [credentials / IAM role / service account]
Artifact types: [Docker images / JARs / npm packages / etc.]
Versioning scheme: [semver / date-based / commit-hash / custom]
Naming convention: [org/project/artifact:tag format]
Retention policy: [how long are artifacts kept?]
Promotion model: [snapshot → release? separate repos per quality level?]
Signing requirements: [artifacts must be signed? with what?]
Who publishes: [CI only? developers can push?]
Immutability: [can published versions be overwritten?]
```

**Sync mapping:**
| Team Artifact | External System | Sync Trigger |
|---|---|---|
| Build output | Artifact in registry | Every CI build (publish) |
| Release artifact | Promoted/tagged artifact | /release (tag as production) |
| Container image | ECR/registry | /deploy-and-validate (build + push) |
| IaC packages (CDK) | CDK asset bucket / Artifactory | /deploy-and-validate |

### 4. Documentation Platform (Publish)

**Typical tools:** Confluence, SharePoint, Notion, GitBook, internal wiki

**What the team does with it:**
- **Publishes:** Architecture decisions, runbooks, API documentation, release notes, onboarding guides
- **Consumes:** Existing documentation (context for refinement/design)

**What SM needs to know:**
```
Tool: [Confluence / SharePoint / Notion / etc.]
Space/site: [URL or identifier]
Access: [API token / OAuth / service account]
Structure: [where does this project's documentation go?]
Templates: [required formats for ADRs, runbooks, etc.]
Who maintains after delivery: [handoff model]
Automation: [can we push from repo? or manual copy?]
What MUST be there: [vs. what can stay in repo]
```

**Sync mapping:**
| Team Artifact | External System | Sync Trigger |
|---|---|---|
| `docs/adr/*.md` | Confluence ADR page | /design exit (publish decision) |
| API contract | Confluence/GitBook API docs | /test-and-develop (auto-generate) |
| Runbook | Confluence ops runbook | /release (publish/update) |
| Release notes | Confluence release page | /release (publish) |

### 5. Change Management (Bidirectional)

**Typical tools:** ServiceNow, Jira Service Management, BMC Remedy, manual CAB

**What the team does with it:**
- **Creates:** Change records for environment promotions (especially staging/prod)
- **Consumes:** Approval status (is the change approved?), release windows, blackout periods
- **Updates:** Change status (implementing → complete), post-implementation review

**What SM needs to know:**
```
Tool: [ServiceNow / Jira SM / manual process / none]
Process: [standard change / normal change / emergency]
Template: [change record template or fields]
Lead time: [how far ahead must changes be submitted?]
Approvers: [CAB members, auto-approve criteria]
Integration: [API? email? manual form?]
Pre-approved patterns: [are some deploys pre-approved? criteria?]
Blackout periods: [dates/times when no changes allowed]
Rollback documentation: [what the change record needs for rollback plan]
```

**Sync mapping:**
| Team Artifact | External System | Sync Trigger |
|---|---|---|
| Deployment request | Change record (CR) | /deploy-and-validate (before staging/prod) |
| Deployment evidence | CR implementation notes | /deploy-and-validate (after success) |
| Rollback event | CR rollback notes | /release (if rollback triggered) |

### 6. Security & Compliance (Publish)

**Typical tools:** SonarQube, Checkmarx, Veracode, Snyk, Qualys, Prisma Cloud

**What the team does with it:**
- **Publishes:** Scan results, remediation evidence, compliance attestation
- **Consumes:** Security policies, vulnerability findings from other scans, compliance requirements

**What SM needs to know:**
```
Tool: [SonarQube / Checkmarx / Snyk / etc.]
Access: [API token / CI integration / agent-based]
Scan types: [SAST / DAST / SCA / container / IaC]
Integration point: [CI pipeline? separate scan? both?]
Finding management: [where are findings tracked? same tool or separate?]
SLA for remediation: [critical: X days, high: Y days, etc.]
Compliance evidence: [what needs to be preserved? for how long?]
Exemption process: [how to mark false positives or accept risk]
```

### 7. Monitoring & Incident Management (Notify + Consume)

**Typical tools:** PagerDuty, OpsGenie, Datadog, Splunk On-Call, ServiceNow ITSM

**What the team does with it:**
- **Configures:** Alert rules, escalation paths, dashboard creation
- **Consumes:** Incident context when diagnosing issues
- **Triggers:** Creates incidents on rollback or critical failures

**What SM needs to know:**
```
Tool: [PagerDuty / OpsGenie / Datadog / etc.]
Integration: [webhook / API / native CI integration]
Escalation path: [who gets paged, in what order]
Severity definitions: [P1-P4 criteria]
Auto-incident creation: [should deploy failures create incidents?]
Dashboard tool: [Grafana / Datadog / CloudWatch / etc.]
Access: [how does the team get dashboards/alerts configured?]
```

### 8. Communication (Notify)

**Typical tools:** Slack, Microsoft Teams, email, Discord

**What the team does with it:**
- **Notifies:** Deploy status, release announcements, test failures, incidents
- **Receives:** Questions from stakeholders, feedback, approval responses

**What SM needs to know:**
```
Tool: [Slack / Teams / etc.]
Channels: [where to post deploy notifications, where to ask questions]
Webhooks: [for CI/CD notifications]
Bots: [any existing bots the team should use]
Etiquette: [threading? @channel rules? hours?]
```

## How /initiate Uses This

During initiation, SM asks about systems of record as a SEPARATE area (not buried in SDLC or environments). For each system the client uses:

1. **Identify the tool** and what role it plays
2. **Determine sync direction** (bidirectional, publish, consume, notify)
3. **Capture access details** (API keys, tokens, URLs — stored securely)
4. **Map the integration points** (which loop triggers sync)
5. **Document in** `docs/engagement/systems-of-record.md`

## Impact on Team Operations

When systems of record are configured, loop behaviors change:

| Loop | Additional Behavior |
|---|---|
| `/ingest` | Pulls requirements from Jira (not just discovery) |
| `/refine` | Updates Jira stories with refined scenarios; creates tests in Xray |
| `/test-and-develop` | Publishes test results to Xray/TestRail on each CI run |
| `/deploy-and-validate` | Creates change records; publishes artifacts; notifies channels |
| `/release` | Closes Jira stories; publishes release notes to Confluence; creates final test evidence |
| `/fix-defect` | Creates/links defect in Jira; updates Xray with regression tests |

## Integration Priority

Not all integrations are needed immediately. SM should prioritize:

| Priority | Systems | Why First |
|---|---|---|
| **P1 (before first feature)** | Requirements (Jira), Source Control | Must know where requirements live and how code is managed |
| **P2 (before first deploy)** | Artifact Repository, CI/CD, Communication | Must publish artifacts and notify on deploys |
| **P3 (before first release)** | Test Management, Change Management, Security | Must provide evidence and approvals for production |
| **P4 (ongoing)** | Documentation, Monitoring, Incident Management | Important but not blocking early work |

## Template: `docs/engagement/systems-of-record.md`

```markdown
# Systems of Record

## Requirements Management
- Tool: [name]
- URL: [base URL]
- Access: [how — credentials stored in secrets manager]
- Sync: Bidirectional
- Project/Board: [identifier]
- Hierarchy: [structure]
- Workflow mapping: [their states → our states]
- Integration: [API / webhook / manual]

## Test Management
- Tool: [name]
- URL: [base URL]
- Access: [how]
- Sync: Bidirectional
- Import format: [Cucumber JSON / JUnit XML / API]
- Linked to requirements via: [Jira link type / direct / etc.]
- Evidence requirements: [what must be stored]

## Artifact Repository
- Tool: [name]
- URL: [base URL]
- Access: [how]
- Sync: Publish
- Naming: [convention]
- Versioning: [scheme]

## Change Management
- Tool: [name or "none"]
- Process: [standard/normal/emergency]
- Lead time: [days]
- Integration: [API / manual]

## Security Scanning
- Tool(s): [names]
- Integration: [CI pipeline / standalone]
- Finding management: [where tracked]

## Documentation
- Tool: [name or "repo only"]
- What must be there: [list]
- Access: [how]

## Communication
- Tool: [Slack / Teams]
- Channels: [deploy notifications, team, stakeholders]
- Webhooks: [URLs — stored in secrets manager]

## Monitoring / Incidents
- Monitoring: [tool]
- Alerting: [tool]
- Incident creation: [automatic / manual]
- Dashboards: [tool, access]
```
