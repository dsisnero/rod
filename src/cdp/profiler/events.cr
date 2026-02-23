require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../debugger/debugger"

module Cdp::Profiler
  struct ConsoleProfileFinishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property location : Cdp::Debugger::Location
    @[JSON::Field(emit_null: false)]
    property profile : Profile
    @[JSON::Field(emit_null: false)]
    property title : String?

    def initialize(@id : String, @location : Cdp::Debugger::Location, @profile : Profile, @title : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Profiler.consoleProfileFinished"
    end
  end

  struct ConsoleProfileStartedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property location : Cdp::Debugger::Location
    @[JSON::Field(emit_null: false)]
    property title : String?

    def initialize(@id : String, @location : Cdp::Debugger::Location, @title : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
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
    property result : Array(ScriptCoverage)

    def initialize(@timestamp : Float64, @occasion : String, @result : Array(ScriptCoverage))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Profiler.preciseCoverageDeltaUpdate"
    end
  end
end
