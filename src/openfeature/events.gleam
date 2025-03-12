import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}
import openfeature/error.{type ErrorCode}

pub type EventCallback =
  fn(EventDetails) -> Nil

pub type EventType {
  ProviderReady
  ProviderError
  ProviderConfigurationChanged
  ProviderStale
}

pub type ProviderEventDetails {
  ProviderEventDetails(
    flags_changed: Option(List(String)),
    message: Option(String),
    error_code: Option(ErrorCode),
    event_metadata: Dict(String, Dynamic),
  )
}

pub type EventDetails {
  EventDetails(provider_name: String, event_details: ProviderEventDetails)
}
