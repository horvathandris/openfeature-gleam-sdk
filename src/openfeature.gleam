import gleam/dict
import gleam/io
import gleam/option.{None}
import providers/in_memory_provider.{in_memory_provider}
import api

pub fn main() {
  io.println("Hello from features!")

  let flags =
    dict.new()
    |> dict.insert("flag-1", True)
  let provider = in_memory_provider(flags)
  io.debug(provider.resolve_bool_evaluation("flag-1", False, None))
  io.debug(provider.resolve_bool_evaluation("flag-2", True, None))
  io.debug(provider.get_metadata())

  api.set_provider(provider)
}
