# OpenFeature Gleam SDK

[![Package Version](https://img.shields.io/hexpm/v/openfeature)](https://hex.pm/packages/openfeature)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/openfeature/)

[OpenFeature](https://openfeature.dev) is an open specification that provides a vendor-agnostic, community-driven API for feature flagging that works with your favorite feature flag management tool.

This repository contains the unofficial SDK implementation of the [specification](https://openfeature.dev/specification/) for the [Gleam](https://gleam.run/) programming language.

## 🚀 Quick start

### Requirements

- Gleam [1+](https://github.com/gleam-lang/gleam/releases/tag/v1.0.0)

### Install

```sh
gleam add openfeature
```

### Usage

```gleam
import gleam/bool
import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/option.{None}
import openfeature
import openfeature/client
import openfeature/evaluation_context
import openfeature/providers/in_memory

pub fn main() {
  // flags defined in memory
  let v2_flag =
    in_memory.Flag(
      default_variant: "off",
      variants: dict.from_list([
        #("off", dynamic.from(False)),
        #("on", dynamic.from(True)),
      ]),
      context_evaluator: None,
    )
  let flags = dict.from_list([#("v2_enabled", v2_flag)])

  // configure a provider
  let _ = openfeature.set_provider(in_memory.provider(flags))

  // get a bool flag value
  let flag_value =
    openfeature.get_client()
    |> client.get_bool_value("v2_enabled", False, evaluation_context.empty())

  // use the returned flag value
  io.println("`v2_enabled` evaluated to: " <> bool.to_string(flag_value))
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
import openfeature

openfeature.set_provider(my_provider())
```

In some situations, it may be beneficial to register multiple providers in the same application. This is possible using [domains](#domains), which is covered in more details below.

### Targeting

Sometimes, the value of a flag must consider some dynamic criteria about the application or user, such as the user's location, IP, email address, or the server's location. In OpenFeature, we refer to this as [targeting](https://openfeature.dev/specification/glossary#targeting). If the flag management system you're using supports targeting, you can provide the input data using the [evaluation context](https://openfeature.dev/docs/reference/concepts/evaluation-context).

```gleam
import gleam/dynamic
import gleam/option.{None}
import openfeature
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
client.get_bool_details(
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
import openfeature

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
import openfeature

openfeature.shutdown()
```

## Extending

### Develop a provider

To develop a provider, you need to create a new project and include the OpenFeature SDK as a dependency. This can be a new repository ~~or included in the existing contrib repository available under the OpenFeature organization~~. You’ll then need to write the provider by exporting a function that returns a value of type `FeatureProvider`, exported by the OpenFeature SDK.

```gleam
import gleam/dynamic.{type Dynamic}
import openfeature/evaluation_context.{type EvaluationContext}
import openfeature/provider.{type FeatureProvider, FeatureProvider}

pub fn my_provider() -> FeatureProvider {
  FeatureProvider(
    get_metadata: fn() { provider.Metadata("My Provider") },
    initialize: fn(evaluation_context: EvaluationContext) {
      // code to initialize your provider
      todo
    },
    shutdown: fn() {
      // code to shutdown your provider
      todo
    },
    resolve_bool_evaluation: fn(
      flag: String,
      default_value: Bool,
      evaluation_context: EvaluationContext,
    ) {
      // code to evaluate a boolean value
      todo
    },
    resolve_string_evaluation: fn(
      flag: String,
      default_value: String,
      evaluation_context: EvaluationContext,
    ) {
      // code to evaluate a string value
      todo
    },
    resolve_int_evaluation: fn(
      flag: String,
      default_value: Int,
      evaluation_context: EvaluationContext,
    ) {
      // code to evaluate an integer value
      todo
    },
    resolve_float_evaluation: fn(
      flag: String,
      default_value: Float,
      evaluation_context: EvaluationContext,
    ) {
      // code to evaluate a float value
      todo
    },
    resolve_dynamic_evaluation: fn(
      flag: String,
      default_value: Dynamic,
      evaluation_context: EvaluationContext,
    ) {
      // code to evaluate a dynamic value
      todo
    },
  )
}
```

### Develop a hook

TODO
