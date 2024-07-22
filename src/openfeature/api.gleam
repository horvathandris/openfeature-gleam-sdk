import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/otp/actor
import gleam/result
import openfeature/client.{type Client, Client, ClientMetadata}
import openfeature/domain.{type Domain}
import openfeature/evaluation_context.{type EvaluationContext, EvaluationContext}
import openfeature/provider.{type FeatureProvider, type Metadata}
import openfeature/providers/no_op
import worm

type APIMessage {
  Shutdown
  SetProvider(
    reply_with: Subject(Result(Nil, Nil)),
    domain: Domain,
    provider: FeatureProvider,
  )
  GetProvider(reply_with: Subject(FeatureProvider), domain: Domain)
  SetContext(evaluation_context: EvaluationContext)
}

type API {
  API(
    provider_registry: Dict(Domain, FeatureProvider),
    global_context: EvaluationContext,
  )
}

fn get_api_subject() -> Subject(APIMessage) {
  worm.persist(init_api)
}

fn init_api() {
  let initial_state = API(dict.new(), evaluation_context.empty())
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
      }
    })
  subject
}

pub fn set_provider(provider: FeatureProvider) -> Result(Nil, Nil) {
  actor.call(get_api_subject(), SetProvider(_, domain.Global, provider), 1000)
}

fn set_provider_internal(
  state: API,
  reply_with: Subject(Result(Nil, Nil)),
  domain: Domain,
  provider: FeatureProvider,
) -> API {
  let provider_registry =
    state.provider_registry
    |> dict.insert(domain, provider)

  case domain {
    domain.Global -> provider.initialize(state.global_context)
    domain.Scoped(_) -> Ok(Nil)
  }
  |> actor.send(reply_with, _)

  API(provider_registry, state.global_context)
}

fn get_provider() -> FeatureProvider {
  actor.call(get_api_subject(), GetProvider(_, domain.Global), 1000)
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
    1000,
  )
  |> result.unwrap(Nil)
}

fn get_domain_provider(domain: String) -> FeatureProvider {
  actor.call(get_api_subject(), GetProvider(_, domain.Scoped(domain)), 1000)
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
  API(state.provider_registry, evaluation_context)
}

pub fn shutdown() {
  actor.send(get_api_subject(), Shutdown)
}

fn shutdown_internal(state: API) -> Nil {
  state.provider_registry
  |> dict.values
  |> list.each(fn(provider) { provider.shutdown() })
}
