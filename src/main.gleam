import env
import gleam/erlang/application
import gleam/erlang/process
import gleam/int
import gleam/result
import mist
import router
import web

pub fn main() {
  let ctx = web.Context(static_directory: static_directory(), assets: assets())

  let handler = router.make_handler(ctx)

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.port(port())
    |> mist.start

  process.sleep_forever()
}

fn port() -> Int {
  case env.get("PORT") {
    Ok(value) -> value |> int.parse |> result.unwrap(8000)
    Error(_) -> 8000
  }
}

fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(static_directory) = application.priv_directory("demo_web")
  static_directory <> "/static"
}

fn assets() -> web.Assets {
  case env.get("DEMO_WEB_ENV") {
    Ok("development") ->
      web.DevelopmentAssets(base_url: vite_origin() <> "/static")

    _ -> web.ProductionAssets
  }
}

fn vite_origin() -> String {
  env.get("VITE_DEV_SERVER_ORIGIN")
  |> result.unwrap("http://localhost:5173")
}
