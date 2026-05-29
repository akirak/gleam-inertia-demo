import argv
import clip
import clip/help
import clip/opt
import env
import gleam/erlang/application
import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/result
import mist
import router
import web

pub fn main() {
  case command() |> clip.run(argv.load().arguments) {
    Ok(options) -> start_server(options)
    Error(message) -> io.println_error(message)
  }
}

fn start_server(options: Options) {
  let ctx = web.Context(static_directory: static_directory(), assets: assets())
  let handler = router.make_handler(ctx)

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.bind(bind_address(options))
    |> mist.port(port(options))
    |> mist.start

  process.sleep_forever()
}

type Options {
  Options(port: Int, bind: String)
}

fn command() -> clip.Command(Options) {
  clip.command({
    use port <- clip.parameter
    use bind <- clip.parameter

    Options(port:, bind:)
  })
  |> clip.opt(
    opt.new("port")
    |> opt.int
    |> opt.default(port_from_env())
    |> opt.help("Port to listen on"),
  )
  |> clip.opt(
    opt.new("bind")
    |> opt.default("localhost")
    |> opt.help("Bind address for the Mist server"),
  )
  |> clip.help(help.simple("demo_web", "Run the demo web server"))
}

fn port(options: Options) -> Int {
  options.port
}

fn port_from_env() -> Int {
  case env.get("PORT") {
    Ok(value) -> value |> int.parse |> result.unwrap(8000)
    Error(_) -> 8000
  }
}

fn bind_address(options: Options) -> String {
  options.bind
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
