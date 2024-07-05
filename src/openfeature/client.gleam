import openfeature/provider.{type FeatureProvider}

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
