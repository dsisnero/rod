require "../profiler/profiler"
require "json"
require "time"
require "../debugger/debugger"

module Cdp::Profiler
  struct ProfileNode
    include JSON::Serializable

    property id : Int64
    property call_frame : Cdp::Runtime::CallFrame
    @[JSON::Field(emit_null: false)]
    property hit_count : Int64?
    @[JSON::Field(emit_null: false)]
    property children : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property deopt_reason : String?
    @[JSON::Field(emit_null: false)]
    property position_ticks : Array(PositionTickInfo)?
  end

  struct Profile
    include JSON::Serializable

    property nodes : Array(ProfileNode)
    property start_time : Float64
    property end_time : Float64
    @[JSON::Field(emit_null: false)]
    property samples : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property time_deltas : Array(Int64)?
  end

  struct PositionTickInfo
    include JSON::Serializable

    property line : Int64
    property ticks : Int64
  end

  struct CoverageRange
    include JSON::Serializable

    property start_offset : Int64
    property end_offset : Int64
    property count : Int64
  end

  struct FunctionCoverage
    include JSON::Serializable

    property function_name : String
    property ranges : Array(CoverageRange)
    property is_block_coverage : Bool
  end

  struct ScriptCoverage
    include JSON::Serializable

    property script_id : Cdp::Runtime::ScriptId
    property url : String
    property functions : Array(FunctionCoverage)
  end
end
