import evaluation_context.{type EvaluationContext, empty_evaluation_context}
import gleam/option.{type Option, None, Some}
import perterm
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
  let api = perterm.get(persistent_term_key, default_api())
  let new_api = API(Some(provider), api.context)
  perterm.put(persistent_term_key, new_api)
  provider.initialize(api.context)
}

pub fn get_provider_metadata() -> Option(Metadata) {
  perterm.get(persistent_term_key, default_api()).provider
  |> option.map(fn(provider: FeatureProvider) { provider.get_metadata() })
}

pub fn set_domain_provider(domain: String, provider: FeatureProvider) -> Nil {
  perterm.put(domain_provider_key_prefix <> domain, provider)
}

pub fn get_domain_provider_metadata(domain: String) -> Option(Metadata) {
  perterm.get(domain_provider_key_prefix <> domain, None)
  |> option.map(fn(provider: FeatureProvider) { provider.get_metadata() })
}

pub fn set_context(context: EvaluationContext) -> Nil {
  let api = perterm.get(persistent_term_key, default_api())
  let new_api = API(api.provider, context)
  perterm.put(persistent_term_key, new_api)
}
