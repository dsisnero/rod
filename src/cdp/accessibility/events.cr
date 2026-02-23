require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../runtime/runtime"

module Cdp::Accessibility
  @[Experimental]
  struct LoadCompleteEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Node)

    def initialize(@nodes : Array(Node))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Accessibility.nodesUpdated"
    end
  end
end
