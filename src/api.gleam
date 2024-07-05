import evaluation_context.{type EvaluationContext, EvaluationContext}
import gleam/option.{None}
import gleam/dict
import provider.{type FeatureProvider}
import metadata.{type Metadata}
import client.{type Client, Client, ClientMetadata, global_domain}
import providers/noop.{no_op_provider}

const persistent_term_key = "openfeature_api"

const domain_provider_key_prefix = "domain_provider__"

fn default_api() {
  API(no_op_provider(), EvaluationContext(None, dict.new()))
}

pub type API {
  API(provider: FeatureProvider, context: EvaluationContext)
}

pub fn set_provider(provider: FeatureProvider) -> Result(Nil, Nil) {
  let api = persistent_term_get(persistent_term_key, default_api())
  let new_api = API(provider, api.context)
  persistent_term_put(persistent_term_key, new_api)
  provider.initialize(api.context)
}

fn get_provider() -> FeatureProvider {
  persistent_term_get(persistent_term_key, default_api()).provider
}

pub fn get_provider_metadata() -> Metadata {
  persistent_term_get(persistent_term_key, default_api()).provider.get_metadata()
}

pub fn set_domain_provider(domain: String, provider: FeatureProvider) -> Nil {
  persistent_term_put(domain_provider_key_prefix <> domain, provider)
}

fn get_domain_provider(domain: String) -> FeatureProvider {
  persistent_term_get(domain_provider_key_prefix <> domain, get_provider())
}

pub fn get_domain_provider_metadata(domain: String) -> Metadata {
  persistent_term_get(domain_provider_key_prefix <> domain, get_provider()).get_metadata()
}

pub fn get_client() {
  Client(provider: get_provider(), metadata: ClientMetadata(global_domain))
}

/// Initialise and retrieve a new client for the provided domain.
/// If the domain has a corresponding provider registered, the client will use that provider.
/// Otherwise, the global default provider is used.
pub fn get_domain_client(domain: String) {
  Client(
    provider: get_domain_provider(domain),
    metadata: ClientMetadata(domain),
  )
}

pub fn set_context(context: EvaluationContext) -> Nil {
  let api = persistent_term_get(persistent_term_key, default_api())
  let new_api = API(api.provider, context)
  persistent_term_put(persistent_term_key, new_api)
}

@external(erlang, "persistent_term", "get")
fn persistent_term_get(key: String, default_value: a) -> a

@external(erlang, "persistent_term", "put")
fn persistent_term_put(key: String, value: a) -> Nil
