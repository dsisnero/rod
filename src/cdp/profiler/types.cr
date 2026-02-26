require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../debugger/debugger"

module Cdp::Profiler
  struct ProfileNode
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : Int64
    @[JSON::Field(key: "callFrame", emit_null: false)]
    property call_frame : Cdp::Runtime::CallFrame
    @[JSON::Field(key: "hitCount", emit_null: false)]
    property hit_count : Int64?
    @[JSON::Field(key: "children", emit_null: false)]
    property children : Array(Int64)?
    @[JSON::Field(key: "deoptReason", emit_null: false)]
    property deopt_reason : String?
    @[JSON::Field(key: "positionTicks", emit_null: false)]
    property position_ticks : Array(PositionTickInfo)?
  end

  struct Profile
    include JSON::Serializable
    @[JSON::Field(key: "nodes", emit_null: false)]
    property nodes : Array(ProfileNode)
    @[JSON::Field(key: "startTime", emit_null: false)]
    property start_time : Float64
    @[JSON::Field(key: "endTime", emit_null: false)]
    property end_time : Float64
    @[JSON::Field(key: "samples", emit_null: false)]
    property samples : Array(Int64)?
    @[JSON::Field(key: "timeDeltas", emit_null: false)]
    property time_deltas : Array(Int64)?
  end

  struct PositionTickInfo
    include JSON::Serializable
    @[JSON::Field(key: "line", emit_null: false)]
    property line : Int64
    @[JSON::Field(key: "ticks", emit_null: false)]
    property ticks : Int64
  end

  struct CoverageRange
    include JSON::Serializable
    @[JSON::Field(key: "startOffset", emit_null: false)]
    property start_offset : Int64
    @[JSON::Field(key: "endOffset", emit_null: false)]
    property end_offset : Int64
    @[JSON::Field(key: "count", emit_null: false)]
    property count : Int64
  end

  struct FunctionCoverage
    include JSON::Serializable
    @[JSON::Field(key: "functionName", emit_null: false)]
    property function_name : String
    @[JSON::Field(key: "ranges", emit_null: false)]
    property ranges : Array(CoverageRange)
    @[JSON::Field(key: "isBlockCoverage", emit_null: false)]
    property? is_block_coverage : Bool
  end

  struct ScriptCoverage
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "functions", emit_null: false)]
    property functions : Array(FunctionCoverage)
  end
end
