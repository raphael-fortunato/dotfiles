---
name: my-testing
description: How to write tests in this codebase. Covers red/green discipline, pytest for backend unit and integration tests, what may be mocked, database and service setup for Postgres, PocketBase and Qdrant, FastAPI endpoint testing, file layout and naming, frontend tests, and what coverage is required. Read before writing or modifying any test.
---

# Testing

## Red/green

Write the test first. Run it. Confirm it fails, and confirm it fails for the reason you
expect and not because of an import error, a typo, or missing setup. Only then implement.

A test that passes before the implementation exists is not exercising anything. If that
happens, the test is wrong, not the workflow.

## Backend (pytest)

`pytest` exclusively for all Python unit and integration tests. Run through `uv run pytest`.

- Use `pytest-asyncio` for async tests with `asyncio_mode = "auto"`.
- Use `time-machine` to freeze or travel through time in tests that branch on timestamps.
- Never use `unittest` test classes or test runners. Write standard `test_*` functions.

## Mocking

Mock third-party external networks only: LLM provider APIs, payment gateways,
transactional email.

Never mock anything internal. No mocking of database drivers, storage adapters, or
repository boundaries. If an adapter talks to a storage engine, let it talk to real
storage in the test.

A separate process this repo runs (such as the agent backend) is internal too. Unit tests
may fake only its HTTP client, and only when one integration test starts the real process
and makes a real call through that same client, so a contract change between the two
fails a test. Say in the report which integration test covers it.

When testing external boundaries, assert on observable behavior, returned data, or state
changes, not merely that a mock was called.

If a test is hard to write without mocking an internal boundary, that is a signal about
the design. Say so rather than reaching for a mock.

## Test state

**Postgres.** Local Docker Compose test container, or `testcontainers-python` when
running isolated in CI. Isolate per test by running the test inside a transaction that
rolls back on teardown. Where a rollback is impractical, use a fast table-truncate
fixture between tests instead.

**PocketBase.** Ephemeral local instance pointed at a temporary SQLite file under
`/tmp`. Destroyed and recreated once per test suite run.

**Qdrant.** Dedicated local test container with in-memory storage. Wipe test collections
per module or per fixture.

Tests must not depend on state left behind by other tests, and must pass when run in
isolation and in any order.

## FastAPI endpoints

Use `httpx.AsyncClient` or `TestClient` against the ASGI `app` in-process. This catches
lifespan and dependency-override problems and runs in milliseconds.

Do not spin up a live HTTP server for routine endpoint tests. Reserve real HTTP calls for
end-to-end smoke checks.

## Layout and naming

Top-level `tests/` directory mirroring the source tree: `tests/api/`, `tests/services/`.

Files are `test_<module>.py`. Test functions are `test_<behavior>_<expected_outcome>`,
for example `test_expired_token_returns_401`.

Fixtures stay shallow and composable, in `conftest.py`, for shared machinery only:
`db_session`, `client`, `auth_headers`.

Build domain-specific payloads with plain setup inside the test body. A reader should see
the inputs without opening another file. Do not push test data into fixtures to shorten
the test.

## Frontend (Next.js)

Vitest plus React Testing Library, and keep it lean. Test non-trivial client logic,
critical UI state machines, and hooks.

Do not test presentation-only components.

Playwright covers critical user journeys such as login and the core workflow submission.
Write a spec in the same step that builds the UI it drives, never ahead of it with guessed
selectors.

## Speed

Slow tests run rarely; tests that do not need to be slow are fixed, not tolerated.

| Tier | Budget per test | Runs |
|---|---|---|
| unit | under 100 ms | every build step, affected files only |
| integration / api | under 2 s | every build step, affected files only |
| full check (`make check`) | | once per unit of work |
| e2e (Playwright) | under 30 s per spec | once per epic; for a direct request, only the specs it touched, once |

- **No real waiting.** Cooldowns, retry delays, TTLs, expiries and polling intervals come
  from settings, and the test environment sets them to milliseconds. Logic that branches
  on elapsed time uses `time-machine`. Never `sleep` to wait for business logic.
- **e2e specs own their data.** Each spec creates the records it needs through the API
  and does not rely on another spec, on run order, or on bootstrap state left by an
  earlier run. A spec passes when run alone and in parallel.
- **Over budget:** fix it. If it genuinely cannot be faster (a real external probe),
  mark it `@pytest.mark.slow` with a one-line reason; step-level runs use
  `-m "not slow"`.
- **One suite at a time.** Never run two test suites concurrently.
- **Isolate failing acceptance tests during debugging.** When debugging an end-to-end or acceptance test failure, never re-run the entire acceptance suite (`make acceptance` or `make acceptance APP=...`) to test a fix. Isolate the single failing test with `--grep` or by targeting its specific spec file. Full suite runs are merge gates, not debug cycles.

## What must be covered

No percentage gates. These four rules instead:

1. Every bug fix gets a regression test that reproduces the issue, written and confirmed
   failing before the fix.
2. Every core business rule and data transformation gets unit tests covering edge cases
   and failure paths, not just the happy path.
3. Every exposed endpoint gets a happy-path status check plus its primary 4xx validation
   cases.
4. Every PocketBase collection gets an access test against the real instance. As an
   anonymous client and as a second ordinary user, list, view, update and delete on
   another user's or tenant's records are denied. Signup and self-update that set
   `role`, `tenant` or `is_admin` are rejected. Hidden fields never appear in responses.
   See the `my-api` skill for the rules being tested.

Anything beyond that is a judgement call. More tests are not automatically better.

## Never

- Never weaken, skip, `xfail`, or delete a test to get a green run.
- Never write a test that asserts only that code ran without error.
- Never assert on implementation details that a refactor would break, when the behaviour
  is what matters.
- Never assert merely that a mock was called when the resulting behavior or output can be asserted.
- Never filter on HTTP status codes inside `page.waitForResponse(...)` (e.g. `r.status() === 200` or `201`). Filter by URL pattern only, then assert `expect(response.status()).toBe(...)` on the resolved response. Status predicates turn 4xx/5xx responses into full test timeouts.