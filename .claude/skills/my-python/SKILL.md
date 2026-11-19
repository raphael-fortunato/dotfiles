---
name: my-python
description: Python conventions for this codebase. Covers tooling (uv, ruff, mypy), functions over classes, function and file size, naming, configuration, datetimes, imports, error hierarchy, Pydantic schema separation, async strategy, SQL, comments, and logging. Read before writing or modifying any Python.
---

# Python

## Tooling

`uv` exclusively for packaging, virtualenvs and scripts. Never invoke `pip`, `poetry`,
`pyenv` or `pipenv`.

`ruff` for both linting and formatting. Line length 100.

`mypy` with a strong baseline: `check_untyped_defs`, `disallow_incomplete_defs`,
`no_implicit_optional`, `warn_unused_ignores` all true. New domain code should be written
as if `--strict` were on. Where a third-party library lacks types, narrow the ignore to
that import rather than loosening the config.

## Readability comes first

This is the highest priority in this codebase. Code that is clever, dense, or long is
worse than code that is obvious, even when the obvious version is more lines.

**Functions are small.** One thing per function. If a function passes roughly 20 lines
of body, or needs a comment to announce its second half, split it. Long descriptive
names are preferred over short names plus a comment. Do not split a function simply to
hit an arbitrary line target, and do not pad one to look substantial.

**Files are small.** A file past roughly 300 lines is a smell that the module is doing
more than one thing. Say so and propose a split rather than appending to it.

**Code breathes.** Blank lines between logical blocks. Do not pack a function into a
solid wall of statements to save space. Do not chain comprehensions or nest them more
than one level; a loop that reads clearly beats a comprehension that does not.

**Guard clauses over nesting.** Validate and return early. Deep `if` nesting is a
rewrite, not a style preference. Do not add defensive guard clauses or `None` checks
for conditions that type annotations and mypy already exclude.

## Naming

Names carry the explanation, since comments are not doing it.

No abbreviations except the universally understood ones: `id`, `url`, `db`, `http`.
Not `usr`, `cfg`, `res`, `tmp`, `val`, `data2`.

Booleans read as assertions: `is_active`, `has_access`, `should_retry`, `can_publish`.
Never a bare noun or a negated name like `not_found` or `disable_cache`.

Functions that do something are verb-first: `fetch_user`, `build_payload`,
`send_invite`. Functions that answer a question are `is_`, `has_`, or `get_`.

Collections are plural, single items singular. `users` is a list, `user` is not.

Include the unit or currency in the name when a number has one: `timeout_seconds`,
`amount_cents`, `max_retries`. A bare `timeout` or `amount` is a bug waiting to happen.

Single-letter names only for a loop index or a comprehension variable with a lifetime of
one line.

Do not pad names with the module they live in. `users.get(user_id)` beats
`users.get_user_by_user_id(user_id)`.

Do not introduce intermediate variables that are used only once and merely restate the
type or operation (such as `response_data = ...` immediately followed by `return response_data`
or `user_dict`).

## Configuration

One `Settings` object built with `pydantic-settings`, defined in a single `config.py`
and instantiated once at import.

No module ever reads `os.environ` or `os.getenv` directly. Everything goes through
`Settings`, so that the full set of required environment variables is visible in one
file and validated at startup rather than discovered at runtime.

Settings are typed and validated. A missing or malformed required variable fails
loudly at startup, never falls back to a default that lets the app boot broken.

Secrets use `SecretStr`. Never give a secret a default value.

Functions that need configuration take the values they need as arguments rather than
reaching for the global `Settings` object. A function's signature should state what it
depends on. Constructing `Settings` and passing values down happens at the composition
edges: app startup, lifespan, FastAPI dependencies.

## Datetimes

Everything is timezone-aware UTC. There are no naive datetimes anywhere in this codebase.

Use `datetime.now(UTC)`. Never `datetime.utcnow()`, never `datetime.now()` without a
timezone argument.

Store UTC, transmit UTC as ISO 8601, and convert to local time only at the point of
display in the frontend. Timezone conversion never happens in the backend.

Durations are `timedelta`, or an int whose name states the unit. Never a bare number.

Pass `now` in as an argument when the function's behaviour branches on it: expiry
checks, scheduling, retention rules, anything of the form "if this is older than X".
There the current time is a real input to a business rule and hiding it in the function
body hides a dependency.

Call `datetime.now(UTC)` directly for incidental timestamping, where the value is only
recorded and never branched on: `created_at`, log lines, metrics. Freeze the clock with
`time-machine` in tests if those ever need asserting.

The test is whether any branch depends on the value. If yes, it is an input. If it is
only written down, it is not.

