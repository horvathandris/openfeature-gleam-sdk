import metadata.{type Metadata}
import evaluation.{type BooleanEvaluation}

pub type FeatureProvider {
  FeatureProvider(
    get_metadata: fn() -> Metadata,
    resolve_boolean_evaluation: BooleanEvaluation,
  )
}
