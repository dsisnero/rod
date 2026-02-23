require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::DeviceAccess
  struct DeviceRequestPromptedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property devices : Array(Cdp::NodeType)

    def initialize(@id : Cdp::NodeType, @devices : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DeviceAccess.deviceRequestPrompted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DeviceAccess.deviceRequestPrompted"
    end
  end
end