## Imports

Absolute imports within the package. No relative imports, not even one level up.

Import modules, not individual names, when pulling from your own package:
`from app.users import queries` then `queries.fetch_user(...)`. This keeps the call site
self-describing and avoids a namespace full of bare verbs. Importing names directly is
fine for third-party libraries and for types.

No imports inside functions, except to break a genuine circular import, and a circular
import is a signal that the module boundary is wrong. Say so rather than hiding it.

No wildcard imports. No re-exporting through `__init__.py` to build a shorter public
path; let callers import from the module that actually defines the thing.

Ruff enforces ordering. Do not hand-sort.

## Magic values

Any literal that appears twice, or whose meaning is not obvious at the call site, gets a
named constant. `MAX_UPLOAD_BYTES = 10 * 1024 * 1024` rather than `10485760` inline.

Constants live in the module that owns them, at module level, `UPPER_SNAKE_CASE`. Only
values genuinely shared across modules move to a `constants.py`, and that file does not
become a dumping ground.

A closed set of values is an `Enum` or a `Literal` type, never a bare string compared
with `==`. Status, kind, role and mode fields are always one of those two.

`0`, `1`, `""` and obvious array indices do not need naming.

## Functions over classes

Strongly bias toward plain functions and modules. Group related operations by module,
not by inventing a `UserService` or `AuthManager` whose methods never touch `self`.

Classes are for exactly two things:

- stateful objects: lifespans, clients holding connection pools, DB sessions, HTTP clients
- data containers: `dataclass` or Pydantic models

No inheritance outside base exception classes and Pydantic base models. No mixins, no
abstract base classes, no metaclasses.

Do not build an abstraction for a single caller. No interfaces added speculatively for a
second implementation that does not exist yet.

Reuse before creating: search the module and its siblings for an existing helper before
introducing a new one.

## Errors

Small, flat hierarchy of semantic domain errors inheriting from a base `AppError`:
`EntityNotFoundError`, `ConflictError`, `PermissionDeniedError` and similar. Flat means
one level under `AppError`.

Business logic stays HTTP-agnostic. Domain errors map to status codes at the FastAPI
boundary via global `exception_handlers`, never by raising `HTTPException` from a service
or domain module.

Never swallow. No bare `except Exception: pass`. No catching a database driver error to
return a default. Unexpected failures are logged with the full traceback and allowed to
fail loud.

Only catch an exception you can actually handle. Otherwise let it propagate.

## Pydantic and model separation

Never reuse a persistence representation as an API schema.

- `schemas/` holds request inputs (`*Create`, `*Update`) and response payloads (`*Response`)
- `domain/` holds domain models, dataclasses, and persistence representations

The separation exists to stop internal IDs, hashes and metadata leaking into responses,
and to decouple DB migrations from API contract changes. Mapping between the two is
explicit, in one place per entity.

## Async

Async by default for anything touching I/O: route handlers, database drivers, vector
search, `httpx` calls.

Pure computation, transformations and domain validation stay sync.

No fake async wrappers over synchronous libraries. Use `run_in_executor` only to isolate
genuinely blocking work, and say why in a comment when you do.

Never call a blocking library from an async function.

## Comments and docstrings

Zero redundant "what" comments. No `# get the user` above `def get_user()`. No
Google or Sphinx docstring blocks restating parameter types that the signature already
carries. No section banners or divider comments (such as `# ---- Helpers ----` or
`# ==== Queries ====`).

Write a docstring only for a non-obvious business rule, a domain quirk, or an
algorithmic edge case. Comments explain why, never what.

One exception to the no-argument-documentation rule: document a parameter when its
semantics are not recoverable from its type. Units, ownership, mutation, or a value with
a meaning the type does not express. Type hints carry types, not meaning.

Delete commented-out code rather than leaving it. Git has it. When a change leaves
existing code unreachable or unused, delete it in the same commit.

## Logging

`structlog`, JSON in production and readable colour locally.

Log events, not prose: `logger.info("payment_succeeded", user_id=user_id, amount=amount)`.

Bind correlation and request IDs across the request lifespan.

Never log credentials, tokens, or sensitive payload data. When in doubt, log an
identifier rather than the value.

## Never

- Never use `pip` or `poetry`.
- Never read `os.environ` outside `config.py`.
- Never create a naive datetime.
- Never interpolate values into SQL.
- Never raise `HTTPException` outside the API layer.
- Never catch an exception without handling it.
- Never add an abstraction layer for a single caller.
- Never leave unreachable, dead, or commented-out code behind, or a `TODO` without saying so in your report.