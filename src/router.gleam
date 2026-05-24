import gleam/http.{Get, Head}
import gleam/http/request
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
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
      ["protocol", "deferred"] -> deferred_demo(req, ctx)
      ["protocol", "deferred-rescue"] -> deferred_rescue_demo(req, ctx)
      ["protocol", "merge"] -> merge_demo(req, ctx)
      ["protocol", "scroll"] -> scroll_demo(req, ctx)
      ["protocol", "once", "source"] -> once_source_demo(req, ctx)
      ["protocol", "once", "target"] -> once_target_demo(req, ctx)

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

  web.inertia_response(req, ctx, 200, "Demo Home", page)
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

  web.inertia_response(req, ctx, 200, "Greet", page)
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

  web.inertia_response(req, ctx, 200, "About", page)
}

fn deferred_demo(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let component = "protocol/deferred"
  let load_permissions =
    inertia.is_partial_reload_for(req, component)
    && inertia.should_include_prop(req, component, "permissions")
  let load_analytics =
    inertia.is_partial_reload_for(req, component)
    && inertia.should_include_prop(req, component, "analytics")

  let page =
    inertia.page(
      component: component,
      props: [#("errors", json.object([]))]
        |> append_prop(
          "summary",
          json.string(
            "Core page content is immediate while secondary data loads after the initial render.",
          ),
        )
        |> append_prop_if(
          load_permissions,
          "permissions",
          json.array(
            [
              json.string("read:reports"),
              json.string("deploy:releases"),
              json.string("audit:events"),
            ],
            of: fn(value) { value },
          ),
        )
        |> append_prop_if(
          load_analytics,
          "analytics",
          json.object([
            #("activeUsers", json.int(128)),
            #("p95LatencyMs", json.int(182)),
            #("queueDepth", json.int(6)),
          ]),
        ),
      version: inertia.NullVersion,
    )
    |> inertia.with_deferred_props([
      #("default", ["permissions"]),
      #("insights", ["analytics"]),
    ])

  web.inertia_response(req, ctx, 200, "Deferred Props", page)
}

fn deferred_rescue_demo(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let component = "protocol/deferred_rescue"
  let retry = query_int(req, "retry", 0)
  let wants_permissions =
    inertia.is_partial_reload_for(req, component)
    && inertia.should_include_prop(req, component, "permissions")
  let rescued_permissions = wants_permissions && retry == 0

  let page =
    inertia.page(
      component: component,
      props: [#("errors", json.object([]))]
        |> append_prop(
          "summary",
          json.string(
            "The initial deferred request fails and is rescued until you explicitly retry it.",
          ),
        )
        |> append_prop_if(
          wants_permissions && !rescued_permissions,
          "permissions",
          json.array(
            [
              json.string("accounts:read"),
              json.string("accounts:write"),
              json.string("billing:refund"),
            ],
            of: fn(value) { value },
          ),
        ),
      version: inertia.NullVersion,
    )
    |> inertia.with_deferred_props([#("default", ["permissions"])])
    |> inertia.with_rescued_props(case rescued_permissions {
      True -> ["permissions"]
      False -> []
    })

  web.inertia_response(req, ctx, 200, "Rescued Deferred Props", page)
}

fn merge_demo(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let component = "protocol/merge"
  let batch = query_int(req, "batch", 1)
  let bounded_batch = clamp(batch, 1, 2)

  let page =
    inertia.page(
      component: component,
      props: [#("errors", json.object([]))]
        |> append_prop(
          "summary",
          json.object([
            #("batch", json.int(bounded_batch)),
            #(
              "totalPosts",
              json.int(case bounded_batch {
                1 -> 2
                _ -> 3
              }),
            ),
            #(
              "headline",
              json.string(case bounded_batch {
                1 -> "Initial batch"
                _ -> "Merged batch"
              }),
            ),
          ]),
        )
        |> append_prop("posts", case bounded_batch {
          1 -> merge_posts_batch_one()
          _ -> merge_posts_batch_two()
        })
        |> append_prop("alerts", case bounded_batch {
          1 -> alerts_batch_one()
          _ -> alerts_batch_two()
        })
        |> append_prop("hasMore", json.bool(bounded_batch < 2)),
      version: inertia.NullVersion,
    )
    |> inertia.with_merge_props(
      inertia.merge_props(
        append: ["posts"],
        prepend: ["alerts"],
        deep_merge: ["summary"],
        match_on: ["posts.id", "alerts.id"],
      ),
    )

  web.inertia_response(req, ctx, 200, "Merge Props", page)
}

fn scroll_demo(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])

  let component = "protocol/scroll"
  let current_page = clamp(query_int(req, "page", 1), 1, 3)

  let page =
    inertia.page(
      component: component,
      props: [
        #("errors", json.object([])),
        #("posts", scroll_posts_json(current_page)),
      ],
      version: inertia.NullVersion,
    )
    |> inertia.with_merge_props(
      inertia.merge_props(
        append: ["posts.data"],
        prepend: [],
        deep_merge: [],
        match_on: [],
      ),
    )
    |> inertia.with_scroll_props([
      #(
        "posts",
        inertia.scroll_prop(
          page_name: "page",
          previous_page: case current_page > 1 {
            True -> Some(current_page - 1)
            False -> None
          },
          next_page: case current_page < 3 {
            True -> Some(current_page + 1)
            False -> None
          },
          current_page: current_page,
        ),
      ),
    ])

  web.inertia_response(req, ctx, 200, "Scroll Props", page)
}

