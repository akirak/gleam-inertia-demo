import gleam/http/request
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import mist

pub type Page {
  Page(
    component: String,
    props: List(#(String, json.Json)),
    version: Version,
    deferred_props: DeferredProps,
    rescued_props: List(String),
    merge_props: MergeProps,
    scroll_props: ScrollProps,
    once_props: OnceProps,
  )
}

pub type Version {
  StringVersion(String)
  NullVersion
}

pub type DeferredProps =
  List(#(String, List(String)))

pub type MergeProps {
  MergeProps(
    append: List(String),
    prepend: List(String),
    deep_merge: List(String),
    match_on: List(String),
  )
}

pub type ScrollProp {
  ScrollProp(
    page_name: String,
    previous_page: Option(Int),
    next_page: Option(Int),
    current_page: Int,
  )
}

pub type ScrollProps =
  List(#(String, ScrollProp))

pub type OnceProp {
  OnceProp(prop: String, expires_at: Option(Int))
}

pub type OnceProps =
  List(#(String, OnceProp))

pub fn page(
  component component: String,
  props props: List(#(String, json.Json)),
  version version: Version,
) -> Page {
  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: [],
    rescued_props: [],
    merge_props: empty_merge_props(),
    scroll_props: [],
    once_props: [],
  )
}

pub fn empty_merge_props() -> MergeProps {
  MergeProps(append: [], prepend: [], deep_merge: [], match_on: [])
}

pub fn merge_props(
  append append: List(String),
  prepend prepend: List(String),
  deep_merge deep_merge: List(String),
  match_on match_on: List(String),
) -> MergeProps {
  MergeProps(
    append: append,
    prepend: prepend,
    deep_merge: deep_merge,
    match_on: match_on,
  )
}

pub fn scroll_prop(
  page_name page_name: String,
  previous_page previous_page: Option(Int),
  next_page next_page: Option(Int),
  current_page current_page: Int,
) -> ScrollProp {
  ScrollProp(
    page_name: page_name,
    previous_page: previous_page,
    next_page: next_page,
    current_page: current_page,
  )
}

pub fn once_prop(
  prop prop: String,
  expires_at expires_at: Option(Int),
) -> OnceProp {
  OnceProp(prop: prop, expires_at: expires_at)
}

pub fn with_deferred_props(page: Page, deferred_props: DeferredProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

pub fn with_rescued_props(page: Page, rescued_props: List(String)) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

pub fn with_merge_props(page: Page, merge_props: MergeProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    scroll_props: scroll_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

pub fn with_scroll_props(page: Page, scroll_props: ScrollProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    once_props: once_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

pub fn with_once_props(page: Page, once_props: OnceProps) -> Page {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    ..,
  ) = page

  Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  )
}

pub fn app_script(url: String, page: Page) -> List(Element(msg)) {
  [
    html.div([attribute.id("app")], []),
    html.script(
      [
        attribute.type_("application/json"),
        attribute.data("page", "app"),
      ],
      json.to_string(page_component_json(url, page)),
    ),
  ]
}

pub fn page_component_json(url: String, page: Page) -> json.Json {
  let Page(
    component: component,
    props: props,
    version: version,
    deferred_props: deferred_props,
    rescued_props: rescued_props,
    merge_props: merge_props,
    scroll_props: scroll_props,
    once_props: once_props,
  ) = page

  let json_version = case version {
    StringVersion(v) -> json.string(v)
    NullVersion -> json.null()
  }

  let fields =
    [
      #("component", json.string(component)),
      #("props", json.object(props)),
      #("url", json.string(url)),
      #("version", json_version),
    ]
    |> add_optional_field("deferredProps", deferred_props_json(deferred_props))
    |> add_optional_field("rescuedProps", string_array_json(rescued_props))
    |> add_merge_props_fields(merge_props)
    |> add_optional_field("scrollProps", scroll_props_json(scroll_props))
    |> add_optional_field("onceProps", once_props_json(once_props))

  json.object(fields)
}

pub fn is_inertia_request(request: request.Request(mist.Connection)) -> Bool {
  case header(request, "x-inertia") {
    Some(value) -> value == "true"
    None -> False
  }
}

pub fn request_url(request: request.Request(mist.Connection)) -> String {
  case request.get_query(request) {
    Ok([]) | Error(_) -> request.path
    Ok(query) -> request.path <> "?" <> uri.query_to_string(query)
  }
}

pub fn header(
  request: request.Request(mist.Connection),
  key: String,
) -> Option(String) {
  case request.get_header(request, string.lowercase(key)) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
}

pub fn header_csv(
  request: request.Request(mist.Connection),
  key: String,
) -> List(String) {
  case header(request, key) {
    Some(value) ->
      value
      |> string.split(on: ",")
      |> list.map(string.trim)
      |> list.filter(fn(item) { item != "" })

    None -> []
  }
}

pub fn is_partial_reload_for(
  request: request.Request(mist.Connection),
  component: String,
) -> Bool {
  header(request, "x-inertia-partial-component") == Some(component)
}

pub fn should_include_prop(
  request: request.Request(mist.Connection),
  component: String,
  key: String,
) -> Bool {
  case is_partial_reload_for(request, component) {
    False -> True
    True -> {
      let only = header_csv(request, "x-inertia-partial-data")
      let except = header_csv(request, "x-inertia-partial-except")

      case list.contains(except, key) {
        True -> False
        False ->
          case only {
            [] -> True
            _ -> list.contains(only, key)
          }
      }
    }
  }
}

pub fn should_skip_once_prop(
  request: request.Request(mist.Connection),
  component: String,
  prop_name: String,
  once_key: String,
) -> Bool {
  let loaded_keys = header_csv(request, "x-inertia-except-once-props")

  case list.contains(loaded_keys, once_key) {
    False -> False
    True -> {
      let requested_props = case is_partial_reload_for(request, component) {
        True -> header_csv(request, "x-inertia-partial-data")
        False -> []
      }

      let excluded_props = header_csv(request, "x-inertia-partial-except")

      case list.contains(excluded_props, prop_name) {
        True -> True
        False ->
          case requested_props {
            [] -> True
            _ -> !list.contains(requested_props, prop_name)
          }
      }
    }
  }
}

fn add_optional_field(
  fields: List(#(String, json.Json)),
  key: String,
  value: Option(json.Json),
) -> List(#(String, json.Json)) {
  case value {
    Some(value) -> list.append(fields, [#(key, value)])
    None -> fields
  }
}

fn add_merge_props_fields(
  fields: List(#(String, json.Json)),
  merge_props: MergeProps,
) -> List(#(String, json.Json)) {
  let MergeProps(
    append: append,
    prepend: prepend,
    deep_merge: deep_merge,
    match_on: match_on,
  ) = merge_props

  fields
  |> add_optional_field("mergeProps", string_array_json(append))
  |> add_optional_field("prependProps", string_array_json(prepend))
  |> add_optional_field("deepMergeProps", string_array_json(deep_merge))
  |> add_optional_field("matchPropsOn", string_array_json(match_on))
}

fn deferred_props_json(deferred_props: DeferredProps) -> Option(json.Json) {
  case deferred_props {
    [] -> None
    _ ->
      deferred_props
      |> list.map(fn(grouped_props) {
        let #(group, keys) = grouped_props
        #(group, json.array(keys, of: json.string))
      })
      |> json.object
      |> Some
  }
}

fn scroll_props_json(scroll_props: ScrollProps) -> Option(json.Json) {
  case scroll_props {
    [] -> None
    _ ->
      scroll_props
      |> list.map(fn(prop) {
        let #(key, value) = prop
        #(key, scroll_prop_json(value))
      })
      |> json.object
      |> Some
  }
}

fn scroll_prop_json(scroll_prop: ScrollProp) -> json.Json {
  let ScrollProp(
    page_name: page_name,
    previous_page: previous_page,
    next_page: next_page,
    current_page: current_page,
  ) = scroll_prop

  json.object([
    #("pageName", json.string(page_name)),
    #("previousPage", nullable_int_json(previous_page)),
    #("nextPage", nullable_int_json(next_page)),
    #("currentPage", json.int(current_page)),
  ])
}

fn once_props_json(once_props: OnceProps) -> Option(json.Json) {
  case once_props {
    [] -> None
    _ ->
      once_props
      |> list.map(fn(prop) {
        let #(key, value) = prop
        #(key, once_prop_json(value))
      })
      |> json.object
      |> Some
  }
}

fn once_prop_json(once_prop: OnceProp) -> json.Json {
  let OnceProp(prop: prop, expires_at: expires_at) = once_prop

  json.object([
    #("prop", json.string(prop)),
    #("expiresAt", nullable_int_json(expires_at)),
  ])
}

fn string_array_json(values: List(String)) -> Option(json.Json) {
  case values {
    [] -> None
    _ -> Some(json.array(values, of: json.string))
  }
}

fn nullable_int_json(value: Option(Int)) -> json.Json {
  case value {
    Some(value) -> json.int(value)
    None -> json.null()
  }
}
