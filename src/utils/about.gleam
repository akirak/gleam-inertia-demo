import gleam/erlang/atom
import gleam/erlang/charlist.{type Charlist}

@external(erlang, "erlang", "system_info")
fn system_info(key: atom) -> Charlist

pub fn get_system_version() -> String {
  let assert Ok(the_atom) = atom.get("system_version")

  system_info(the_atom)
  |> charlist.to_string
}
