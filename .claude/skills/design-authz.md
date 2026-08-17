---
name: design-authz
description: Policy-based authorization design loop — model complex RBAC + ABAC, consolidate role explosion, write access scenarios as Gherkin, implement as tested policy-as-code.
allowed-tools: [Read, Write, Edit, Bash, Agent, WebFetch, WebSearch]
user-invocable: true
---

# /design-authz — Policy-Based Authorization Design Loop

The **design-authz** loop designs complex authorization models where simple RBAC leads to role explosion. It produces a consolidated policy model (RBAC base + ABAC overlay), access scenarios as Gherkin, and tested policy-as-code using engines like Cerbos, OPA/Rego, Cedar, or Casbin.

This is NOT "set up auth" — authentication is separate. This is about designing the RULES that govern who can do what, where, when, and ensuring those rules are externalized, tested, and auditable.

## Context Check (Before Starting)

Before starting authorization design, verify:
- `docs/engagement/team.md` — Who defines access rules? Security team? Product owner?
- Domain model from `/design` — Resource types, ownership, relationships
- API design — Actions available per resource
- Identity provider documentation — What attributes/claims come with the token (roles, groups, team, region)

If ANY required context is missing → prompt User (see `/initiate` gap-fill protocol).

## Participants

| Role | Agent | Contribution |
|---|---|---|
| **Policy architect** | Archie | Models the authorization space, selects engine, designs decision points |
| **Scenario writer** | Igor | Writes access scenarios as Given/When/Then |
| **Security edge cases** | Paul | Probes for privilege escalation, default-allow paths, missing denials |
| **Security reviewer** | Cissi | Least privilege, separation of duties, audit completeness |
| **Navigator** | User | Approves access rules, confirms business intent |

## Authorization Contract (Entry Criteria)

Every authorization design starts with:

```
Subjects:       [Who acts — users, service accounts, API keys]
  Attributes:   [role, team, region, org-level, department]
Resources:      [What's acted upon — entities in the domain model]
  Attributes:   [type, owner, region, sensitivity, project, phase]
Actions:        [What can be done — CRUD + domain-specific]
  Examples:     [view, edit, create, delete, assign, approve, escalate, admin]
Contexts:       [Conditions that modify access]
  Examples:     [own-team, own-region, delegated, emergency, time-bound]
Existing Roles: [Current role definitions from client — often bloated]
Target Engine:  [Cerbos, OPA/Rego, Cedar, Casbin, or custom]
```

## The Loop

```
┌─────────────────────────────────────────────────────────────┐
│  1. MODEL THE AUTHORIZATION SPACE (Archie)                  │
│     - Subject taxonomy (role, team, region, org level)       │
│     - Resource taxonomy (type, ownership, sensitivity)       │
│     - Action catalog (view, edit, assign, approve, admin)    │
│     - Context rules (scoping by attribute match)             │
│     User approves: "This captures our access model"          │
│                                                             │
│  2. CONSOLIDATE ROLES (Archie + User)                       │
│     - Identify redundant roles (same perms, different names) │
│     - Identify attribute-driven roles (same role, scoped     │
│       by region/team — collapse into role + attribute)        │
│     - Target: 10-20 base roles + ABAC scoping               │
│     - NOT 66 unique hardcoded roles                          │
│     User approves: "This consolidation is correct"           │
│                                                             │
│  3. WRITE ACCESS SCENARIOS (Igor)                           │
│     - Happy paths: allowed access for each role             │
│     - Denials: cross-region, cross-team, privilege boundary  │
│     - Delegation: user grants subset to another              │
│     - Emergency: break-glass with mandatory audit            │
│     - Service accounts: scoped to their service only         │
│     User approves: "These rules match business intent"       │
│                                                             │
│  4. SECURITY REVIEW (Cissi + Paul)                          │
│     Cissi checks:                                            │
│     - Least privilege (no default-allow paths)               │
│     - Separation of duties (approve ≠ create)                │
│     - Audit trail completeness                               │
│     - Emergency access procedures documented                 │
│     - Token lifetime and session management                  │
│     Paul probes:                                             │
│     - Can user escalate by combining roles?                  │
│     - What if attribute is null/missing?                     │
│     - What if token is stale (attributes changed since auth)?│
│     - Can service account be used as user proxy?             │
│                                                             │
│  5. IMPLEMENT AS POLICY TESTS (Paul)                        │
│     - Every scenario → policy test case                      │
│     - Run against policy engine (playground or test server)  │
│     - Deploy policies alongside application code             │
│     - Coverage: which policy rules are never triggered?       │
│                                                             │
│  6. IMPLEMENT INTEGRATION (Dmitri)                          │
│     - Policy engine middleware (Cerbos sidecar / OPA daemon) │
│     - Decision point placement (gateway vs. service vs. data)│
│     - Audit logging (decision + context + timestamp)         │
│     - Emergency override mechanism (break-glass)             │
│     - Policy deployment pipeline (version, test, deploy)     │
│     - Defense in depth: database RLS as backstop             │
│                                                             │
│  User validates: "Access works as intended in practice"      │
└─────────────────────────────────────────────────────────────┘
```

