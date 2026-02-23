require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Tracing
  @[Experimental]
  struct BufferUsageEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property percent_full : Float64?
    @[JSON::Field(emit_null: false)]
    property event_count : Float64?
    @[JSON::Field(emit_null: false)]
    property value : Float64?

    def initialize(@percent_full : Float64?, @event_count : Float64?, @value : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Tracing.bufferUsage"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Tracing.bufferUsage"
    end
  end

  @[Experimental]
  struct DataCollectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property value : Array(JSON::Any)

    def initialize(@value : Array(JSON::Any))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Tracing.dataCollected"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Tracing.dataCollected"
    end
  end

  struct TracingCompleteEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property? data_loss_occurred : Bool
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property trace_format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property stream_compression : Cdp::NodeType?

    def initialize(@data_loss_occurred : Bool, @stream : Cdp::NodeType?, @trace_format : Cdp::NodeType?, @stream_compression : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Tracing.tracingComplete"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Tracing.tracingComplete"
    end
  end
end
