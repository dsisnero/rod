require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../debugger/debugger"

module Cdp::Profiler
  struct ConsoleProfileFinishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "location", emit_null: false)]
    property location : Cdp::Debugger::Location
    @[JSON::Field(key: "profile", emit_null: false)]
    property profile : Profile
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String?

    def initialize(@id : String, @location : Cdp::Debugger::Location, @profile : Profile, @title : String?)
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
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "location", emit_null: false)]
    property location : Cdp::Debugger::Location
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String?

    def initialize(@id : String, @location : Cdp::Debugger::Location, @title : String?)
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
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : Float64
    @[JSON::Field(key: "occasion", emit_null: false)]
    property occasion : String
    @[JSON::Field(key: "result", emit_null: false)]
    property result : Array(ScriptCoverage)

    def initialize(@timestamp : Float64, @occasion : String, @result : Array(ScriptCoverage))
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
