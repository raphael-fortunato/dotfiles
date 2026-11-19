---
name: my-api
description: FastAPI conventions for this codebase. Covers layering, router structure and versioning, dependencies and auth, PocketBase collection access rules, response shapes and status codes, pagination, where validation lives, streaming, background tasks, idempotency and rate limiting. Read before writing or modifying any route, router, API schema, or PocketBase collection or migration.
---

# API

Read the `my-python` skill first. This file covers only what is specific to the HTTP layer.

## Layering

There are three layers and no more: routers, services, queries. A layer is added when it
earns its place, never by default.

**Direct reads.** For logic-free queries (fetch by ID, straightforward filtering) the
route handler calls the query function directly. Do not write a passthrough service
function that only forwards its arguments.

**Service functions.** Create one only when there is real business logic: multi-table
side effects, orchestration such as a DB write plus a vector index update, or an
invariant to enforce. The service layer is a boundary for business rules, not mandatory
boilerplate.

**Handlers stay thin.** A route handler parses input, calls one function, and returns.
If a handler contains branching business logic, that logic belongs in a service.

## Routers and versioning

One router per resource at `api/routers/<resource>.py`.

`prefix` and `tags` are declared in the router file itself:

```python
router = APIRouter(prefix="/documents", tags=["documents"])
```

Routers are collected into a parent router in `api/v1/__init__.py`:

```python
v1_router = APIRouter(prefix="/v1")
v1_router.include_router(documents.router)
```

`main.py` mounts only `v1_router`. The version lives in exactly one place and is never
repeated in a resource file.

Create, read, update and delete use plural nouns and the HTTP method: `POST /documents`,
never `/create-document`, `/get-document` or `/update-document`. An action that is not
one of those (archive, snooze, finish, sync) is a `POST` with a verb as the last segment:
`POST /documents/{id}/archive` for one record, `POST /documents/sync` for the
collection. A plain field change stays a `PATCH`; don't add `/{id}/rename` for what
`PATCH /{id}` already does. Action endpoints are safe to retry: `complete` and `uncomplete`,
never `toggle`.
Nested resources go one level deep at most; beyond that, use a query parameter.

## Dependencies and auth

Injected through `Depends`: database sessions and connections, the authenticated
`current_user`, `Settings`, and external clients such as the Qdrant client or an HTTP
client.

Base authentication is enforced at the router level:

```python
router = APIRouter(
    prefix="/documents",
    tags=["documents"],
    dependencies=[Depends(get_current_user)],
)
```

Granular roles and permissions are checked per route with an explicit dependency such as
`Depends(require_role("admin"))`.

Unauthenticated routes are marked explicitly on their own declaration and are limited to
health checks, webhooks and the auth endpoints themselves. Authentication is never
optional by omission; if a route is public, that is a visible decision in the code.

Never instantiate a client or open a connection inside a handler. It arrives through
`Depends`.

## PocketBase access rules

PocketBase serves its REST API directly to anyone who can reach its domain. Collection
rules are the authorization layer; the frontend is not. Write every rule assuming an
attacker calls the API with `curl` after signing up themselves.

- **Rules live in migrations** under `pb_migrations/`, never only in the admin UI.
- **Signup is locked by default.** `users.createRule` is `null` unless the product needs
  self-signup. Accounts are otherwise created by the backend or an invite flow.
- **Privilege fields are never client-writable.** With signup open, a public create rule
  lets the caller set any field, including `role`. Guard every privilege field (`role`,
  `tenant`/`tenant_id`, `is_admin`, plan, quota) in both create and self-update rules:

  ```
  createRule: @request.body.role:isset = false && @request.body.tenant_id:isset = false
  updateRule: id = @request.auth.id && @request.body.role:isset = false
              && @request.body.tenant_id:isset = false
  ```

  Changing a privilege field is a separate admin-only rule or a backend call.
- **`@request.auth.id != ""` alone is never a data rule.** It means "anyone who can get
  an account". Scope every rule to the owner (`user = @request.auth.id`) or the tenant
  (`tenant = @request.auth.tenant`).
