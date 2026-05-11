import gleam/bytes_tree
import gleam/http.{type Method, Get, Head}
import gleam/http/request.{type Request as HttpRequest}
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{None}
import gleam/result
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/element
import lustre/element/html.{html}
import mist
import utils/inertia

pub type Context {
  Context(static_directory: String, assets: Assets)
}

pub type Assets {
  ProductionAssets
  DevelopmentAssets(base_url: String)
}

pub type Request =
  HttpRequest(mist.Connection)

pub type Response =
  response.Response(mist.ResponseData)

pub type Handler =
  fn(Request) -> Response

pub fn middleware(
  ctx: Context,
  req: Request,
  handle_request: Handler,
) -> Response {
  serve_static(req, ctx.static_directory, fn() { handle_request(req) })
}

pub fn inertia_response(
  req: Request,
  ctx: Context,
  status: Int,
  page: inertia.Page,
) -> Response {
  let url = req.path

  case inertia.is_inertia_request(req) {
    False -> {
      let body =
        html([], [
          html.head(
            [],
            // Titles should be inserted using Head component
            asset_scripts(ctx),
          ),
          html.body([], inertia.app_script(url, page)),
        ])
        |> element.to_document_string
        |> bytes_tree.from_string

      response.Response(
        status: status,
        headers: [
          #("Content-Type", "text/html; charset=utf-8"),
        ],
        body: mist.Bytes(body),
      )
    }
    True -> {
      let body =
        inertia.page_component_json(url, page)
        |> json.to_string
        |> bytes_tree.from_string

      response.Response(
        status: status,
        headers: [
          #("X-Inertia", "true"),
          #("Content-Type", "application/json"),
        ],
        body: mist.Bytes(body),
      )
    }
  }
}

fn asset_scripts(ctx: Context) -> List(element.Element(msg)) {
  let Context(assets: assets, ..) = ctx
  case assets {
    ProductionAssets -> [
      html.script(
        [
          attribute.type_("module"),
          attribute.src("/static/js/app.js"),
        ],
        "",
      ),
    ]

    DevelopmentAssets(vite_origin) -> [
      html.script(
        [
          attribute.type_("module"),
          attribute.src(vite_origin <> "/@vite/client"),
        ],
        "",
      ),
      html.script(
        [attribute.type_("module")],
        react_refresh_preamble(vite_origin),
      ),
      html.script(
        [
          attribute.type_("module"),
          attribute.src(vite_origin <> "/src-inertia/app.tsx"),
        ],
        "",
      ),
    ]
  }
}

fn react_refresh_preamble(vite_origin: String) -> String {
  "import RefreshRuntime from \""
  <> vite_origin
  <> "/@react-refresh\"\n"
  <> "RefreshRuntime.injectIntoGlobalHook(window)\n"
  <> "window.$RefreshReg$ = () => {}\n"
  <> "window.$RefreshSig$ = () => (type) => type\n"
  <> "window.__vite_plugin_react_preamble_installed__ = true\n"
}

pub fn html_response(body: String) -> Response {
  response.new(200)
  |> response.set_header("content-type", "text/html; charset=utf-8")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

pub fn text_response(status: Int, body: String) -> Response {
  response.new(status)
  |> response.set_header("content-type", "text/plain; charset=utf-8")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

pub fn not_found() -> Response {
  text_response(404, "Not found")
}

pub fn require_methods(
  req: Request,
  allowed allowed: List(Method),
  next handler: fn() -> Response,
) -> Response {
  case list.contains(allowed, req.method) {
    True -> handler()
    False ->
      text_response(405, "Method not allowed")
      |> response.set_header("allow", allowed_header(allowed))
  }
}

fn serve_static(
  req: Request,
  directory: String,
  next handler: fn() -> Response,
) -> Response {
  case req.method, string.starts_with(req.path, "/static/") {
    Get, True -> static_response(req, directory, handler)
    Head, True -> static_response(req, directory, handler)
    _, _ -> handler()
  }
}

fn static_response(
  req: Request,
  directory: String,
  next handler: fn() -> Response,
) -> Response {
  let path =
    req.path
    |> string.drop_start(up_to: string.length("/static/"))
    |> uri.percent_decode
    |> result.unwrap("")
    |> string.replace(each: "..", with: "")
    |> string.replace(each: "\\", with: "/")

  case mist.send_file(directory <> "/" <> path, offset: 0, limit: None) {
    Ok(body) ->
      response.new(200)
      |> response.set_header("content-type", content_type(path))
      |> response.set_body(body)
    Error(_) -> handler()
  }
}

fn allowed_header(methods: List(Method)) -> String {
  methods
  |> list.map(fn(method) {
    case method {
      Get -> "GET"
      Head -> "HEAD"
      _ -> ""
    }
  })
  |> string.join(with: ", ")
}

fn content_type(path: String) -> String {
  let extension =
    path
    |> string.split(on: ".")
    |> list.last
    |> result.unwrap("")
    |> string.lowercase

  case extension {
    "html" -> "text/html; charset=utf-8"
    "css" -> "text/css; charset=utf-8"
    "js" | "mjs" | "jsx" -> "text/javascript; charset=utf-8"
    "json" -> "application/json; charset=utf-8"
    "png" -> "image/png"
    "jpg" | "jpeg" -> "image/jpeg"
    "svg" -> "image/svg+xml"
    "ico" -> "image/x-icon"
    "woff" -> "font/woff"
    "woff2" -> "font/woff2"
    _ -> "application/octet-stream"
  }
}
