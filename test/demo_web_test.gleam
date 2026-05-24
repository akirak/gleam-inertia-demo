import gleam/json
import gleam/option.{None, Some}
import gleeunit
import utils/inertia

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn page_object_with_deferred_props_test() {
  let page =
    inertia.page(
      component: "Posts/Index",
      props: [
        #("errors", json.object([])),
        #("user", json.object([#("name", json.string("Jonathan"))])),
      ],
      version: inertia.StringVersion("6b16b94d7c51cbe5b1fa42aac98241d5"),
    )
    |> inertia.with_deferred_props([
      #("default", ["comments", "analytics"]),
      #("sidebar", ["relatedPosts"]),
    ])

  let expected =
    json.object([
      #("component", json.string("Posts/Index")),
      #(
        "props",
        json.object([
          #("errors", json.object([])),
          #("user", json.object([#("name", json.string("Jonathan"))])),
        ]),
      ),
      #("url", json.string("/posts")),
      #("version", json.string("6b16b94d7c51cbe5b1fa42aac98241d5")),
      #(
        "deferredProps",
        json.object([
          #("default", json.array(["comments", "analytics"], of: json.string)),
          #("sidebar", json.array(["relatedPosts"], of: json.string)),
        ]),
      ),
    ])

  assert json.to_string(inertia.page_component_json("/posts", page))
    == json.to_string(expected)
}

pub fn page_object_with_rescued_deferred_props_test() {
  let page =
    inertia.page(
      component: "Users/Index",
      props: [#("errors", json.object([]))],
      version: inertia.StringVersion("6b16b94d7c51cbe5b1fa42aac98241d5"),
    )
    |> inertia.with_rescued_props(["permissions"])

  let expected =
    json.object([
      #("component", json.string("Users/Index")),
      #("props", json.object([#("errors", json.object([]))])),
      #("url", json.string("/users")),
      #("version", json.string("6b16b94d7c51cbe5b1fa42aac98241d5")),
      #("rescuedProps", json.array(["permissions"], of: json.string)),
    ])

  assert json.to_string(inertia.page_component_json("/users", page))
    == json.to_string(expected)
}

pub fn page_object_with_merge_props_test() {
  let page =
    inertia.page(
      component: "Feed/Index",
      props: [
        #("errors", json.object([])),
        #("user", json.object([#("name", json.string("Jonathan"))])),
        #(
          "posts",
          json.array(
            [
              json.object([
                #("id", json.int(1)),
                #("title", json.string("First Post")),
              ]),
            ],
            of: fn(value) { value },
          ),
        ),
        #(
          "notifications",
          json.array(
            [
              json.object([
                #("id", json.int(2)),
                #("message", json.string("New comment")),
              ]),
            ],
            of: fn(value) { value },
          ),
        ),
        #(
          "conversations",
          json.object([
            #(
              "data",
              json.array(
                [
                  json.object([
                    #("id", json.int(1)),
                    #("title", json.string("Support Chat")),
                    #(
                      "participants",
                      json.array(["John", "Jane"], of: json.string),
                    ),
                  ]),
                ],
                of: fn(value) { value },
              ),
            ),
          ]),
        ),
      ],
      version: inertia.StringVersion("6b16b94d7c51cbe5b1fa42aac98241d5"),
    )
    |> inertia.with_merge_props(
      inertia.merge_props(
        append: ["posts"],
        prepend: ["notifications"],
        deep_merge: ["conversations"],
        match_on: ["posts.id", "notifications.id", "conversations.data.id"],
      ),
    )

  let expected =
    json.object([
      #("component", json.string("Feed/Index")),
      #(
        "props",
        json.object([
          #("errors", json.object([])),
          #("user", json.object([#("name", json.string("Jonathan"))])),
          #(
            "posts",
            json.array(
              [
                json.object([
                  #("id", json.int(1)),
                  #("title", json.string("First Post")),
                ]),
              ],
              of: fn(value) { value },
            ),
          ),
          #(
            "notifications",
            json.array(
              [
                json.object([
                  #("id", json.int(2)),
                  #("message", json.string("New comment")),
                ]),
              ],
              of: fn(value) { value },
            ),
          ),
          #(
            "conversations",
            json.object([
              #(
                "data",
                json.array(
                  [
                    json.object([
                      #("id", json.int(1)),
                      #("title", json.string("Support Chat")),
                      #(
                        "participants",
                        json.array(["John", "Jane"], of: json.string),
                      ),
                    ]),
                  ],
                  of: fn(value) { value },
                ),
              ),
            ]),
          ),
        ]),
      ),
      #("url", json.string("/feed")),
      #("version", json.string("6b16b94d7c51cbe5b1fa42aac98241d5")),
      #("mergeProps", json.array(["posts"], of: json.string)),
      #("prependProps", json.array(["notifications"], of: json.string)),
      #("deepMergeProps", json.array(["conversations"], of: json.string)),
      #(
        "matchPropsOn",
        json.array(
          ["posts.id", "notifications.id", "conversations.data.id"],
          of: json.string,
        ),
      ),
    ])

  assert json.to_string(inertia.page_component_json("/feed", page))
    == json.to_string(expected)
}

