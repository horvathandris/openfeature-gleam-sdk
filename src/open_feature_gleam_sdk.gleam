import gleam/io
import gleam/dict
import gleam/option.{None}
import providers/in_memory_provider.{in_memory_provider}

pub fn main() {
  io.println("Hello from features!")

  let flags =
    dict.new()
    |> dict.insert("flag-1", True)
  let provider = in_memory_provider(flags)
  io.debug(provider.resolve_boolean_evaluation("flag-1", False, None))
}
