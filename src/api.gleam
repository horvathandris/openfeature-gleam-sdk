import evaluation_context.{type EvaluationContext, empty_evaluation_context}
import gleam/option.{type Option, None, Some}
import perterm
import provider.{type FeatureProvider}

const persistent_term_key = "openfeature_api"

fn default_api() {
  API(None, empty_evaluation_context())
}

pub opaque type API {
  API(provider: Option(FeatureProvider), context: EvaluationContext)
}

pub fn set_provider(provider: FeatureProvider) -> Nil {
  let api = perterm.get(persistent_term_key, default_api())
  let new_api = API(Some(provider), api.context)
  perterm.put(persistent_term_key, new_api)
  provider.initialize(api.context)
}

pub fn set_context(context: EvaluationContext) -> Nil {
  let api = perterm.get(persistent_term_key, default_api())
  let new_api = API(api.provider, context)
  perterm.put(persistent_term_key, new_api)
}
