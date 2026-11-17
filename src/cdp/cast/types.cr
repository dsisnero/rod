require "../cdp"
require "json"
require "base64"
require "time"

module Cdp::Cast
  struct Sink
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "session", emit_null: false)]
    property session : String?

    def initialize(@name : String, @id : String, @session : String? = nil)
    end
  end
end