fn once_source_demo(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])
  web.inertia_response(
    req,
    ctx,
    200,
    "Once Props",
    once_page(
      req,
      "protocol/once/source",
      "plans",
      "plans",
      "catalog-snapshot-source-2026-05-24",
    ),
  )
}

fn once_target_demo(req: web.Request, ctx: web.Context) -> web.Response {
  use <- web.require_methods(req, [Get, Head])
  web.inertia_response(
    req,
    ctx,
    200,
    "Once Props Target",
    once_page(
      req,
      "protocol/once/target",
      "availablePlans",
      "catalog",
      "catalog-snapshot-target-2026-05-24",
    ),
  )
}

fn once_page(
  req: web.Request,
  component: String,
  prop_name: String,
  page_label: String,
  generated_at: String,
) -> inertia.Page {
  let once_key = "catalog"

  inertia.page(
    component: component,
    props: [#("errors", json.object([]))]
      |> append_prop("pageLabel", json.string(page_label))
      |> append_prop("serverLabel", json.string("fresh-on-every-response"))
      |> append_prop_if(
        !inertia.should_skip_once_prop(req, component, prop_name, once_key),
        prop_name,
        once_catalog_json(generated_at),
      ),
    version: inertia.NullVersion,
  )
  |> inertia.with_once_props([
    #(once_key, inertia.once_prop(prop: prop_name, expires_at: None)),
  ])
}

fn append_prop(
  props: List(#(String, json.Json)),
  key: String,
  value: json.Json,
) -> List(#(String, json.Json)) {
  list.append(props, [#(key, value)])
}

fn append_prop_if(
  props: List(#(String, json.Json)),
  include: Bool,
  key: String,
  value: json.Json,
) -> List(#(String, json.Json)) {
  case include {
    True -> append_prop(props, key, value)
    False -> props
  }
}

fn query_int(req: web.Request, key: String, default: Int) -> Int {
  case request.get_query(req) {
    Ok(query) -> {
      let found =
        query
        |> list.find(fn(pair) {
          let #(name, _value) = pair
          name == key
        })

      case found {
        Ok(#(_, value)) -> int.parse(value) |> result.unwrap(default)
        Error(_) -> default
      }
    }

    Error(_) -> default
  }
}

fn clamp(value: Int, min_value: Int, max_value: Int) -> Int {
  case value < min_value {
    True -> min_value
    False ->
      case value > max_value {
        True -> max_value
        False -> value
      }
  }
}

fn post(id: Int, title: String, status: String) -> json.Json {
  json.object([
    #("id", json.int(id)),
    #("title", json.string(title)),
    #("status", json.string(status)),
  ])
}

fn alert(id: String, message: String) -> json.Json {
  json.object([
    #("id", json.string(id)),
    #("message", json.string(message)),
  ])
}

fn merge_posts_batch_one() -> json.Json {
  json.array(
    [
      post(1, "Instrument page object payloads", "stable"),
      post(2, "Verify partial reload merging", "queued"),
    ],
    of: fn(value) { value },
  )
}

fn merge_posts_batch_two() -> json.Json {
  json.array(
    [
      post(2, "Verify partial reload merging", "updated"),
      post(3, "Document protocol edge cases", "ready"),
    ],
    of: fn(value) { value },
  )
}

fn alerts_batch_one() -> json.Json {
  json.array([alert("seed", "Initial alert")], of: fn(value) { value })
}

fn alerts_batch_two() -> json.Json {
  json.array([alert("latest", "Prepended alert")], of: fn(value) { value })
}

fn scroll_posts_json(current_page: Int) -> json.Json {
  json.object([
    #("data", scroll_posts_data(current_page)),
  ])
}

fn scroll_posts_data(current_page: Int) -> json.Json {
  let items = case current_page {
    1 -> [
      post(1, "Scroll item 1", "page-1"),
      post(2, "Scroll item 2", "page-1"),
    ]
    2 -> [
      post(3, "Scroll item 3", "page-2"),
      post(4, "Scroll item 4", "page-2"),
    ]
    _ -> [
      post(5, "Scroll item 5", "page-3"),
      post(6, "Scroll item 6", "page-3"),
    ]
  }

  json.array(items, of: fn(value) { value })
}

fn once_catalog_json(generated_at: String) -> json.Json {
  json.object([
    #("generatedAt", json.string(generated_at)),
    #(
      "items",
      json.array(
        [
          json.object([#("id", json.int(1)), #("name", json.string("Starter"))]),
          json.object([#("id", json.int(2)), #("name", json.string("Growth"))]),
          json.object([#("id", json.int(3)), #("name", json.string("Scale"))]),
        ],
        of: fn(value) { value },
      ),
    ),
  ])
}
