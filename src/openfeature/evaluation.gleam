import gleam/dynamic.{type Dynamic}
import openfeature/evaluation_context.{type EvaluationContext}

pub type Reason {
  Disabled
  Split
  TargetingMatch
  Default
  Unknown
  Cached
  Static
  Error
}

type GenericEvaluation(value) =
  fn(String, value, EvaluationContext) -> ResolutionDetails(value)

pub type BoolEvaluation =
  GenericEvaluation(Bool)

pub type StringEvaluation =
  GenericEvaluation(String)

pub type IntEvaluation =
  GenericEvaluation(Int)

pub type FloatEvaluation =
  GenericEvaluation(Float)

pub type DynamicEvaluation =
  GenericEvaluation(Dynamic)

pub type ResolutionDetails(value) {
  ResolutionSuccess(value: value, reason: Reason)
  ResolutionError(
    value: value,
    reason: Reason,
    code: ErrorCode,
    message: String,
  )
}

pub type ErrorCode {
  ProviderNotReady
  FlagNotFound
  ParseError
  TypeMismatch
  TargetingKeyMissing
  InvalidContext
  General
}
