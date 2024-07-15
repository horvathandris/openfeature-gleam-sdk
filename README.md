# OpenFeature Gleam SDK

[![Package Version](https://img.shields.io/hexpm/v/openfeature)](https://hex.pm/packages/openfeature)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/openfeature/)

An SDK for the OpenFeature specification.

```sh
gleam add openfeature
```
```gleam
import gleam/bool
import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/option.{None}
import openfeature/api as openfeature
import openfeature/client
import openfeature/evaluation.{type ResolutionDetails}
import openfeature/evaluation_context
import openfeature/providers/in_memory

pub fn main() {
  let test_flag =
    in_memory.InMemoryFlag(
      "off",
      dict.from_list([
        #("off", dynamic.from(False)),
        #("on", dynamic.from(True)),
      ]),
      None,
    )
  let flags = dict.from_list([#("test_flag", test_flag)])
  let provider = in_memory.provider(flags)
  let _ = openfeature.set_provider(provider)
  // set global provider

  io.println(
    "`test_flag` evaluated to " <> bool.to_string(evaluate_flag("test_flag")),
  )
}

fn evaluate_flag(flag: String) -> Bool {
  openfeature.get_client()
  |> client.resolve_bool_evaluation(flag, False, evaluation_context.empty())
  |> fn(details: ResolutionDetails(Bool)) { details.value }
}
```

Further documentation can be found at <https://hexdocs.pm/openfeature>.

## 🌟 Features

| Status | Features                        | Description                                                                                                                        |
| ------ | ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| ✅      | [Providers](#providers)         | Integrate with a commercial, open source, or in-house feature management tool.                                                     |
| ✅      | [Targeting](#targeting)         | Contextually-aware flag evaluation using [evaluation context](https://openfeature.dev/docs/reference/concepts/evaluation-context). |
| ❌      | [Hooks](#hooks)                 | Add functionality to various stages of the flag evaluation life-cycle.                                                             |
| ❌      | [Logging](#logging)             | Integrate with popular logging packages.                                                                                           |
| ✅      | [Domains](#domains)             | Logically bind clients with providers.                                                                                             |
| ❌      | [Eventing](#eventing)           | React to state changes in the provider or flag management system.                                                                  |
| ⚠️      | [Shutdown](#shutdown)           | Gracefully clean up a provider during application shutdown.                                                                        |
| ⚠️      | [Extending](#extending)         | Extend OpenFeature with custom providers and hooks.                                                                                |

<sub>Implemented: ✅ | In-progress: ⚠️ | Not implemented yet: ❌</sub>

### Providers

TODO

### Targeting

TODO

### Hooks

TODO

### Logging

TODO

### Domains

TODO

### Eventing

TODO

### Shutdown

TODO

## Extending

### Develop a provider

TODO

### Develop a hook

TODO
