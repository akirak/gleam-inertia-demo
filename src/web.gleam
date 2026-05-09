// Based on https://github.com/gleam-wisp/wisp/tree/develop/examples/src/routing/app/web.gleam
import wisp

pub type Context {
  Context(static_directory: String)
}

pub type Handler = fn(wisp.Request) -> wisp.Response

pub fn middleware(
  ctx: Context,
  req: wisp.Request,
  handle_request: Handler,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use req <- wisp.csrf_known_header_protection(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  handle_request(req)
}
