---
name: bdd-behave
description: Parse Gherkin BDD feature files and generate missing Python step definition functions. Use when working with Behave tests, writing BDD scenarios, or implementing missing test steps.
---

# BDD Behave Skill

Transform Gherkin feature files into Python step definitions by analyzing what steps already exist and generating what's missing.

## Quick start

1. **Paste your test content** - Provide BDD tests in any format (feature file, plain text, or existing Python steps)
2. **Skill validates/creates feature file** - Converts to proper `.feature` format if needed, validates Gherkin syntax
3. **Provide Python steps file** - Share existing `features/steps/steps.py` (or skill creates one if missing)
4. **Get complete setup** - Skill generates feature file and Python function stubs for missing steps

## Workflow

### 0. Validate and create feature file
When user pastes test content:
1. **Check format** - Is it already valid Gherkin (.feature format)?
2. **If plain text/mixed** - Convert to proper Gherkin syntax with Feature/Scenario structure
3. **Validate structure** - Ensure:
   - File starts with `Feature: <description>`
   - Scenarios use `Scenario: <description>`
   - Steps start with `Given`, `When`, `Then`, `And`, or `But`
   - Proper indentation (2 spaces)
4. **Create file** - If no feature file exists, create at `features/login.feature` (or appropriate name)

**Valid feature file structure:**
```gherkin
Feature: Short feature description
  Background: (optional - runs before each scenario)
    Given some setup

  Scenario: First scenario name
    Given initial condition
    When action occurs
    Then expected result
    And additional check

  Scenario: Second scenario name
    Given different condition
    When different action
    Then different result
```

### 1. Extract steps from feature file
Look for Gherkin keywords:
- `Given` - Initial context/setup
- `When` - Action/trigger
- `Then` - Expected result
- `And` / `But` - Continuation of previous step

Example feature:
```gherkin
Feature: User login
  Scenario: Valid credentials
    Given a user with username "alice" and password "secret"
    When the user logs in with "alice" and "secret"
    Then the user should be authenticated
    And the session should contain user data
```

### 2. Extract step definitions from Python file
Parse existing `features/steps/steps.py` (or create if missing) to find decorator patterns:
```python
from behave import given, when, then

@given('a user with username "{username}" and password "{password}"')
def step_create_user(context, username, password):
    pass
```

**If no steps file exists**, create `features/steps/__init__.py` and `features/steps/steps.py`

### 3. Identify missing steps
Compare feature file steps with existing Python decorators. Flag steps with no matching function.

### 4. Generate function stubs
Create Python functions with:
- Correct `@given`, `@when`, `@then` decorator matching the Gherkin text
- Regex patterns for parameterized steps (e.g., `"{string}"`, `"{int}"`)
- Docstring noting what the step should do
- `pass` or `raise NotImplementedError()` as placeholder

Example generated function:
```python
@when('the user logs in with "{username}" and "{password}"')
def step_user_logs_in(context, username, password):
    """When the user logs in with credentials."""
    raise NotImplementedError()
```

## Step types and parameter patterns

| Step Text | Pattern | Python |
|-----------|---------|--------|
| `Given a user "alice"` | Quoted string | `"{string}"` |
| `Given 5 items` | Bare number | `"{int}"` |
| `Given a list:` (table follows) | Table | `context.table` |
| `Given a data:` (docstring follows) | Multiline string | `context.text` |

## Common patterns

**Named parameters:**
```gherkin
Given a user with email "{email}" and role "{role}"
```
→ Generate with regex: `@given('a user with email "([^"]*)" and role "([^"]*)"')`

**Data tables:**
```gherkin
Given these users exist:
  | name  | role  |
  | alice | admin |
  | bob   | user  |
```
→ Function receives `context.table` with rows

**Docstrings:**
```gherkin
Given a configuration file:
  """
  [settings]
  debug=true
  """
```
→ Function receives `context.text` with multiline content

## Gherkin validation checklist

When converting or creating a feature file, verify:

- [ ] File has `.feature` extension
- [ ] Starts with `Feature: ` line (title case)
- [ ] Each scenario starts with `Scenario: ` (title case)
- [ ] All steps start with `Given`, `When`, `Then`, `And`, or `But`
- [ ] Proper indentation (2 spaces per level)
- [ ] No trailing whitespace
- [ ] Steps are complete sentences (not fragments)
- [ ] One assertion concept per step (not multiple checks)

**Common mistakes to fix:**
```gherkin
# ❌ WRONG - Missing Feature keyword
Scenario: Login
  Given user exists

# ✅ CORRECT
Feature: User Login
  Scenario: Login succeeds
    Given user exists

# ❌ WRONG - Inconsistent indentation
Feature: Test
  Scenario: Test
Given step

# ✅ CORRECT
Feature: Test
  Scenario: Test
    Given step

# ❌ WRONG - Step doesn't start with keyword
  user logs in

# ✅ CORRECT
  When user logs in
```

## Project structure

Behave expects this directory layout:
```
project/
├── features/
│   ├── __init__.py
│   ├── login.feature          # Feature files here
│   ├── checkout.feature
│   └── steps/
│       ├── __init__.py
│       ├── steps.py           # Step definitions
│       ├── auth_steps.py      # Optional: organize by domain
│       └── cart_steps.py
├── environment.py             # Optional: setup/teardown
└── behave.ini                 # Optional: config
```

## Workflow tips

- **Run behave first** to see which steps are missing: `behave features/user_login.feature`
- **Match step text exactly** - Behave matches on the decorated string, so punctuation matters
- **Use parameterization** to reduce function count (e.g., one function handles multiple scenarios)
- **Organize by domain** - Put user-related steps in `features/steps/users.py`, auth steps in `features/steps/auth.py`

## Next steps

Once stubs are generated:
1. Copy functions into your `features/steps/` file
2. Run `behave` again to verify steps are found
3. Implement each function body with actual test logic
4. Run full suite: `behave`

See [EXAMPLES.md](EXAMPLES.md) for complete feature file → Python code examples.

See [REFERENCE.md](REFERENCE.md) for detailed validation rules, feature file creation, and debugging.
