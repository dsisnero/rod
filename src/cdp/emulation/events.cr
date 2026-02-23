require "../cdp"
require "json"
require "time"

require "../dom/dom"

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
end
