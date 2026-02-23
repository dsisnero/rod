require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../debugger/debugger"

module Cdp::Profiler
  struct ProfileNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : Int64
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property nodes : Array(ProfileNode)
    @[JSON::Field(emit_null: false)]
    property start_time : Float64
    @[JSON::Field(emit_null: false)]
    property end_time : Float64
    @[JSON::Field(emit_null: false)]
    property samples : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property time_deltas : Array(Int64)?
  end

  struct PositionTickInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property line : Int64
    @[JSON::Field(emit_null: false)]
    property ticks : Int64
  end

  struct CoverageRange
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property start_offset : Int64
    @[JSON::Field(emit_null: false)]
    property end_offset : Int64
    @[JSON::Field(emit_null: false)]
    property count : Int64
  end

  struct FunctionCoverage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property function_name : String
    @[JSON::Field(emit_null: false)]
    property ranges : Array(CoverageRange)
    @[JSON::Field(emit_null: false)]
    property? is_block_coverage : Bool
  end

  struct ScriptCoverage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property functions : Array(FunctionCoverage)
  end
end
