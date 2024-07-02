import gleam/option.{type Option}

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

pub type EvaluationContext

pub type BooleanEvaluation =
  fn(String, Bool, Option(EvaluationContext)) -> ResolutionDetails(Bool)

pub type ResolutionDetails(value) {
  SuccessfulResolution(value: value, reason: Reason)
  ErrorneousResolution(code: ErrorCode, message: String)
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
