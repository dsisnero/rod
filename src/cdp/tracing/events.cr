require "../cdp"
require "json"
require "time"

require "../io/io"

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
  end

  struct TracingCompleteEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property? data_loss_occurred : Bool
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::IO::StreamHandle?
    @[JSON::Field(emit_null: false)]
    property trace_format : StreamFormat?
    @[JSON::Field(emit_null: false)]
    property stream_compression : StreamCompression?

    def initialize(@data_loss_occurred : Bool, @stream : Cdp::IO::StreamHandle?, @trace_format : StreamFormat?, @stream_compression : StreamCompression?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Tracing.tracingComplete"
    end
  end
end
