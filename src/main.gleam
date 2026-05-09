import wisp
import router
import web
import mist
import wisp/wisp_mist
import gleam/erlang/process

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let ctx = web.Context(static_directory: static_directory())

  let handler = router.make_handler(ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start

  process.sleep_forever()
}

fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(static_directory) = wisp.priv_directory("demo_web")
  static_directory <> "/static"
}
