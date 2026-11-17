require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../network/network"

module Cdp::Emulation
  @[Experimental]
  struct VirtualTimeBudgetExpiredEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Emulation.virtualTimeBudgetExpired"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Emulation.virtualTimeBudgetExpired"
    end
  end

  @[Experimental]
  struct ScreenOrientationLockChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "locked", emit_null: false)]
    property? locked : Bool
    @[JSON::Field(key: "orientation", emit_null: false)]
    property orientation : ScreenOrientation?

    def initialize(@locked : Bool, @orientation : ScreenOrientation?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Emulation.screenOrientationLockChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Emulation.screenOrientationLockChanged"
    end
  end
end
