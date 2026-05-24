import gleam/http.{Get, Head}
import gleam/http/request
import gleam/json
import utils/about.{get_system_version}
import utils/inertia
import web

pub fn make_handler(ctx: web.Context) -> web.Handler {
  fn(req: web.Request) -> web.Response {
    use req <- web.middleware(ctx, req)

    case request.path_segments(req) {
      [] -> home(req, ctx)
      ["about"] -> about(req, ctx)
      ["greet", name] -> greet(name, req, ctx)

      // This matches all other paths.
      _ -> web.not_found()
    }
  }
}

fn home(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let page =
    inertia.page(
      component: "home",
      props: [
        #("errors", json.object([])),
      ],
      version: inertia.NullVersion,
    )

  web.inertia_response(req, ctx, 200, page)
}

fn greet(name: String, req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let page =
    inertia.page(
      component: "greet",
      props: [
        #("name", json.string(name)),
        #("errors", json.object([])),
      ],
      version: inertia.NullVersion,
    )

  web.inertia_response(req, ctx, 200, page)
}

fn about(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let version = get_system_version()

  let page =
    inertia.page(
      component: "about",
      props: [
        #("systemVersion", json.string(version)),
        #("errors", json.object([])),
      ],
      version: inertia.NullVersion,
    )

  web.inertia_response(req, ctx, 200, page)
}
