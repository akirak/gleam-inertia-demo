import gleam/http.{Get}
import web
import wisp.{type Request, type Response}
import lustre/element
import lustre/attribute
import lustre/element/html.{html}

pub fn make_handler(ctx: web.Context) -> web.Handler {
  fn(req: Request) -> Response {
    use req <- web.middleware(ctx, req)

    // Wisp doesn't have a special router abstraction, instead we recommend using
    // regular old pattern matching. This is faster than a router, is type safe,
    // and means you don't have to learn or be limited by a special DSL.
    //
    case wisp.path_segments(req) {
      ["greet", name] -> greet(name, req)

      // This matches all other paths.
      _ -> wisp.not_found()
    }
  }
}

fn greet(_name: String, req: Request) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)

  let html =
    html([], [
      html.head([], [
        html.title([], "Greetings!"),
        html.script([
          attribute.type_("module"),
          attribute.src("/static/inertia/js/app.jsx"),
        ], "")
      ]),
      html.body([], [
        html.div([attribute.id("app")], [])
      ]),
    ])

  wisp.ok()
  |> wisp.html_body(element.to_document_string(html))
}
