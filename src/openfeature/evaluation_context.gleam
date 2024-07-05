import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option, None, Some}

pub type EvaluationContext {
  EvaluationContext(
    targeting_key: Option(String),
    attributes: Dict(String, Dynamic),
  )
}

pub fn empty() {
  EvaluationContext(None, dict.new())
}

pub fn get_attribute(
  evaluation_context: EvaluationContext,
  key: String,
) -> Result(Dynamic, Nil) {
  dict.get(evaluation_context.attributes, key)
}

pub fn get_all_attributes(
  evaluation_context: EvaluationContext,
) -> List(#(String, Dynamic)) {
  dict.to_list(evaluation_context.attributes)
}

pub fn merge(
  initial_context: EvaluationContext,
  overriding_context: EvaluationContext,
) -> EvaluationContext {
  let targeting_key = case overriding_context.targeting_key {
    None -> initial_context.targeting_key
    Some(_) -> overriding_context.targeting_key
  }
  let attributes =
    dict.combine(
      initial_context.attributes,
      overriding_context.attributes,
      fn(_initial, overriding) { overriding },
    )
  EvaluationContext(targeting_key, attributes)
}
