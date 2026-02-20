require "json"
require "../cdp"
require "../runtime/runtime"
require "./types"

# Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
# breakpoints, stepping through execution, exploring stack traces, etc.
module Cdp::Debugger
  # Commands
  struct ContinueToLocation
    include JSON::Serializable
    include Cdp::Request

    property location : Location
    @[JSON::Field(emit_null: false)]
    property target_call_frames : ContinueToLocationTargetCallFrames?

    def initialize(@location : Location, @target_call_frames : ContinueToLocationTargetCallFrames?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.continueToLocation"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property max_scripts_cache_size : Float64?

    def initialize(@max_scripts_cache_size : Float64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.enable"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : EnableResult
      res = EnableResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct EnableResult
    include JSON::Serializable

    property debugger_id : Cdp::Runtime::UniqueDebuggerId

    def initialize(@debugger_id : Cdp::Runtime::UniqueDebuggerId)
    end
  end

  struct EvaluateOnCallFrame
    include JSON::Serializable
    include Cdp::Request

    property call_frame_id : CallFrameId
    property expression : String
    @[JSON::Field(emit_null: false)]
    property object_group : String?
    @[JSON::Field(emit_null: false)]
    property include_command_line_api : Bool?
    @[JSON::Field(emit_null: false)]
    property silent : Bool?
    @[JSON::Field(emit_null: false)]
    property return_by_value : Bool?
    @[JSON::Field(emit_null: false)]
    property generate_preview : Bool?
    @[JSON::Field(emit_null: false)]
    property throw_on_side_effect : Bool?
    @[JSON::Field(emit_null: false)]
    property timeout : Cdp::Runtime::TimeDelta?

    def initialize(@call_frame_id : CallFrameId, @expression : String, @object_group : String?, @include_command_line_api : Bool?, @silent : Bool?, @return_by_value : Bool?, @generate_preview : Bool?, @throw_on_side_effect : Bool?, @timeout : Cdp::Runtime::TimeDelta?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.evaluateOnCallFrame"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : EvaluateOnCallFrameResult
      res = EvaluateOnCallFrameResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct EvaluateOnCallFrameResult
    include JSON::Serializable

    property result : Cdp::Runtime::RemoteObject
    @[JSON::Field(emit_null: false)]
    property exception_details : Cdp::Runtime::ExceptionDetails?

    def initialize(@result : Cdp::Runtime::RemoteObject, @exception_details : Cdp::Runtime::ExceptionDetails?)
    end
  end

  struct GetPossibleBreakpoints
    include JSON::Serializable
    include Cdp::Request

    property start : Location
    @[JSON::Field(emit_null: false)]
    property end : Location?
    @[JSON::Field(emit_null: false)]
    property restrict_to_function : Bool?

    def initialize(@start : Location, @end : Location?, @restrict_to_function : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.getPossibleBreakpoints"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPossibleBreakpointsResult
      res = GetPossibleBreakpointsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetPossibleBreakpointsResult
    include JSON::Serializable

    property locations : Array(BreakLocation)

    def initialize(@locations : Array(BreakLocation))
    end
  end

  struct GetScriptSource
    include JSON::Serializable
    include Cdp::Request

    property script_id : Cdp::Runtime::ScriptId

    def initialize(@script_id : Cdp::Runtime::ScriptId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.getScriptSource"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetScriptSourceResult
      res = GetScriptSourceResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetScriptSourceResult
    include JSON::Serializable

    property script_source : String
    @[JSON::Field(emit_null: false)]
    property bytecode : String?

    def initialize(@script_source : String, @bytecode : String?)
    end
  end

  @[Experimental]
  struct DisassembleWasmModule
    include JSON::Serializable
    include Cdp::Request

    property script_id : Cdp::Runtime::ScriptId

    def initialize(@script_id : Cdp::Runtime::ScriptId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.disassembleWasmModule"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : DisassembleWasmModuleResult
      res = DisassembleWasmModuleResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct DisassembleWasmModuleResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property stream_id : String?
    property total_number_of_lines : Int64
    property function_body_offsets : Array(Int64)
    property chunk : WasmDisassemblyChunk

    def initialize(@stream_id : String?, @total_number_of_lines : Int64, @function_body_offsets : Array(Int64), @chunk : WasmDisassemblyChunk)
    end
  end

  @[Experimental]
  struct NextWasmDisassemblyChunk
    include JSON::Serializable
    include Cdp::Request

    property stream_id : String

    def initialize(@stream_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.nextWasmDisassemblyChunk"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : NextWasmDisassemblyChunkResult
      res = NextWasmDisassemblyChunkResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct NextWasmDisassemblyChunkResult
    include JSON::Serializable

    property chunk : WasmDisassemblyChunk

    def initialize(@chunk : WasmDisassemblyChunk)
    end
  end

  @[Experimental]
  struct GetStackTrace
    include JSON::Serializable
    include Cdp::Request

    property stack_trace_id : Cdp::Runtime::StackTraceId

    def initialize(@stack_trace_id : Cdp::Runtime::StackTraceId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.getStackTrace"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetStackTraceResult
      res = GetStackTraceResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetStackTraceResult
    include JSON::Serializable

    property stack_trace : Cdp::Runtime::StackTrace

    def initialize(@stack_trace : Cdp::Runtime::StackTrace)
    end
  end

  struct Pause
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.pause"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveBreakpoint
    include JSON::Serializable
    include Cdp::Request

    property breakpoint_id : BreakpointId

    def initialize(@breakpoint_id : BreakpointId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.removeBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RestartFrame
    include JSON::Serializable
    include Cdp::Request

    property call_frame_id : CallFrameId
    @[JSON::Field(emit_null: false)]
    property mode : RestartFrameMode?

    def initialize(@call_frame_id : CallFrameId, @mode : RestartFrameMode?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.restartFrame"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Resume
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property terminate_on_resume : Bool?

    def initialize(@terminate_on_resume : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.resume"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SearchInContent
    include JSON::Serializable
    include Cdp::Request

    property script_id : Cdp::Runtime::ScriptId
    property query : String
    @[JSON::Field(emit_null: false)]
    property case_sensitive : Bool?
    @[JSON::Field(emit_null: false)]
    property is_regex : Bool?

    def initialize(@script_id : Cdp::Runtime::ScriptId, @query : String, @case_sensitive : Bool?, @is_regex : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.searchInContent"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SearchInContentResult
      res = SearchInContentResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SearchInContentResult
    include JSON::Serializable

    property result : Array(SearchMatch)

    def initialize(@result : Array(SearchMatch))
    end
  end

  struct SetAsyncCallStackDepth
    include JSON::Serializable
    include Cdp::Request

    property max_depth : Int64

    def initialize(@max_depth : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setAsyncCallStackDepth"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetBlackboxExecutionContexts
    include JSON::Serializable
    include Cdp::Request

    property unique_ids : Array(String)

    def initialize(@unique_ids : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBlackboxExecutionContexts"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetBlackboxPatterns
    include JSON::Serializable
    include Cdp::Request

    property patterns : Array(String)
    @[JSON::Field(emit_null: false)]
    property skip_anonymous : Bool?

    def initialize(@patterns : Array(String), @skip_anonymous : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBlackboxPatterns"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetBlackboxedRanges
    include JSON::Serializable
    include Cdp::Request

    property script_id : Cdp::Runtime::ScriptId
    property positions : Array(ScriptPosition)

    def initialize(@script_id : Cdp::Runtime::ScriptId, @positions : Array(ScriptPosition))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBlackboxedRanges"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetBreakpoint
    include JSON::Serializable
    include Cdp::Request

    property location : Location
    @[JSON::Field(emit_null: false)]
    property condition : String?

    def initialize(@location : Location, @condition : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBreakpoint"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetBreakpointResult
      res = SetBreakpointResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetBreakpointResult
    include JSON::Serializable

    property breakpoint_id : BreakpointId
    property actual_location : Location

    def initialize(@breakpoint_id : BreakpointId, @actual_location : Location)
    end
  end

  struct SetInstrumentationBreakpoint
    include JSON::Serializable
    include Cdp::Request

    property instrumentation : SetInstrumentationBreakpointInstrumentation

    def initialize(@instrumentation : SetInstrumentationBreakpointInstrumentation)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setInstrumentationBreakpoint"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetInstrumentationBreakpointResult
      res = SetInstrumentationBreakpointResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetInstrumentationBreakpointResult
    include JSON::Serializable

    property breakpoint_id : BreakpointId

    def initialize(@breakpoint_id : BreakpointId)
    end
  end

  struct SetBreakpointByUrl
    include JSON::Serializable
    include Cdp::Request

    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property url_regex : String?
    @[JSON::Field(emit_null: false)]
    property script_hash : String?
    @[JSON::Field(emit_null: false)]
    property column_number : Int64?
    @[JSON::Field(emit_null: false)]
    property condition : String?

    def initialize(@line_number : Int64, @url : String?, @url_regex : String?, @script_hash : String?, @column_number : Int64?, @condition : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBreakpointByUrl"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetBreakpointByUrlResult
      res = SetBreakpointByUrlResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetBreakpointByUrlResult
    include JSON::Serializable

    property breakpoint_id : BreakpointId
    property locations : Array(Location)

    def initialize(@breakpoint_id : BreakpointId, @locations : Array(Location))
    end
  end

  @[Experimental]
  struct SetBreakpointOnFunctionCall
    include JSON::Serializable
    include Cdp::Request

    property object_id : Cdp::Runtime::RemoteObjectId
    @[JSON::Field(emit_null: false)]
    property condition : String?

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId, @condition : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBreakpointOnFunctionCall"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetBreakpointOnFunctionCallResult
      res = SetBreakpointOnFunctionCallResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetBreakpointOnFunctionCallResult
    include JSON::Serializable

    property breakpoint_id : BreakpointId

    def initialize(@breakpoint_id : BreakpointId)
    end
  end

  struct SetBreakpointsActive
    include JSON::Serializable
    include Cdp::Request

    property active : Bool

    def initialize(@active : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setBreakpointsActive"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetPauseOnExceptions
    include JSON::Serializable
    include Cdp::Request

    property state : ExceptionsState

    def initialize(@state : ExceptionsState)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setPauseOnExceptions"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetReturnValue
    include JSON::Serializable
    include Cdp::Request

    property new_value : Cdp::Runtime::CallArgument

    def initialize(@new_value : Cdp::Runtime::CallArgument)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setReturnValue"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetScriptSource
    include JSON::Serializable
    include Cdp::Request

    property script_id : Cdp::Runtime::ScriptId
    property script_source : String
    @[JSON::Field(emit_null: false)]
    property dry_run : Bool?
    @[JSON::Field(emit_null: false)]
    property allow_top_frame_editing : Bool?

    def initialize(@script_id : Cdp::Runtime::ScriptId, @script_source : String, @dry_run : Bool?, @allow_top_frame_editing : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setScriptSource"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetScriptSourceResult
      res = SetScriptSourceResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetScriptSourceResult
    include JSON::Serializable

    property status : SetScriptSourceStatus
    @[JSON::Field(emit_null: false)]
    property exception_details : Cdp::Runtime::ExceptionDetails?

    def initialize(@status : SetScriptSourceStatus, @exception_details : Cdp::Runtime::ExceptionDetails?)
    end
  end

  struct SetSkipAllPauses
    include JSON::Serializable
    include Cdp::Request

    property skip : Bool

    def initialize(@skip : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setSkipAllPauses"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetVariableValue
    include JSON::Serializable
    include Cdp::Request

    property scope_number : Int64
    property variable_name : String
    property new_value : Cdp::Runtime::CallArgument
    property call_frame_id : CallFrameId

    def initialize(@scope_number : Int64, @variable_name : String, @new_value : Cdp::Runtime::CallArgument, @call_frame_id : CallFrameId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.setVariableValue"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StepInto
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property break_on_async_call : Bool?
    @[JSON::Field(emit_null: false)]
    property skip_list : Array(LocationRange)?

    def initialize(@break_on_async_call : Bool?, @skip_list : Array(LocationRange)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.stepInto"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StepOut
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.stepOut"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StepOver
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property skip_list : Array(LocationRange)?

    def initialize(@skip_list : Array(LocationRange)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.stepOver"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
