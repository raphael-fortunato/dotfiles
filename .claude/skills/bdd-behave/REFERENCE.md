# BDD Behave Reference

## Feature file validation and creation

### When to create a feature file

1. User pastes raw test descriptions (not in `.feature` format)
2. User provides scenario steps in prose/bullet points
3. No `features/` directory exists yet
4. Steps are mixed in with Python code comments

### Conversion process

**Input (raw prose):**
```
User login test:
- First I need to set up a user with email alice@test.com and password secret
- Then the user logs in with those credentials
- The user should be authenticated
- The session should be created
```

**Output (Gherkin `.feature` file):**
```gherkin
Feature: User login
  Scenario: User logs in successfully
    Given a user with email "alice@test.com" and password "secret"
    When the user logs in with those credentials
    Then the user should be authenticated
    And the session should be created
```

### Validation rules

| Rule | Example | Fix |
|------|---------|-----|
| Must start with `Feature:` | `Scenario: Login` | Add `Feature: User Authentication` at top |
| Scenarios must start with `Scenario:` | `Given user exists` (at root level) | Wrap in `Scenario:` block |
| Steps must start with keyword | `user logs in` | Change to `When user logs in` |
| Consistent indentation | Lines at different levels | Use 2-space indentation |
| Complete sentences | `log in` | Change to `When the user logs in` |

### File naming

Feature file names should be:
- Lowercase with hyphens: `user-login.feature`
- Descriptive: `checkout-cart.feature`, not `test1.feature`
- Domain-based: group related features together

## Step parameter extraction

### Common parameter patterns

**String parameters:**
```gherkin
Given a user with email "alice@test.com"
```
Extract as: `"{email}"` → Python: `"{email}"`

**Numeric parameters:**
```gherkin
Given there are 5 items in the cart
```
Extract as: `"{count}"` or `{count:d}` → Python parameter name: `count`

**Boolean/Choice parameters:**
```gherkin
Given the user is "active" | "inactive"
```
Extract as: `"{status}"` → Python: `"{status}"`

**Multiple parameters:**
```gherkin
Given a user "alice" with role "admin" created on "2024-01-01"
```
→ Extract as: `a user "{name}" with role "{role}" created on "{date}"`

### Regex conversion rules

| Gherkin | Python Regex | Python Function |
|---------|--------------|-----------------|
| `"{email}"` | `"([^"]*)"` | Parameter named `email` |
| `{count}` (bare number) | `(\d+)` | Parameter named `count` (int type) |
| `"{a}" and "{b}"` | `"([^"]*)" and "([^"]*)"` | Parameters: `a`, `b` |

## Project initialization checklist

When creating a new BDD project:

1. **Create directory structure:**
   ```bash
   mkdir -p features/steps
   touch features/__init__.py
   touch features/steps/__init__.py
   ```

2. **Install behave:**
   ```bash
   pip install behave
   ```

3. **Create initial feature file:**
   ```bash
   # features/login.feature
   Feature: User Authentication
     Scenario: User logs in
       ...
   ```

4. **Create initial steps file:**
   ```bash
   # features/steps/steps.py
   from behave import given, when, then
   ```

5. **Run to verify:**
   ```bash
   behave
   ```

## Step definition best practices

### Naming conventions

**Good function names:**
- `step_user_logs_in_with_credentials`
- `step_database_has_n_records`
- `step_error_message_displayed`

**Avoid:**
- Single letters: `step_a`, `step_b`
- Generic names: `step_1`, `step_test`
- Abbreviations: `step_usr_logs` (use `step_user_logs_in`)

### Decorator matching

The decorator string must match the Gherkin step exactly (except for parameters):

```gherkin
Given a user with email "alice@test.com"
```

Must be:
```python
@given('a user with email "{email}"')
def step_create_user(context, email):
    pass
```

NOT:
```python
@given('a user is created')  # ❌ Doesn't match
def step_create_user(context, email):
    pass
```

### Context object

The `context` object passed to every step holds test state:

```python
@given('a user with email "{email}"')
def step_create_user(context, email):
    context.user = {"email": email}  # Store for later steps

@when('the user logs in')
def step_login(context):
    user = context.user  # Access in later step
    context.is_authenticated = authenticate(user)

@then('the user should be authenticated')
def step_check_auth(context):
    assert context.is_authenticated  # Use stored state
```

## Common step patterns

### Setup steps (Given)
```python
@given('a database with {count:d} users')
def step_create_users(context, count):
    context.users = [create_user(i) for i in range(count)]

@given('the configuration:')
def step_load_config(context):
    # context.table has rows from table in feature file
    for row in context.table:
        set_config(row['key'], row['value'])
```

### Action steps (When)
```python
@when('the user clicks "{button}"')
def step_click_button(context, button):
    context.result = click_button(button)

@when('the API receives a request:')
def step_api_request(context):
    # context.text contains multiline string from feature
    context.response = api_call(context.text)
```

### Assertion steps (Then)
```python
@then('the response status is "{status}"')
def step_check_status(context, status):
    assert context.response.status == status

@then('the user sees:')
def step_check_output(context):
    for row in context.table:
        assert row['field'] in context.screen
```

## Debugging tips

**Step not found error:**
```
Undefined step: 'Given the user is logged in'
```
→ Check decorator matches exactly (including punctuation, case)

**Ambiguous step error:**
```
Ambiguous step: 'When user logs in' matches multiple definitions
```
→ Make decorators more specific, use parameters differently

**Table/text not received:**
```
context.table is None
AttributeError: 'NoneStep' object has no attribute 'table'
```
→ Verify feature file has table/docstring indented correctly

**Test data isolation:**
→ Use `environment.py` hooks to clean up between scenarios:
```python
def before_scenario(context, scenario):
    context.db = setup_test_db()

def after_scenario(context, scenario):
    cleanup_test_db(context.db)
```
