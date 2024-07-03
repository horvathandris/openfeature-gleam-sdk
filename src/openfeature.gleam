import provider.{type FeatureProvider}
import persistent_term
import gleam/option.{type Option, None, Some}
import evaluation_context.{type EvaluationContext, empty_evaluation_context}

const persistent_term_key = "openfeature_api"

fn default_api() {
  API(None, empty_evaluation_context())
}

pub opaque type API {
  API(provider: Option(FeatureProvider), context: EvaluationContext)
}

pub fn set_provider(provider: FeatureProvider) -> Nil {
  let api = persistent_term.get(persistent_term_key, default_api())
  let new_api = API(Some(provider), api.context)
  persistent_term.put(persistent_term_key, new_api)
  provider.initialize(api.context)
}

pub fn set_context(context: EvaluationContext) {
  let api = persistent_term.get(persistent_term_key, default_api())
  let new_api = API(api.provider, context)
  persistent_term.put(persistent_term_key, new_api)
}
