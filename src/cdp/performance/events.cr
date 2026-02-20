require "../performance/performance"
require "json"
require "time"

module Cdp::Performance
  struct MetricsEvent
    include JSON::Serializable
    include Cdp::Event

    property metrics : Array(Metric)
    property title : String

    def initialize(@metrics : Array(Metric), @title : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Performance.metrics"
    end
  end
end
