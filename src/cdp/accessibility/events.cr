require "../accessibility/accessibility"
require "json"
require "time"
require "../dom/dom"
require "../runtime/runtime"
require "../page/page"

module Cdp::Accessibility
  @[Experimental]
  struct LoadCompleteEvent
    include JSON::Serializable
    include Cdp::Event

    property root : Node

    def initialize(@root : Node)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Accessibility.loadComplete"
    end
  end

  @[Experimental]
  struct NodesUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    property nodes : Array(Node)

    def initialize(@nodes : Array(Node))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Accessibility.nodesUpdated"
    end
  end
end
