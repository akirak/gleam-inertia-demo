# Gleam + Inertia Demo Application

This is a Gleam [Mist](https://github.com/rawhat/mist) application using [Inertia](https://inertiajs.com/) to provide a React frontend while running on Erlang VM (BEAM).

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
