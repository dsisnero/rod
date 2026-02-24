require "../cdp"
require "json"
require "time"

module Cdp::Cast
  struct Sink
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property session : String?
  end
end
