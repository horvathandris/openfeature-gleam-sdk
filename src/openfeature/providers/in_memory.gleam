import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import openfeature/error
import openfeature/evaluation.{
  type ResolutionDetails, ResolutionError, ResolutionSuccess, Static,
}
import openfeature/evaluation_context.{type EvaluationContext}
import openfeature/provider.{FeatureProvider, Metadata}

pub type Flag {
  Flag(
    default_variant: String,
    variants: Variants,
    context_evaluator: Option(
      fn(EvaluationContext) -> ResolutionDetails(dynamic.Dynamic),
    ),
  )
}

pub type Variants =
  Dict(String, dynamic.Dynamic)

pub fn new_variants(variants: List(#(String, a))) -> Variants {
  variants
  |> list.map(fn(key_and_value) {
    #(key_and_value.0, dynamic.from(key_and_value.1))
  })
  |> dict.from_list
}

pub fn provider(from: Dict(String, Flag)) {
  FeatureProvider(
    get_metadata: get_metadata,
    initialize: fn(context) {
      // print context on initialize
      io.debug(context)
      Ok(Nil)
    },
    shutdown: fn() { Nil },
    resolve_bool_evaluation: fn(flag, default_value, evaluation_context) {
      resolve_evaluation(
        flag,
        from,
        default_value,
        evaluation_context,
        decode.bool,
      )
    },
    resolve_string_evaluation: fn(flag, default_value, evaluation_context) {
      resolve_evaluation(
        flag,
        from,
        default_value,
        evaluation_context,
        decode.string,
      )
    },
    resolve_int_evaluation: fn(flag, default_value, evaluation_context) {
      resolve_evaluation(
        flag,
        from,
        default_value,
        evaluation_context,
        decode.int,
      )
    },
    resolve_float_evaluation: fn(flag, default_value, evaluation_context) {
      resolve_evaluation(
        flag,
        from,
        default_value,
        evaluation_context,
        decode.float,
      )
    },
    resolve_dynamic_evaluation: fn(flag, default_value, _evaluation_context) {
      resolve_dynamic_evaluation(flag, from, default_value)
    },
  )
}

fn get_metadata() {
  Metadata("In-Memory Provider")
}

fn resolve_evaluation(
  flag: String,
  flags: Dict(String, Flag),
  default_value: value,
  evaluation_context: EvaluationContext,
  decoder: decode.Decoder(value),
) -> ResolutionDetails(value) {
  inner_resolve(flag, flags, default_value, evaluation_context, decoder)
  |> result.unwrap(ResolutionError(
    default_value,
    evaluation.Error,
    error.General,
    "flag " <> flag <> " not found",
  ))
}

fn inner_resolve(
  flag: String,
  flags: Dict(String, Flag),
  default_value: value,
  evaluation_context: EvaluationContext,
  decoder: decode.Decoder(value),
) {
  use found_flag <- result.map(dict.get(flags, flag))
  case found_flag.context_evaluator {
    Some(context_evaluator) ->
      evaluate_context_evaluator(
        default_value,
        context_evaluator,
        evaluation_context,
        decoder,
      )
    None ->
      case dict.get(found_flag.variants, found_flag.default_variant) {
        Ok(val) ->
          case
            dynamic.from(val)
            |> decode.run(decoder)
          {
            Ok(resolved_val) -> ResolutionSuccess(resolved_val, Static)
            Error(_) ->
              ResolutionError(
                default_value,
                evaluation.Error,
                error.TypeMismatch,
                "type mismatch",
              )
          }
        Error(_) ->
          ResolutionError(
            default_value,
            evaluation.Error,
            error.General,
            "default variant "
              <> found_flag.default_variant
              <> " not found in variants",
          )
      }
  }
}

fn evaluate_context_evaluator(
  default_value: value,
  context_evaluator evaluator: fn(EvaluationContext) ->
    ResolutionDetails(dynamic.Dynamic),
  evaluation_context context: EvaluationContext,
  decoder decoder: decode.Decoder(value),
) -> ResolutionDetails(value) {
  let resolution_details = evaluator(context)

  resolution_details.value
  |> decode.run(decoder)
  |> result.map(fn(val) {
    case resolution_details {
      ResolutionSuccess(_, reason) -> ResolutionSuccess(val, reason)
      ResolutionError(_, reason, code, message) ->
        ResolutionError(val, reason, code, message)
    }
  })
  |> result.unwrap(ResolutionError(
    default_value,
    evaluation.Error,
    error.TypeMismatch,
    "type mismatch",
  ))
}

fn resolve_dynamic_evaluation(
  flag: String,
  flags: Dict(String, value),
  default_value: dynamic.Dynamic,
) -> ResolutionDetails(dynamic.Dynamic) {
  case dict.get(flags, flag) {
    Ok(val) -> ResolutionSuccess(dynamic.from(val), Static)
    Error(_) ->
      ResolutionError(
        default_value,
        evaluation.Error,
        error.FlagNotFound,
        "not found",
      )
  }
}
