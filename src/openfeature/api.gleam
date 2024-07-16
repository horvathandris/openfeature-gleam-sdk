import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import openfeature/client.{type Client, Client, ClientMetadata}
import openfeature/domain
import openfeature/evaluation_context.{type EvaluationContext, EvaluationContext}
import openfeature/provider.{type FeatureProvider, type Metadata}
import openfeature/providers/no_op

const global_provider_key = "global_openfeature_provider"

const global_context_key = "global_openfeature_context"

const domain_provider_registry_key = "openfeature_domain_providers"

pub fn set_provider(provider: FeatureProvider) -> Result(Nil, Nil) {
  persistent_term_put(global_provider_key, provider)
  let context =
    persistent_term_get(global_context_key, evaluation_context.empty())
  provider.initialize(context)
}

fn get_provider() -> FeatureProvider {
  persistent_term_get(global_provider_key, no_op.provider())
}

pub fn get_provider_metadata() -> Metadata {
  get_provider().get_metadata()
}

fn get_domain_provider_registry() -> Dict(String, FeatureProvider) {
  persistent_term_get(domain_provider_registry_key, dict.new())
}

pub fn set_domain_provider(domain: String, provider: FeatureProvider) -> Nil {
  get_domain_provider_registry()
  |> dict.insert(domain, provider)
  |> persistent_term_put(domain_provider_registry_key, _)
}

fn get_domain_provider(domain: String) -> FeatureProvider {
  get_domain_provider_registry()
  |> dict.get(domain)
  |> result.unwrap(get_provider())
}

pub fn get_domain_provider_metadata(domain: String) -> Metadata {
  get_domain_provider(domain).get_metadata()
}

pub fn get_client() {
  Client(
    provider: get_provider(),
    metadata: ClientMetadata(domain.Global),
    evaluation_context: evaluation_context.empty(),
  )
}

/// Initialise and retrieve a new client for the provided domain.
/// If the domain has a corresponding provider registered, the client will use that provider.
/// Otherwise, the global default provider is used.
pub fn get_domain_client(domain: String) {
  Client(
    provider: get_domain_provider(domain),
    metadata: ClientMetadata(domain.Scoped(domain)),
    evaluation_context: evaluation_context.empty(),
  )
}

pub fn set_context(context: EvaluationContext) -> Nil {
  persistent_term_put(global_context_key, context)
}

pub fn shutdown() {
  get_domain_provider_registry()
  |> dict.values
  |> list.prepend(get_provider())
  |> list.each(fn(provider: FeatureProvider) { provider.shutdown() })

  persistent_term_erase(domain_provider_registry_key)
  persistent_term_erase(global_provider_key)
  persistent_term_erase(global_context_key)
}

@external(erlang, "persistent_term", "get")
fn persistent_term_get(key: String, default_value: a) -> a

@external(erlang, "persistent_term", "put")
fn persistent_term_put(key: String, value: a) -> Nil

@external(erlang, "persistent_term", "erase")
fn persistent_term_erase(key: String) -> Bool
