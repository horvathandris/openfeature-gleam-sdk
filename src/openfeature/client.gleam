import gleam/dynamic.{type Dynamic}
import openfeature/domain.{type Domain}
import openfeature/evaluation.{type ResolutionDetails}
import openfeature/evaluation_context.{type EvaluationContext}
import openfeature/provider.{type FeatureProvider}

pub type Client {
  Client(
    provider: FeatureProvider,
    metadata: ClientMetadata,
    evaluation_context: EvaluationContext,
  )
}

pub type ClientMetadata {
  ClientMetadata(domain: Domain)
}

@deprecated("This exists for historical compatibility, use `get_domain` instead.")
pub fn get_name(metadata: ClientMetadata) -> Domain {
  get_domain(metadata)
}

pub fn get_domain(metadata: ClientMetadata) -> Domain {
  metadata.domain
}

pub fn get_bool_value(
  client: Client,
  flag: String,
  default_value: Bool,
  evaluation_context: EvaluationContext,
) -> Bool {
  get_bool_details(client, flag, default_value, evaluation_context)
  |> get_value_from_details
}

pub fn get_bool_details(
  client: Client,
  flag: String,
  default_value: Bool,
  evaluation_context: EvaluationContext,
) -> ResolutionDetails(Bool) {
  client.provider.resolve_bool_evaluation(
    flag,
    default_value,
    evaluation_context,
  )
}

pub fn get_string_value(
  client: Client,
  flag: String,
  default_value: String,
  evaluation_context: EvaluationContext,
) -> String {
  get_string_details(client, flag, default_value, evaluation_context)
  |> get_value_from_details
}

pub fn get_string_details(
  client: Client,
  flag: String,
  default_value: String,
  evaluation_context: EvaluationContext,
) -> ResolutionDetails(String) {
  client.provider.resolve_string_evaluation(
    flag,
    default_value,
    evaluation_context,
  )
}

pub fn get_int_value(
  client: Client,
  flag: String,
  default_value: Int,
  evaluation_context: EvaluationContext,
) -> Int {
  get_int_details(client, flag, default_value, evaluation_context)
  |> get_value_from_details
}

pub fn get_int_details(
  client: Client,
  flag: String,
  default_value: Int,
  evaluation_context: EvaluationContext,
) -> ResolutionDetails(Int) {
  client.provider.resolve_int_evaluation(
    flag,
    default_value,
    evaluation_context,
  )
}

pub fn get_float_value(
  client: Client,
  flag: String,
  default_value: Float,
  evaluation_context: EvaluationContext,
) -> Float {
  get_float_details(client, flag, default_value, evaluation_context)
  |> get_value_from_details
}

pub fn get_float_details(
  client: Client,
  flag: String,
  default_value: Float,
  evaluation_context: EvaluationContext,
) {
  client.provider.resolve_float_evaluation(
    flag,
    default_value,
    evaluation_context,
  )
}

pub fn get_dynamic_value(
  client: Client,
  flag: String,
  default_value: Dynamic,
  evaluation_context: EvaluationContext,
) -> Dynamic {
  get_dynamic_details(client, flag, default_value, evaluation_context)
  |> get_value_from_details
}

pub fn get_dynamic_details(
  client: Client,
  flag: String,
  default_value: Dynamic,
  evaluation_context: EvaluationContext,
) {
  client.provider.resolve_dynamic_evaluation(
    flag,
    default_value,
    evaluation_context,
  )
}

fn get_value_from_details(details: ResolutionDetails(a)) -> a {
  details.value
}

pub fn set_context(
  client: Client,
  evaluation_context: EvaluationContext,
) -> Client {
  let Client(provider: provider, metadata: metadata, ..) = client
  Client(provider, metadata, evaluation_context)
}
