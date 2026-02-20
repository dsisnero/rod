require "../performancetimeline/performancetimeline"
require "json"
require "time"

module Cdp::PerformanceTimeline
  struct TimelineEventAddedEvent
    include JSON::Serializable
    include Cdp::Event

    property event : TimelineEvent

    def initialize(@event : TimelineEvent)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "PerformanceTimeline.timelineEventAdded"
    end
  end
end
