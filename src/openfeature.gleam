import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor
import gleam/result
import openfeature/client.{type Client, Client, ClientMetadata}
import openfeature/domain.{type Domain}
import openfeature/evaluation_context.{type EvaluationContext, EvaluationContext}
import openfeature/events.{type EventCallback}
import openfeature/provider.{type FeatureProvider, type Metadata}
import openfeature/providers/no_op
import worm

const timeout = 10_000

type APIMessage {
  Shutdown
  SetProvider(
    reply_with: Subject(Result(Nil, Nil)),
    domain: Domain,
    provider: FeatureProvider,
  )
  GetProvider(reply_with: Subject(FeatureProvider), domain: Domain)
  SetContext(evaluation_context: EvaluationContext)
  AddHandler(domain: Domain, callback: EventCallback)
  RemoveHandler(domain: Domain, callback: EventCallback)
}

type API {
  API(
    provider_registry: Dict(Domain, FeatureProvider),
    global_context: EvaluationContext,
    event_callbacks: Dict(Domain, List(EventCallback)),
  )
}

fn get_api_subject() -> Subject(APIMessage) {
  worm.persist(init_api)
}

fn init_api() {
  let initial_state = API(dict.new(), evaluation_context.empty(), dict.new())
  let assert Ok(subject) =
    actor.start(initial_state, fn(message: APIMessage, state: API) {
      case message {
        Shutdown -> {
          shutdown_internal(state)
          actor.Stop(process.Normal)
        }

        SetProvider(reply_with, domain, provider) ->
          set_provider_internal(state, reply_with, domain, provider)
          |> actor.continue

        GetProvider(reply_with, domain) ->
          get_provider_internal(state, reply_with, domain)
          |> actor.continue

        SetContext(evaluation_context) ->
          set_context_internal(state, evaluation_context)
          |> actor.continue

        AddHandler(domain, callback) ->
          add_handler_internal(state, domain, callback)
          |> actor.continue

        RemoveHandler(domain, callback) ->
          remove_handler_internal(state, domain, callback)
          |> actor.continue
      }
    })
  subject
}

pub fn set_provider(provider: FeatureProvider) -> Result(Nil, Nil) {
  process.try_call(
    get_api_subject(),
    SetProvider(_, domain.Global, provider),
    timeout,
  )
  |> result.nil_error
  |> result.flatten
}

fn set_provider_internal(
  state: API,
  reply_with: Subject(Result(Nil, Nil)),
  domain: Domain,
  provider: FeatureProvider,
) -> API {
  let init_result = provider.initialize(state.global_context)
  actor.send(reply_with, init_result)

  let provider_registry =
    state.provider_registry
    |> dict.insert(domain, provider)

  API(provider_registry, state.global_context, state.event_callbacks)
}

fn get_provider() -> FeatureProvider {
  actor.call(get_api_subject(), GetProvider(_, domain.Global), timeout)
}

fn get_provider_internal(
  state: API,
  reply_with: Subject(FeatureProvider),
  domain: Domain,
) -> API {
  state.provider_registry
  |> dict.get(domain)
  |> result.unwrap(no_op.provider())
  |> actor.send(reply_with, _)

  state
}

pub fn get_provider_metadata() -> Metadata {
  get_provider().get_metadata()
}

pub fn set_domain_provider(domain: String, provider: FeatureProvider) -> Nil {
  actor.call(
    get_api_subject(),
    SetProvider(_, domain.Scoped(domain), provider),
    timeout,
  )
  |> result.unwrap(Nil)
}

fn get_domain_provider(domain: String) -> FeatureProvider {
  actor.call(get_api_subject(), GetProvider(_, domain.Scoped(domain)), timeout)
}

pub fn get_domain_provider_metadata(domain: String) -> Metadata {
  get_domain_provider(domain).get_metadata()
}

pub fn get_client() {
  Client(
    provider: get_provider(),
    metadata: ClientMetadata(domain.Global),
    evaluation_context: evaluation_context.empty(),
  )
}

/// Initialise and retrieve a new client for the provided domain.
/// If the domain has a corresponding provider registered, the client will use that provider.
/// Otherwise, the global default provider is used.
pub fn get_domain_client(domain: String) {
  Client(
    provider: get_domain_provider(domain),
    metadata: ClientMetadata(domain.Scoped(domain)),
    evaluation_context: evaluation_context.empty(),
  )
}

fn set_context_internal(
  state: API,
  evaluation_context: EvaluationContext,
) -> API {
  API(state.provider_registry, evaluation_context, state.event_callbacks)
}

pub fn shutdown() {
  actor.send(get_api_subject(), Shutdown)
}

fn shutdown_internal(state: API) -> Nil {
  state.provider_registry
  |> dict.values
  |> list.each(fn(provider) { provider.shutdown() })
}

fn add_handler_internal(
  state: API,
  domain: Domain,
  callback: EventCallback,
) -> API {
  let domain_callbacks =
    state.event_callbacks
    |> dict.get(domain)
    |> result.unwrap([])
    |> list.prepend(callback)

  state.event_callbacks
  |> dict.insert(domain, domain_callbacks)
  |> API(state.provider_registry, state.global_context, _)
}

fn remove_handler_internal(state: API, domain: Domain, callback: EventCallback) {
  let domain_callbacks =
    state.event_callbacks
    |> dict.get(domain)
    |> result.unwrap([])
    |> list.drop_while(fn(x) { x == callback })

  state.event_callbacks
  |> dict.insert(domain, domain_callbacks)
  |> API(state.provider_registry, state.global_context, _)
}
