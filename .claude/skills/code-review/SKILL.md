---
name: code-review
description: Review code commits and branches for acceptance criteria coverage, architectural alignment, security, and test coverage. Loads domain language from CONTEXT.md and maps the codebase architecture via a sub-agent before reviewing. Use when reviewing a specific commit, branch, or pull request.
---

# Code Review Skill

**Usage:** specify a commit SHA, branch name, or PR number.

## Review Workflow

### 0. Load Domain & Architecture Context

- [ ] Read `CONTEXT.md` (ubiquitous language, architecture style) and `docs/adr/` if present.
- [ ] Spawn an **`explore`** sub-agent:

```
Map the architecture of this codebase at: <REPO_ROOT>
Return (≤30 lines): top-level structure, architectural pattern, key modules + roles, dependency direction, ports/adapters. Skip test and generated files.
```

### 1. Gather Code Changes
- [ ] Fetch diff; list modified/added/deleted files.

### 2. Acceptance Criteria Coverage
- [ ] Find criteria in: PR description, linked issue, commit message, or `docs/` specs.
- [ ] For each criterion: is it implemented? Which file/line? Does a test cover it?
- [ ] Flag any criterion that is missing, partial, or untested.

> If no explicit criteria exist, infer intent from PR title/issue and state that clearly.

### 3. Architectural Alignment

> Evaluate against the pattern found in Step 0.

- [ ] New code lives in the correct architectural layer; no infrastructure leaking into domain
- [ ] Dependency direction matches the project's rules; no new circular deps
- [ ] New integrations use existing port/adapter interfaces, not direct coupling
- [ ] New abstractions follow existing patterns (repo, use-case, command/query, etc.)
- [ ] Identifiers match ubiquitous language from `CONTEXT.md`
- [ ] No ADR in `docs/adr/` is violated

### 4. Security
- [ ] No hardcoded secrets or credentials
- [ ] Inputs validated; no injection risks (SQL, shell, template)
- [ ] Auth/authz checks present on protected paths
- [ ] No sensitive data in logs or error messages

See [REFERENCE.md](REFERENCE.md#security-checklist) for patterns.

### 5. Clean Code
- [ ] Obvious SRP/DRY violations
- [ ] Naming that obscures intent
- [ ] Functions too long or deeply nested to reason about

### 6. Performance
- [ ] N+1 queries or missing indexes
- [ ] O(n²)+ algorithms in hot paths

### 7. Tests
- [ ] Happy path covered
- [ ] Key edge cases covered (nulls, boundaries, error conditions)
- [ ] AC criteria from Step 2 each have a corresponding test

### 8. Documentation
- [ ] Behaviour changes reflected in README / docs
- [ ] Architecture docs updated for structural changes
