require "../cast/cast"
require "json"
require "time"

module Cdp::Cast
  struct Sink
    include JSON::Serializable

    property name : String
    property id : String
    @[JSON::Field(emit_null: false)]
    property session : String?
  end
end
