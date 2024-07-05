import openfeature/evaluation.{Default, ResolutionSuccess}
import openfeature/provider.{
  type FeatureProvider, type Metadata, FeatureProvider, Metadata,
}

pub fn provider() {
  FeatureProvider(
    get_metadata: get_metadata,
    initialize: fn(_context) { Ok(Nil) },
    shutdown: fn() { Nil },
    resolve_bool_evaluation: fn(_flag, default_value, _evaluation_context) {
      ResolutionSuccess(default_value, Default)
    },
    resolve_string_evaluation: fn(_flag, default_value, _evaluation_context) {
      ResolutionSuccess(default_value, Default)
    },
    resolve_int_evaluation: fn(_flag, default_value, _evaluation_context) {
      ResolutionSuccess(default_value, Default)
    },
    resolve_float_evaluation: fn(_flag, default_value, _evaluation_context) {
      ResolutionSuccess(default_value, Default)
    },
    resolve_dynamic_evaluation: fn(_flag, default_value, _evaluation_context) {
      ResolutionSuccess(default_value, Default)
    },
  )
}

fn get_metadata() -> Metadata {
  Metadata("No-op Provider")
}