- **A role check alone is never enough** in a multi-tenant collection. Pair
  `@request.auth.role = "admin"` with a tenant match.
- **Secret fields are `hidden`.** OTP codes, tokens and API keys on any collection are
  marked hidden so no list or view rule can return them.
- **A public rule (`""`) is a visible decision.** Use it only for data meant for anyone,
  with a comment in the migration saying so.
- **The admin UI (`/_/`) is not public.** Block it at the reverse proxy, or put it behind
  the same access layer as other admin tools.

## Responses and status codes

Annotate the return type directly and return the Pydantic instance:

```python
async def get_document(document_id: UUID) -> DocumentResponse:
```

FastAPI derives serialization and the OpenAPI schema from the return annotation. Do not
also pass `response_model=`; that duplicates the same fact in two places.

Status codes:

- `201 Created` for creation, always returning the created resource
- `204 No Content` for deletion, with an empty body
- `200 OK` for everything else

Payloads are bare objects and lists. No envelope, no `{"data": ..., "status": "success"}`.
HTTP status carries the status; the body carries the content.

Errors are never raised as `HTTPException` from services or domain code. Domain errors
propagate and are mapped to status codes by the global `exception_handlers` registered in
`main.py`. Handlers may raise `HTTPException` directly only for conditions that are
genuinely HTTP-level and have no domain meaning.

## Pagination and filtering

Offset and limit for administrative and standard UI tables. Cursor-based for
high-frequency or large event feeds, keyed on timestamp plus ID.

Offset lists return:

```json
{ "items": [], "total": 120, "limit": 20, "offset": 0 }
```

Cursor lists swap `total` and `offset` for `next_cursor` and `has_more`.

`limit` has a default and a hard maximum, validated in the schema. An unbounded list
endpoint is a bug.

List responses are typed with a generic container so the shape is defined once rather
than re-declared per resource.

## Validation

**Pydantic schemas** carry syntactic validation: types, formats, string length, regex,
required fields, field-level parsing and coercion.

**The domain layer** carries semantic and stateful validation: uniqueness checks against
the database, state machine transitions, quota and balance checks, anything that needs to
read current state to decide.

A validator that needs a database session is in the wrong place.

Request and response schemas live in `schemas/`, never reusing a persistence model. See
the `my-python` skill for that separation.

## Streaming

For LLM and RAG responses use `StreamingResponse` with `text/event-stream`. Each event
carries a JSON payload:

```
data: {"delta": "...", "finish_reason": null}\n\n
```


Terminate the stream with an explicit final event carrying a `finish_reason`. Send errors
as an event on the stream, since the status code has already been sent and cannot be
changed once streaming has begun.

## Background tasks

FastAPI's `BackgroundTasks` is for trivial fire-and-forget work only: an audit webhook,
closing an ephemeral handle.

Anything critical, retry-dependent, long-running, or CPU-heavy goes to a durable queue
and a worker. If losing the task on a restart would matter, it does not belong in
`BackgroundTasks`.

## Idempotency

Critical mutating POST endpoints (billing, pipeline execution triggers) require an
`Idempotency-Key` header. Cache the response against the key in Redis or an ephemeral
table and return the cached response on a repeat.

## Rate limiting

Token bucket or fixed window backed by Redis, applied at the gateway or reverse proxy.
Use `slowapi` at the router level for public endpoints where gateway-level limiting is
not available.

## Observability

Bind a request ID in middleware at the edge of every request and let `structlog` carry it
through the call. Every log line emitted during a request is traceable to that request.

Never log request bodies wholesale. Log identifiers and outcomes.

## Never

- Never put business logic in a route handler.
- Never write a service function that only forwards arguments to a query.
- Never raise `HTTPException` outside the API layer.
- Never return a persistence model from a route.
- Never use both a return annotation and `response_model=`.
- Never expose a list endpoint without a maximum `limit`.
- Never make a route public by forgetting the auth dependency; mark it explicitly.
- Never ship a PocketBase rule that a self-registered user can satisfy for someone
  else's data, or a create/update rule that lets a client set its own role or tenant.