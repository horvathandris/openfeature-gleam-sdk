import evaluation_context.{type EvaluationContext, empty_evaluation_context}
import gleam/option.{type Option, None, Some}
import provider.{type FeatureProvider}
import metadata.{type Metadata}

const persistent_term_key = "openfeature_api"

const domain_provider_key_prefix = "domain_provider__"

fn default_api() {
  API(None, empty_evaluation_context())
}

pub opaque type API {
  API(provider: Option(FeatureProvider), context: EvaluationContext)
}

pub fn set_provider(provider: FeatureProvider) -> Result(Nil, Nil) {
  let api = persistent_term_get(persistent_term_key, default_api())
  let new_api = API(Some(provider), api.context)
  persistent_term_put(persistent_term_key, new_api)
  provider.initialize(api.context)
}

pub fn get_provider_metadata() -> Option(Metadata) {
  persistent_term_get(persistent_term_key, default_api()).provider
  |> option.map(fn(provider: FeatureProvider) { provider.get_metadata() })
}

pub fn set_domain_provider(domain: String, provider: FeatureProvider) -> Nil {
  persistent_term_put(domain_provider_key_prefix <> domain, provider)
}

pub fn get_domain_provider_metadata(domain: String) -> Option(Metadata) {
  persistent_term_get(domain_provider_key_prefix <> domain, None)
  |> option.map(fn(provider: FeatureProvider) { provider.get_metadata() })
}

pub fn set_context(context: EvaluationContext) -> Nil {
  let api = persistent_term_get(persistent_term_key, default_api())
  let new_api = API(api.provider, context)
  persistent_term_put(persistent_term_key, new_api)
}

@external(erlang, "persistent_term", "get")
pub fn persistent_term_get(key: String, default_value: a) -> a

@external(erlang, "persistent_term", "put")
pub fn persistent_term_put(key: String, value: a) -> Nil
