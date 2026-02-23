require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Accessibility
  @[Experimental]
  struct LoadCompleteEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property root : Cdp::NodeType

    def initialize(@root : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Accessibility.loadComplete"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Accessibility.loadComplete"
    end
  end

  @[Experimental]
  struct NodesUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@nodes : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Accessibility.nodesUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Accessibility.nodesUpdated"
    end
  end
end
