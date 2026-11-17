require "../cdp"
require "json"
require "base64"
require "time"

module Cdp::DeviceAccess
  alias RequestId = String

  alias DeviceId = String

  struct PromptDevice
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : DeviceId
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String

    def initialize(@id : DeviceId, @name : String)
    end
  end
end
