require "../emulation/emulation"
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
  end
end
