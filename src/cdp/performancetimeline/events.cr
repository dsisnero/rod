require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::PerformanceTimeline
  struct TimelineEventAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property event : Cdp::NodeType

    def initialize(@event : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "PerformanceTimeline.timelineEventAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "PerformanceTimeline.timelineEventAdded"
    end
  end
end
