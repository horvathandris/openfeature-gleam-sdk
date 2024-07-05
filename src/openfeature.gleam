import api
import gleam/dict
import gleam/io
import gleam/option.{None}
import providers/in_memory.{in_memory_provider}

pub fn main() {
  io.println("Hello from features!")

  let flags =
    dict.new()
    |> dict.insert("flag-1", True)
  let provider = in_memory_provider(flags)
  io.debug(provider.resolve_bool_evaluation("flag-1", False, None))
  io.debug(provider.resolve_bool_evaluation("flag-2", True, None))
  io.debug(provider.get_metadata())

  io.debug(api.get_provider_metadata())

  api.set_provider(provider)

  io.debug(api.get_provider_metadata())
  io.debug(api.get_domain_provider_metadata("some-domain"))
}
