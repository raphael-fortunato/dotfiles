# BDD Behave Examples

## Example 1: Complete workflow

### Feature file (features/user_login.feature)
```gherkin
Feature: User Authentication
  Scenario: Login with valid credentials
    Given a user with email "alice@example.com" and password "secret123"
    When the user submits the login form
    Then the user should be authenticated
    And the session should contain the user email

  Scenario: Login with invalid password
    Given a user with email "bob@example.com" and password "correct"
    When the user submits login with password "wrong"
    Then the user should not be authenticated
    And an error message should contain "Invalid credentials"
```

### Existing steps file (features/steps/authentication.py)
```python
from behave import given, when, then

@given('a user with email "{email}" and password "{password}"')
def step_create_user(context, email, password):
    context.user = {"email": email, "password": password}
    context.is_authenticated = False
```

### Analysis
Missing steps:
- `When the user submits the login form`
- `Then the user should be authenticated`
- `And the session should contain the user email`
- `When the user submits login with password "{password}"`
- `Then the user should not be authenticated`
- `And an error message should contain "{message}"`

### Generated stub functions
```python
@when('the user submits the login form')
def step_submit_login_form(context):
    """When the user submits the login form."""
    raise NotImplementedError()

@then('the user should be authenticated')
def step_user_authenticated(context):
    """Then the user should be authenticated."""
    raise NotImplementedError()

@then('the session should contain the user email')
def step_session_contains_email(context):
    """Then the session should contain the user email."""
    raise NotImplementedError()

@when('the user submits login with password "{password}"')
def step_submit_login_with_password(context, password):
    """When the user submits login with password."""
    raise NotImplementedError()

@then('the user should not be authenticated')
def step_user_not_authenticated(context):
    """Then the user should not be authenticated."""
    raise NotImplementedError()

@then('an error message should contain "{message}"')
def step_error_message_contains(context, message):
    """Then an error message should contain a message."""
    raise NotImplementedError()
```

## Example 2: Data tables

### Feature file
```gherkin
Feature: User Management
  Scenario: Create multiple users
    Given these users exist:
      | email             | role  |
      | alice@example.com | admin |
      | bob@example.com   | user  |
      | carol@example.com | user  |
    When the admin lists all users
    Then there should be 3 users total
```

### Generated function
```python
@given('these users exist:')
def step_create_users_table(context):
    """Given these users exist (from table)."""
    context.users = []
    for row in context.table:
        context.users.append({
            "email": row["email"],
            "role": row["role"]
        })
```

## Example 3: Multiline strings (docstrings)

### Feature file
```gherkin
Feature: Configuration
  Scenario: Load config file
    Given a configuration file:
      """
      [database]
      host=localhost
      port=5432
      name=testdb
      """
    When the system loads the configuration
    Then the database host should be "localhost"
```

### Generated function
```python
@given('a configuration file:')
def step_load_config(context):
    """Given a configuration file (from docstring)."""
    # context.text contains the multiline string
    config_lines = context.text.split('\n')
    context.config = {}
    for line in config_lines:
        if '=' in line:
            key, value = line.split('=', 1)
            context.config[key.strip()] = value.strip()
```

## Workflow: From feature to implementation

1. **Write feature file** with scenarios
2. **Run behave** to identify missing steps
3. **Generate stubs** using this skill
4. **Copy stubs** into your steps file
5. **Implement bodies** with actual test logic
6. **Run behave** again to verify and debug

Example command:
```bash
# See which steps are undefined
behave features/user_login.feature

# After implementing, run all tests
behave
```

## Tips for effective BDD

- **One step = one assertion concept** - Don't pack multiple checks into one step
- **Use parameters** instead of hardcoding values
- **Organize steps logically** - Group related steps in same file
- **Reuse steps** - Write generic steps that work across scenarios
- **Keep Gherkin readable** - Non-technical stakeholders should understand scenarios
