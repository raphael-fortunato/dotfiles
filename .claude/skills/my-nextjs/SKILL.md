---
name: my-nextjs
description: Next.js and frontend conventions for this codebase. Covers App Router and client boundaries, when to extract hooks, data fetching and auth transport, generated API types, Tailwind and shadcn, feature-first structure, forms, client state, and loading and error handling. Read before writing or modifying any frontend code.
---

# Next.js

## Router and component boundaries

App Router exclusively. Server Components are the default for layouts, pages and
data-fetching containers.

Push `"use client"` as far down the tree as possible, leaves first. The boundary belongs
on the interactive leaf, never on a page or a major layout container. When a client
wrapper has to sit higher, pass server-rendered JSX through as `children` rather than
pulling the subtree across the boundary.

<example name="client-boundary">
A page stays a Server Component. Only the search input is a client leaf.

  app/documents/page.tsx        Server Component, fetches and renders
  features/documents/components/search-input.tsx    "use client"
</example>

If a component needs `"use client"` only because a child does, the boundary is in the
wrong place. Move it down.

## Logic versus layout

Default to colocation. UI state, simple handlers and JSX live together in the component.
Reading a 40-line component top to bottom beats jumping between a JSX file and an
artificial `useComponentLogic()` returning a bag of twelve props.

Extract a custom hook only when one of these is true:

- the behaviour is genuinely reused across components (`useDebounce`, `useLocalStorage`)
- the component coordinates a real state machine: window listeners, multi-step timers,
  a non-trivial `useReducer`
- the logic has branching worth testing on its own through `renderHook`
- component logic alone exceeds roughly 40 to 50 lines and is burying the markup

Keep inline: local booleans, modal toggles, one-off submit handlers, tab indexes.

Reuse before creating: search existing components and utilities in the feature and shared
folders before writing new ones. When a component, handler, or hook becomes unreachable or
unused, delete it in the same commit.

## Data fetching

**Server Components** call FastAPI directly with `fetch()`, always with explicit cache
tags and a revalidation strategy.

<example name="server-fetch">
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
    next: { tags: ["documents"], revalidate: 60 },
  });
</example>

**Client Components** use TanStack Query for anything client-initiated: polling, infinite
scroll, live tables, post-interaction mutations. Query options and fetchers live in
`features/<feature>/api/`.

Never fetch in a `useEffect`. If it is client-side data, it is a query.

## Auth transport

Session tokens live in `httpOnly`, `Secure`, `SameSite=Lax` cookies.

Server Components read the cookie with `cookies()` from `next/headers` and attach it as
an `Authorization: Bearer` header on internal FastAPI calls.

Browser calls either pass cookies directly when on the same root domain, or route through
a thin Route Handler under `app/api/` acting as a proxy. Raw credentials are never
exposed to client-side JavaScript.

Never put a token in `localStorage`, in a non-`httpOnly` cookie, or in a
`NEXT_PUBLIC_` variable.

## Types across the boundary

API types are generated, never hand-written. Run `openapi-typescript` against FastAPI's
`/openapi.json` and commit the output.

Hand-written types are limited to client-only UI state: view toggles, modal state, local
form drafts. Never hand-maintain a request or response contract, and never redeclare a
type that exists in the generated file.

If the generated types are stale, regenerate them. Do not patch around them.

## Styling and UI primitives

Tailwind CSS with shadcn/ui on Radix primitives.

Extract a reusable component when a pattern repeats at least three times, or to isolate
interactive state out of a Server Component. Not before.

No speculative micro-components. A single-use wrapper around a `div` and some text is not
a component. Keep components local to their route or feature until they are proven
generic, then move them to `components/ui/`.

Compose class names with the `cn` helper. No inline `style` attributes except for genuinely
dynamic values such as a computed width.

## Project structure

Feature-first. Feature code is colocated:

<example name="structure">
  src/
    app/                         routing, layouts, route handlers only
    features/
      documents/
        components/
        hooks/                   reusable or heavy logic only
        api/                     query options, client fetchers
    components/ui/               shadcn and Radix primitives
    lib/                         fetch client, formatting, cn helper
</example>

`app/` contains routing and nothing else. Pages import views and containers from
`features/`. A page file that grows its own markup and logic is a page that should be
importing a feature component instead.

## Forms

`react-hook-form` with `@hookform/resolvers/zod` and Zod schemas.

Zod schemas mirror the constraints in the corresponding Pydantic schema. When the two
drift, the backend is the source of truth and the frontend is what changes.

Client validation is a convenience, never a guarantee. The server validates regardless.

## Client state

In this order, and do not skip up the list:

1. **URL search params** for anything filterable, shareable or bookmarkable: pagination,
   search terms, active tab.
2. **Local state** with `useState` or `useReducer` for isolated component UI.
3. **Zustand** for genuine cross-component global state: sidebar collapse, multi-step
   builder state, player state.

Avoid React Context for frequently updated values; it causes render thrashing. Context is
for stable values such as a theme or a configured client.

Server data is not client state. It belongs in TanStack Query, not in a store.

## Loading and errors

`loading.tsx` for route-level streaming transitions with skeleton UI. Inline `Suspense`
boundaries around independent sections so a slow endpoint does not block fast ones.

`error.tsx` at route level for catastrophic render failures, with a clean retry.

Expected API errors surface where the user is: validation and 4xx responses map to
`react-hook-form` field errors inline, mutation failures raise a `sonner` toast. An
expected error never reaches an error boundary.

Never swallow a failed mutation silently. Every mutation has a visible success and a
visible failure path.

## Never

- Never put `"use client"` on a page or layout.
- Never fetch data in a `useEffect`.
- Never hand-write a type that exists in the generated OpenAPI output.
- Never expose a token to client-side JavaScript.
- Never put server data in a Zustand store.
- Never build a component for a single use.
- Never leave unreachable, orphaned, or dead code behind.
- Never leave a mutation without visible success and failure states.