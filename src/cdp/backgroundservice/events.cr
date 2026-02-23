require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::BackgroundService
  struct RecordingStateChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property? is_recording : Bool
    @[JSON::Field(emit_null: false)]
    property service : Cdp::NodeType

    def initialize(@is_recording : Bool, @service : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BackgroundService.recordingStateChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "BackgroundService.recordingStateChanged"
    end
  end

  struct BackgroundServiceEventReceivedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property background_service_event : Cdp::NodeType

    def initialize(@background_service_event : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BackgroundService.backgroundServiceEventReceived"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "BackgroundService.backgroundServiceEventReceived"
    end
  end
end
