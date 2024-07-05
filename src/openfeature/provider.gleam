import openfeature/evaluation.{
  type BoolEvaluation, type DynamicEvaluation, type FloatEvaluation,
  type IntEvaluation, type StringEvaluation,
}
import openfeature/evaluation_context.{type EvaluationContext}

pub type FeatureProvider {
  FeatureProvider(
    initialize: fn(EvaluationContext) -> Result(Nil, Nil),
    shutdown: fn() -> Nil,
    get_metadata: fn() -> Metadata,
    resolve_bool_evaluation: BoolEvaluation,
    resolve_string_evaluation: StringEvaluation,
    resolve_int_evaluation: IntEvaluation,
    resolve_float_evaluation: FloatEvaluation,
    resolve_dynamic_evaluation: DynamicEvaluation,
  )
}

pub type Metadata {
  Metadata(name: String)
}
