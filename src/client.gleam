import provider.{type FeatureProvider}

pub const global_domain = ""

pub type Client {
  Client(provider: FeatureProvider, metadata: ClientMetadata)
}

pub type ClientMetadata {
  ClientMetadata(domain: String)
}

pub fn get_name(metadata: ClientMetadata) {
  metadata.domain
}

pub fn get_domain(metadata: ClientMetadata) {
  metadata.domain
}
