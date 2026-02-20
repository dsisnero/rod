require "../input/input"
require "json"
require "time"

module Cdp::Input
  @[Experimental]
  struct DragInterceptedEvent
    include JSON::Serializable
    include Cdp::Event

    property data : DragData

    def initialize(@data : DragData)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Input.dragIntercepted"
    end
  end
end
