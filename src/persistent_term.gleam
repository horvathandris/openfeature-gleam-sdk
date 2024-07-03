@external(erlang, "persistent_term", "get")
pub fn get(key: String, default_value: a) -> a

@external(erlang, "persistent_term", "put")
pub fn put(key: String, value: a) -> Nil
