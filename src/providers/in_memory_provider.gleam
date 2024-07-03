import evaluation.{
  type ResolutionDetails, FlagNotFound, ResolutionError, ResolutionSuccess,
  Static, TypeMismatch,
}
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/io
import metadata.{Metadata}
import provider.{FeatureProvider}

pub fn in_memory_provider(from: Dict(String, value)) {
  FeatureProvider(
    get_metadata: get_metadata,
    initialize: fn(context) {
      // print context on initialize
      io.debug(context)
      Nil
    },
    resolve_bool_evaluation: fn(flag, _default_value, _evaluation_context) {
      resolve_evaluation(flag, from, dynamic.bool)
    },
    resolve_string_evaluation: fn(flag, _default_value, _evaluation_context) {
      resolve_evaluation(flag, from, dynamic.string)
    },
    resolve_int_evaluation: fn(flag, _default_value, _evaluation_context) {
      resolve_evaluation(flag, from, dynamic.int)
    },
    resolve_float_evaluation: fn(flag, _default_value, _evaluation_context) {
      resolve_evaluation(flag, from, dynamic.float)
    },
    resolve_dynamic_evaluation: fn(flag, _default_value, _evaluation_context) {
      resolve_dynamic_evaluation(flag, from)
    },
  )
}

fn get_metadata() {
  Metadata("In-Memory Provider")
}

fn resolve_evaluation(
  flag: String,
  flags: Dict(String, value),
  decoder: dynamic.Decoder(resolved_value),
) -> ResolutionDetails(resolved_value) {
  case dict.get(flags, flag) {
    Ok(val) ->
      case
        dynamic.from(val)
        |> decoder
      {
        Ok(resolved_val) -> ResolutionSuccess(resolved_val, Static)
        Error(_) -> ResolutionError(TypeMismatch, "type mismatch")
      }
    Error(_) -> ResolutionError(FlagNotFound, "not found")
  }
}

fn resolve_dynamic_evaluation(
  flag: String,
  flags: Dict(String, value),
) -> ResolutionDetails(dynamic.Dynamic) {
  case dict.get(flags, flag) {
    Ok(val) -> ResolutionSuccess(dynamic.from(val), Static)
    Error(_) -> ResolutionError(FlagNotFound, "not found")
  }
}
