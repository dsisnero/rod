
require "../cdp"
require "json"
require "time"

require "../network/network"
require "../dom/dom"
require "../page/page"

module Cdp::PerformanceTimeline
  struct TimelineEventAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property event : TimelineEvent

    def initialize(@event : TimelineEvent)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "PerformanceTimeline.timelineEventAdded"
    end
  end

end