pub fn page_object_with_scroll_props_test() {
  let page =
    inertia.page(
      component: "Posts/Index",
      props: [
        #("errors", json.object([])),
        #(
          "posts",
          json.object([
            #(
              "data",
              json.array(
                [
                  json.object([
                    #("id", json.int(1)),
                    #("title", json.string("First Post")),
                  ]),
                  json.object([
                    #("id", json.int(2)),
                    #("title", json.string("Second Post")),
                  ]),
                ],
                of: fn(value) { value },
              ),
            ),
          ]),
        ),
      ],
      version: inertia.StringVersion("6b16b94d7c51cbe5b1fa42aac98241d5"),
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
          previous_page: None,
          next_page: Some(2),
          current_page: 1,
        ),
      ),
    ])

  let expected =
    json.object([
      #("component", json.string("Posts/Index")),
      #(
        "props",
        json.object([
          #("errors", json.object([])),
          #(
            "posts",
            json.object([
              #(
                "data",
                json.array(
                  [
                    json.object([
                      #("id", json.int(1)),
                      #("title", json.string("First Post")),
                    ]),
                    json.object([
                      #("id", json.int(2)),
                      #("title", json.string("Second Post")),
                    ]),
                  ],
                  of: fn(value) { value },
                ),
              ),
            ]),
          ),
        ]),
      ),
      #("url", json.string("/posts?page=1")),
      #("version", json.string("6b16b94d7c51cbe5b1fa42aac98241d5")),
      #("mergeProps", json.array(["posts.data"], of: json.string)),
      #(
        "scrollProps",
        json.object([
          #(
            "posts",
            json.object([
              #("pageName", json.string("page")),
              #("previousPage", json.null()),
              #("nextPage", json.int(2)),
              #("currentPage", json.int(1)),
            ]),
          ),
        ]),
      ),
    ])

  assert json.to_string(inertia.page_component_json("/posts?page=1", page))
    == json.to_string(expected)
}

pub fn page_object_with_once_props_test() {
  let page =
    inertia.page(
      component: "Billing/Plans",
      props: [
        #("errors", json.object([])),
        #(
          "plans",
          json.array(
            [
              json.object([
                #("id", json.int(1)),
                #("name", json.string("Basic")),
              ]),
              json.object([#("id", json.int(2)), #("name", json.string("Pro"))]),
            ],
            of: fn(value) { value },
          ),
        ),
      ],
      version: inertia.StringVersion("6b16b94d7c51cbe5b1fa42aac98241d5"),
    )
    |> inertia.with_once_props([
      #("plans", inertia.once_prop(prop: "plans", expires_at: None)),
    ])

  let expected =
    json.object([
      #("component", json.string("Billing/Plans")),
      #(
        "props",
        json.object([
          #("errors", json.object([])),
          #(
            "plans",
            json.array(
              [
                json.object([
                  #("id", json.int(1)),
                  #("name", json.string("Basic")),
                ]),
                json.object([
                  #("id", json.int(2)),
                  #("name", json.string("Pro")),
                ]),
              ],
              of: fn(value) { value },
            ),
          ),
        ]),
      ),
      #("url", json.string("/billing/plans")),
      #("version", json.string("6b16b94d7c51cbe5b1fa42aac98241d5")),
      #(
        "onceProps",
        json.object([
          #(
            "plans",
            json.object([
              #("prop", json.string("plans")),
              #("expiresAt", json.null()),
            ]),
          ),
        ]),
      ),
    ])

  assert json.to_string(inertia.page_component_json("/billing/plans", page))
    == json.to_string(expected)
}
