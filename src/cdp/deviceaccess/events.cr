require "../cdp"
require "json"
require "time"

module Cdp::DeviceAccess
  struct DeviceRequestPromptedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : RequestId
    @[JSON::Field(emit_null: false)]
    property devices : Array(PromptDevice)

    def initialize(@id : RequestId, @devices : Array(PromptDevice))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DeviceAccess.deviceRequestPrompted"
    end
  end
end
