require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Profiler
  struct ConsoleProfileFinishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property profile : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property title : String?

    def initialize(@id : String, @location : Cdp::NodeType, @profile : Cdp::NodeType, @title : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Profiler.consoleProfileFinished"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Profiler.consoleProfileFinished"
    end
  end

  struct ConsoleProfileStartedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property title : String?

    def initialize(@id : String, @location : Cdp::NodeType, @title : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Profiler.consoleProfileStarted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Profiler.consoleProfileStarted"
    end
  end

  @[Experimental]
  struct PreciseCoverageDeltaUpdateEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property timestamp : Float64
    @[JSON::Field(emit_null: false)]
    property occasion : String
    @[JSON::Field(emit_null: false)]
    property result : Array(Cdp::NodeType)

    def initialize(@timestamp : Float64, @occasion : String, @result : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Profiler.preciseCoverageDeltaUpdate"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Profiler.preciseCoverageDeltaUpdate"
    end
  end
end
