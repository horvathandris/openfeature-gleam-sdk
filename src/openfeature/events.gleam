import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}
import openfeature/error.{type ErrorCode}

pub type EventCallback =
  fn(EventDetails) -> Nil

type EventType {
  ProviderReady
  ProviderError
  ProviderConfigurationChanged
  ProviderStale
}

type ProviderEventDetails {
  ProviderEventDetails(
    flags_changed: Option(List(String)),
    message: Option(String),
    error_code: Option(ErrorCode),
    event_metadata: Dict(String, Dynamic),
  )
}

type EventDetails {
  EventDetails(provider_name: String, event_details: ProviderEventDetails)
}
