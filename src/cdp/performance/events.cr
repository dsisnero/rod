require "../cdp"
require "json"
require "time"

module Cdp::Performance
  struct MetricsEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property metrics : Array(Metric)
    @[JSON::Field(emit_null: false)]
    property title : String

    def initialize(@metrics : Array(Metric), @title : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Performance.metrics"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Performance.metrics"
    end
  end
end
