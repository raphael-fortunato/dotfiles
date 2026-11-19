---
name: code-review
description: Review code commits and branches for clean code, SOLID principles, architectural alignment, and technical debt. Validates documentation updates and test coverage (happy paths and edge cases). Use when reviewing a specific commit, branch, or pull request.
---

# Code Review Skill

## Quick Start

To perform a comprehensive code review:

```
1. Specify the target: commit SHA, branch name, or pull request
2. Provide repository context (owner, repo name)
3. Request detailed analysis focusing on:
   - Code quality & SOLID principles
   - Architectural alignment
   - Documentation updates
   - Test coverage
```

**Example:**
> Review the changes in commit abc123def456 in the my-repo repository for clean code, SOLID principles, architectural fit, and test coverage.

## Review Workflow

### 1. Gather Code Changes
- [ ] Fetch diff for the commit/branch/PR
- [ ] Identify all modified and added files
- [ ] Note any deletions or structural changes

### 2. Clean Code & SOLID Analysis
- [ ] **Single Responsibility Principle**: Each function/class has one reason to change
- [ ] **Open/Closed Principle**: Code is open for extension, closed for modification
- [ ] **Liskov Substitution**: Subclasses can replace base classes without breaking behavior
- [ ] **Interface Segregation**: Interfaces are specific, not bloated
- [ ] **Dependency Inversion**: Dependencies flow toward abstractions, not concrete details
- [ ] **DRY (Don't Repeat Yourself)**: No unnecessary code duplication
- [ ] **Naming**: Variables, functions, classes have clear, intention-revealing names
- [ ] **Function Size**: Functions are small and focused (typically under 20 lines)
- [ ] **Complexity**: Cyclomatic complexity is reasonable; no deeply nested logic

### 3. Architectural Alignment
- [ ] Changes fit the existing codebase structure and patterns
- [ ] No inconsistency with established module organization
- [ ] Respects dependency graph (no circular dependencies)
- [ ] Follows project conventions (naming, file structure, patterns)
- [ ] No violation of architectural layers (if applicable)

### 4. Technical Debt Assessment
- [ ] No hardcoded values that should be configurable
- [ ] No "quick fix" patterns that indicate shortcuts
- [ ] Error handling is explicit and graceful
- [ ] No commented-out code or debug statements left behind
- [ ] Performance implications considered for new code

### 5. Documentation Review
- [ ] README or design docs updated if behavior changes
- [ ] Docstrings/comments added for complex logic
- [ ] Type hints or annotations present (where applicable)
- [ ] API contracts documented
- [ ] Migration guides added if breaking changes
- [ ] Architecture docs updated if structural changes occur

### 6. Test Coverage Analysis
- [ ] Unit tests cover happy path scenarios
- [ ] Edge cases tested:
  - Boundary conditions
  - Null/empty inputs
  - Error conditions
  - Off-by-one scenarios
- [ ] Tests verify behavior, not implementation details
- [ ] Mock dependencies used appropriately
- [ ] No flaky or overly implementation-specific tests
- [ ] Test names are descriptive and indicate what is being tested

## Review Output Format

For each finding, include:

```
**Category**: [Clean Code | Architecture | Technical Debt | Documentation | Tests]
**Severity**: [Critical | High | Medium | Low]
**File**: path/to/file.ext
**Line**: [line number or range, if applicable]
**Issue**: Brief description of the problem
**Suggestion**: Recommended fix or improvement
```

## Examples of Findings

### Example 1: SOLID Violation
```
**Category**: Clean Code (SRP Violation)
**Severity**: High
**File**: src/UserService.ts
**Line**: 42-89
**Issue**: UserService handles both user authentication and email notifications, violating Single Responsibility Principle.
**Suggestion**: Extract email notifications into a separate NotificationService. Have UserService delegate to it.
```

### Example 2: Documentation Gap
```
**Category**: Documentation
**Severity**: Medium
**File**: docs/architecture.md
**Issue**: New caching layer introduced in CacheManager.py is not documented in architecture guide.
**Suggestion**: Add section describing cache strategy, TTL, invalidation policy, and trade-offs.
```

### Example 3: Missing Edge Case Test
```
**Category**: Tests
**Severity**: Medium
**File**: tests/PaymentProcessor.test.ts
**Line**: [add test for negative amount]
**Issue**: Tests cover happy path but don't validate edge case: negative payment amounts should be rejected.
**Suggestion**: Add test case: expect(() => processor.charge(-50)).toThrow('Amount must be positive')
```

## When to Use This Skill

- ✅ Review a specific commit for quality and fit
- ✅ Assess a feature branch before merging
- ✅ Evaluate a pull request for architectural alignment
- ✅ Check if technical debt is increasing
- ✅ Verify documentation keeps pace with code changes
- ✅ Ensure test coverage matches implementation

## Advanced Features

For more details on SOLID principles and clean code metrics, see [REFERENCE.md](REFERENCE.md).
