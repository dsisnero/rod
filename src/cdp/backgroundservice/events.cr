require "../cdp"
require "json"
require "time"

require "../network/network"
require "../serviceworker/serviceworker"

module Cdp::BackgroundService
  struct RecordingStateChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "isRecording", emit_null: false)]
    property? is_recording : Bool
    @[JSON::Field(key: "service", emit_null: false)]
    property service : ServiceName

    def initialize(@is_recording : Bool, @service : ServiceName)
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
    @[JSON::Field(key: "backgroundServiceEvent", emit_null: false)]
    property background_service_event : BackgroundServiceEvent

    def initialize(@background_service_event : BackgroundServiceEvent)
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
