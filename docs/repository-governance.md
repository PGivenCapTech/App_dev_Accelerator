---
version: 1
last_updated: 2026-07-24
updated_by: system
---

# Repository Governance

Platform-level controls that enforce the branching strategy and quality gates for ALL users of the repo — regardless of what tool they use (AI-assisted or not). These are configured during `/initiate` and apply immediately.

## Why This Is Done During Initiate (Not Later)

- Developers may start pushing code before the first feature completes
- Branch protection prevents accidental damage to main from day one
- Quality gates in CI prevent unverified code from merging
- PR templates guide contributors who weren't part of the AI team setup
- These controls protect the repo for non-AI-tool users and new team members

## What Gets Configured

### 1. Branch Protection (GitHub Rulesets)

```yaml
# .github/rulesets/main-protection.json (or configured via GitHub API / UI)
ruleset:
  name: "Protect main"
  target: branches
  conditions:
    ref_name:
      include: ["refs/heads/main"]
  rules:
    - type: pull_request
      parameters:
        required_approving_review_count: 1
        dismiss_stale_reviews_on_push: true
        require_last_push_approval: false
    - type: required_status_checks
      parameters:
        strict_status_checks_required: true
        required_status_checks:
          - context: "build"
          - context: "test"
          - context: "coverage-gate"
          - context: "traceability-gate"
          - context: "security-scan"
    - type: non_fast_forward  # Prevents force push
    - type: deletion          # Prevents branch deletion
```

### 2. Branch Naming Convention

```yaml
# .github/rulesets/branch-naming.json
ruleset:
  name: "Branch naming convention"
  target: branches
  conditions:
    ref_name:
      exclude: ["refs/heads/main"]
  rules:
    - type: branch_name_pattern
      parameters:
        operator: regex
        pattern: "^(feature|fix|refactor)/[a-z0-9-]+$"
        name: "Branch must be feature/, fix/, or refactor/ + kebab-case slug"
```

### 3. Merge Method Restriction

```
Repository Settings:
  Allow merge commits: ❌ Disabled
  Allow squash merging: ✅ Enabled (default commit message: PR title + description)
  Allow rebase merging: ❌ Disabled
  Auto-delete head branches: ✅ Enabled
```

### 4. PR Template

```markdown
<!-- .github/pull_request_template.md -->

## Scenario Reference

<!-- Which scenario(s) does this PR satisfy? Link to backlog item. -->
- Scenario: `backlog/ready/<slug>/feature.md` — [scenario name]

## What Changed

<!-- Brief description of the implementation approach -->

## Test Evidence

- [ ] All BDD scenarios pass
- [ ] All unit tests pass
- [ ] Coverage: 100% (line + branch)
- [ ] Traceability: 100% (scenario ↔ test ↔ code)
- [ ] No skipped or ignored tests
- [ ] NFR scenarios pass (if applicable)

## Quality Checklist

- [ ] Commit messages reference scenarios
- [ ] No secrets in code
- [ ] No TODO/FIXME without a linked backlog item
- [ ] No orphan code (every file traces to a requirement)

## Deployment Impact

- [ ] Database migration included (forward-compatible)
- [ ] Environment variables documented
- [ ] Breaking API changes: [none / described below]
```

### 5. CODEOWNERS

```
# .github/CODEOWNERS

# Quality gate definitions — require team consensus (human SM approval)
docs/definition-of-ready.md    @team-sm
docs/definition-of-done.md     @team-sm
docs/sdlc-defaults.md          @team-sm

# Engagement context — require SM approval for changes
docs/engagement/               @team-sm

# Pipeline and infrastructure — require senior review
.github/workflows/             @team-sm @team-leads
infra/                         @team-sm @team-leads

# Backlog priority — SM owns
backlog/backlog.md             @team-sm
```

**Note:** `@team-sm` and `@team-leads` are GitHub teams. If not available, use individual handles. SM configures these based on `docs/engagement/team.md`.

### 6. Required Status Checks (CI Pipeline)

The pipeline must include these checks as separate reportable statuses:

| Check | What It Verifies | Blocks Merge If |
|---|---|---|
| `build` | Code compiles, dependencies resolve | Build fails |
| `test` | All BDD + unit + integration tests pass | Any test fails |
| `coverage-gate` | Line + branch coverage = 100% | Coverage < 100% |
| `traceability-gate` | Every scenario has tests, every code file has a requirement | Any gap |
| `security-scan` | SAST + dependency scan clean | High/critical finding |
| `lint` | Code format and style | Any violation |
| `commit-lint` | Commit messages follow convention | Missing scenario reference |

These are defined in the pipeline workflow (GitHub Actions, ADO, etc.) and registered as required status checks on the branch protection rule.

### 7. Commit Message Convention

```
Format: <type>(<scope>): <description>

Types: feat, fix, refactor, test, infra, docs
Scope: scenario slug or area affected
Description: what and why (present tense)

Examples:
  feat(user-onboarding): add email validation step
  fix(payment-timeout): increase retry window to 30s
  refactor(notification-service): extract event publisher interface
  test(user-onboarding): add edge case for duplicate email

Rule: Every feat/fix/refactor MUST reference a scenario slug in scope.
```

Enforced by a commit-lint CI check that reads PR commit messages.

## Implementation by Platform

### GitHub

```bash
# SM runs during /initiate (via GitHub CLI)

# Set merge method
gh api repos/{owner}/{repo} -X PATCH \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=true

# Create branch protection (legacy API — or use rulesets for newer repos)
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --input branch-protection.json

# Or use rulesets (newer, more flexible)
gh api repos/{owner}/{repo}/rulesets -X POST \
  --input .github/rulesets/main-protection.json
```

### Azure DevOps

```
Branch policies on main:
  - Require minimum 1 reviewer
  - Check for linked work items: required
  - Build validation: required (pipeline must pass)
  - Merge type: squash only
  - Reset votes on new push: enabled
```

### GitLab

```
Protected branch (main):
  - Push access: No one
  - Merge access: Maintainers + approval required
  - Pipeline must pass
  - All discussions resolved
```

## When to Configure

```
/initiate
  ├── ... (SDLC, environments, team, etc.)
  │
  ├── Repository Governance (NEW — after repo exists)
  │   ├── Configure branch protection / rulesets
  │   ├── Set merge method to squash-only
  │   ├── Enable auto-delete branches
  │   ├── Create PR template
  │   ├── Create CODEOWNERS (based on team.md)
  │   ├── Configure branch naming rules
  │   └── SM confirms: "Governance configured. All pushes
  │       to main now require PR + CI + approval."
  │
  └── ... (continue with remaining initiation)
```

## Adapting to Client's Existing Controls

If the client already has branch protection:
- SM reads existing rules
- Compares against our defaults
- Proposes additions (coverage gate, traceability gate) that don't conflict
- Client's existing reviewers/rules are preserved
- SM adds accelerator gates alongside, not replacing

If the client has DIFFERENT conventions:
- SM captures their convention as an SDLC override
- Adapts naming rules, merge method, template to match
- Quality gates (coverage, traceability) are ADDED regardless — non-negotiable
- Commit message format adapts to their existing standard

## Verification

After configuration, SM verifies:

```
GOVERNANCE CHECK:
  ✅ Main branch protected (no direct push)
  ✅ PR required for merge
  ✅ At least 1 approval required
  ✅ Status checks required: [list]
  ✅ Squash merge only
  ✅ Auto-delete branches enabled
  ✅ Branch naming enforced
  ✅ PR template exists
  ✅ CODEOWNERS configured
  ⚠️ [Any items that couldn't be configured — explain why]
```
