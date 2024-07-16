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
    in_memory.Flag(
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
| ✅      | [Shutdown](#shutdown)           | Gracefully clean up a provider during application shutdown.                                                                        |
| ⚠️      | [Extending](#extending)         | Extend OpenFeature with custom providers and hooks.                                                                                |

<sub>Implemented: ✅ | In-progress: ⚠️ | Not implemented yet: ❌</sub>

### Providers

[Providers](https://openfeature.dev/docs/reference/concepts/provider) are an abstraction between a flag management system and the OpenFeature SDK. Look [here](https://openfeature.dev/ecosystem?instant_search%5BrefinementList%5D%5Btype%5D%5B0%5D=Provider&instant_search%5BrefinementList%5D%5Btechnology%5D%5B0%5D=Gleam) for a complete list of available providers. If the provider you're looking for hasn't been created yet, see the [develop a provider](#develop-a-provider) section to learn how to build it yourself.

Once you've added a provider as a dependency, it can be registered with OpenFeature like this:

```gleam
import openfeature/api as openfeature

openfeature.set_provider(my_provider())
```

In some situations, it may be beneficial to register multiple providers in the same application. This is possible using [domains](#domains), which is covered in more details below.

### Targeting

Sometimes, the value of a flag must consider some dynamic criteria about the application or user, such as the user's location, IP, email address, or the server's location. In OpenFeature, we refer to this as [targeting](https://openfeature.dev/specification/glossary#targeting). If the flag management system you're using supports targeting, you can provide the input data using the [evaluation context](https://openfeature.dev/docs/reference/concepts/evaluation-context).

```gleam
import gleam/dynamic
import gleam/option.{None}
import openfeature/api as openfeature
import openfeature/client
import openfeature/evaluation_context.{EvaluationContext}

// set the global evaluation context
openfeature.set_context(
  evaluation_context.targetless([
    #("region", dynamic.from("us-east-1-iah-1a")),
  ])
)

// set the client evaluation context
let my_app_client =
  openfeature.get_domain_client("my-app")
  |> client.set_context(
    evaluation_context.targetless([
      #("version",  dynamic.from("1.4.6")),
    ])
  )

// set the invocation context
client.resolve_bool_evaluation(
  my_app_client,
  "bool-flag",
  False,
  evaluation_context.targeted(
    "userId:1234",
    [#("company", dynamic.from("Wise"))]
  ),
)
```

### Hooks

TODO

### Logging

TODO

### Domains

Clients can be assigned to a domain. A domain is a logical identifier which can be used to associate clients with a particular provider. If a domain has no associated provider, the default provider is used.

```gleam
import openfeature/api as openfeature

// registering the default provider
openfeature.set_provider(local_provider())
// registering a domain provider
openfeature.set_domain_provider("cached-domain", cached_provider())

// a client bound to the default provider
openfeature.get_client()
// a client bound to the cached provider
openfeature.get_domain_client("cached-domain")
```

### Eventing

TODO

### Shutdown

The OpenFeature API provides a close function to perform a cleanup of all registered providers. This should only be called when your application is in the process of shutting down.

```gleam
import openfeature/api as openfeature

openfeature.shutdown()
```

## Extending

### Develop a provider

TODO

### Develop a hook

TODO