## Access Scenario Format (Igor)

```gherkin
@authz @role:project-manager @region:americas
Scenario: Project manager can edit tasks in their region
  Given a user with role "project-manager" and region "americas"
  And a task belonging to project "Hotel-ABC" in region "americas"
  When the user attempts to edit the task
  Then access is allowed

@authz @role:project-manager @region:americas @denial
Scenario: Project manager cannot edit tasks in another region
  Given a user with role "project-manager" and region "americas"
  And a task belonging to project "Hotel-XYZ" in region "eame"
  When the user attempts to edit the task
  Then access is denied
  And the denial is logged with reason "region mismatch"

@authz @delegation
Scenario: Delegated user can act within delegation scope
  Given user "alice" has delegated "task-edit" on project "Hotel-ABC" to user "bob"
  And the delegation is active (not expired)
  When "bob" attempts to edit a task in project "Hotel-ABC"
  Then access is allowed
  And the audit log records "delegated access" with delegator "alice"

@authz @emergency @audit
Scenario: Emergency override requires audit justification
  Given a user with role "admin" and emergency-override enabled
  When the admin accesses a restricted resource
  Then access is allowed
  And a mandatory audit entry is created with justification field
  And the security team is notified
```

## Authorization Patterns

| Pattern | When to Use | How |
|---|---|---|
| **RBAC base** | Broad capability groups | Roles grant action categories (viewer, editor, manager, admin) |
| **ABAC overlay** | Contextual scoping | Attributes narrow RBAC (editor + region=americas = edit only in americas) |
| **Delegation** | Temporary authority transfer | User grants subset of their permissions to another, time-bound |
| **Hierarchical** | Organizational inheritance | Org → region → team → project (higher inherits lower within scope) |
| **Resource-owner** | Creator privileges | Creator gets admin on resources they create |
| **Time-bound** | Temporary elevated access | Access grant with TTL, auto-revokes, audit on grant and revoke |
| **Break-glass** | Emergency override | Bypass normal rules with mandatory justification + alert |

## Rules

- **Default deny** — explicit allow required for every access path. No implicit permissions.
- **Externalized policies** — authorization logic lives in the policy engine, not application code. Application calls the engine for a decision.
- **Every decision audited** — allow AND deny decisions logged with full context (subject, resource, action, attributes, timestamp, decision, reason).
- **Policies are code** — versioned in git, tested in CI, deployed via pipeline. Not configured in a UI.
- **Consolidate before implementing** — don't encode role explosion into policy. Collapse 66 roles into 15 roles + attribute-based scoping FIRST.
- **Defense in depth** — policy engine for application-layer decisions + database RLS as a backstop. Belt AND suspenders.
- **Stale attributes** — define cache TTL for user attributes. What happens if a user changes teams but their token still says the old team? Handle explicitly.
- **Service accounts are subjects too** — every service account has explicit scoped permissions. No service account gets admin.

## Policy Engine Selection

| Engine | Language | Deployment | Strengths | Best For |
|---|---|---|---|---|
| **Cerbos** | YAML policies | Sidecar or embedded | Simple policy language, PDP pattern, Playground | Teams wanting readable policies without learning a DSL |
| **OPA (Rego)** | Rego | Daemon or sidecar | Extremely expressive, widely adopted, data-driven | Teams comfortable with a policy DSL, complex rules |
| **Cedar** | Cedar | Library (Rust/Java) | Formally verified, AWS-backed, fast | High-assurance environments, AWS-heavy stacks |
| **Casbin** | Model + Policy files | Library (many languages) | Flexible model system, easy to start | Simpler RBAC/ABAC without full PDP infrastructure |

Selection criteria: team familiarity > expressiveness > deployment model > ecosystem.

## Outputs

```
docs/authz/
  authz-model.md          — Subject/resource/action taxonomy, consolidated role matrix, ABAC rules
  role-consolidation.md   — Before/after role mapping (66 → 15 + attributes)
  decision-points.md      — Where in the architecture decisions are made (gateway/service/data)
  
features/authz/
  access-scenarios.feature  — Gherkin scenarios for all access paths
  denial-scenarios.feature  — Gherkin scenarios for all denial paths
  delegation.feature        — Delegation grant/revoke/expiry scenarios
  emergency.feature         — Break-glass and override scenarios

policies/
  roles.yaml (or .rego)     — Role definitions
  resources.yaml            — Resource type policies
  conditions.yaml           — ABAC condition rules
  
tests/authz/
  policy-tests/             — Test cases matching every Gherkin scenario
  coverage-report.md        — Which policy rules are exercised by tests
```

## Invocation

```bash
# Full authorization design from role matrix
/design-authz "Design authorization for 66 roles across 11 teams and 3 regions"

# Consolidate existing role explosion
/design-authz --consolidate "Collapse 66 roles into base RBAC + ABAC scoping"

# Add delegation to existing model
/design-authz --extend "Add delegation and emergency override to existing authz model"

# Review existing policies for gaps
/design-authz --review "Audit current policy set for missing denials or escalation paths"
```
