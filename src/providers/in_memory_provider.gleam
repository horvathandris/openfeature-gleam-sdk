import gleam/dict.{type Dict}
import provider.{FeatureProvider}
import gleam/dynamic
import evaluation.{
  ErrorneousResolution, FlagNotFound, Static, SuccessfulResolution, TypeMismatch,
}
import metadata.{Metadata}

pub fn in_memory_provider(from: Dict(String, value)) {
  FeatureProvider(
    get_metadata: fn() { Metadata("In-Memory Provider") },
    resolve_boolean_evaluation: fn(flag, _default_value, _evaluation_context) {
      case dict.get(from, flag) {
        Ok(val) ->
          case resolve_generic(val, dynamic.bool) {
            Ok(bool_val) -> SuccessfulResolution(bool_val, Static)
            Error(_) -> ErrorneousResolution(TypeMismatch, "not a bool")
          }
        Error(_) -> ErrorneousResolution(FlagNotFound, "not found")
      }
    },
  )
}

fn resolve_generic(
  generic: value,
  resolver: fn(dynamic.Dynamic) -> resolved_value,
) {
  dynamic.from(generic)
  |> resolver
}
