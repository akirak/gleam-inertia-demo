# Gleam + Inertia Demo Application

This is a Gleam [Mist](https://github.com/rawhat/mist) application using [Inertia](https://inertiajs.com/) to provide a React frontend while running on Erlang VM (BEAM).

## Rationale
After trying [TanStack Start](https://tanstack.com/start/latest) in a few
personal projects, I wanted a deployment model that does not require
self-hosting a Node.js server for application logic. Bun is interesting, but it
does not change the main trade-off: the runtime still becomes part of the
server-side frontend stack.

For my homelab, I want that server-side boundary to run on the Erlang VM
(BEAM). Elixir and Phoenix LiveView are strong options, but Gleam is a better
fit for the kind of small, typed Backend-For-Frontend (BFF) layer I want to
write. The missing piece is a low-friction frontend story. I still want to build
the interface in React, keep client state minimal, and avoid inventing a new
server-side web framework for Gleam.

Inertia provides a useful protocol for that shape of application: Gleam can own
routing, data preparation, and HTTP responses while React owns the interactive
views. This repository explores that project structure and the adapter code
needed to make it comfortable.

## Goals
- Keep the backend small, typed, and easy to reason about in Gleam.
- Use React for view code without adding a Node.js application server.
- Treat Inertia as the boundary between server routes and client pages.
- Preserve BEAM runtime strengths, especially predictable concurrency through
  its preemptive scheduler.
- Make the project structure simple enough to reuse for small BFF-style
  applications.

## Non-Goals
- Complex frontend: Client states should be kept minimal unless necessary
- Running the Gleam backend on a JavaScript runtime or WASM (like Cloudflare
  Workers)

## Prerequisites
- Gleam
- Erlang (tested on Erlang 28)
- Node.js + pnpm

If you are a Nix user, the flake.nix in this repository provides all of the
above dependencies via the development shell.
## Development
First install the dependencies:

``` sh
gleam deps download
pnpm install
```

Then run development servers.
You can run the following two commands simultaneously:
``` sh
pnpm dev
DEMO_WEB_ENV=development gleam run -m main
```

You can also use `just`:
``` sh
just dev
```

To exit the processes being run with `just`, type `h`, `q`, `Ctrl-C`, and `a`. The first two keys exits vite, the rest exits Erlang (Gleam).

Visit http://localhost:8000

## End-to-End Tests

Install the browser automation dependencies once:

``` sh
pnpm install
pnpm exec playwright install --with-deps chromium
```

Run the E2E suite:

``` sh
pnpm test:e2e
```

Playwright starts both the Vite dev server and the Gleam application server for
the test run. The initial suite covers the home page, client-side navigation to
the About page, and the dynamic greet route.

## TODO
### Protocol
- Page Object with Deferred Props
- Page Object with Rescued Deferred Props
- Page Object with Merge Props
- Page Object with Scroll Props
- Page Object with Once Props
- Asset Versioning
- Partial Reloads
- Allow only supported HTTP status codes
### Enhance the Web Site
- ~~CSS~~
- ~~Layout~~
### Developer Experience
- Hot swapping support
### Packaging
- Factor out the Inertia adapter

## Thanks
[wisp_inertia](https://github.com/keuller/wisp_inertia) package by Keuller
Magalhães is an inspiration of this repository.
