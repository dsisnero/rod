require "../backgroundservice/backgroundservice"
require "json"
require "time"

module Cdp::BackgroundService
  struct RecordingStateChangedEvent
    include JSON::Serializable
    include Cdp::Event

    property is_recording : Bool
    property service : ServiceName

    def initialize(@is_recording : Bool, @service : ServiceName)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BackgroundService.recordingStateChanged"
    end
  end

  struct BackgroundServiceEventReceivedEvent
    include JSON::Serializable
    include Cdp::Event

    property background_service_event : BackgroundServiceEvent

    def initialize(@background_service_event : BackgroundServiceEvent)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "BackgroundService.backgroundServiceEventReceived"
    end
  end
end
