require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::DeviceAccess
  alias RequestId = String

  alias DeviceId = String

  struct PromptDevice
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String
  end
end
