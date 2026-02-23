require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Input
  @[Experimental]
  struct DragInterceptedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property data : Cdp::NodeType

    def initialize(@data : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Input.dragIntercepted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Input.dragIntercepted"
    end
  end
end
