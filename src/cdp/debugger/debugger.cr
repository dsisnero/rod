require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Debugger domain exposes JavaScript debugging capabilities. It allows setting and removing
# breakpoints, stepping through execution, exploring stack traces, etc.
module Cdp::Debugger
  struct EnableResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property debugger_id : Cdp::NodeType

    def initialize(@debugger_id : Cdp::NodeType)
    end
  end

  struct EvaluateOnCallFrameResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property result : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property exception_details : Cdp::NodeType?

    def initialize(@result : Cdp::NodeType, @exception_details : Cdp::NodeType?)
    end
  end

  struct GetPossibleBreakpointsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property locations : Array(Cdp::NodeType)

    def initialize(@locations : Array(Cdp::NodeType))
    end
  end

  struct GetScriptSourceResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_source : String
    @[JSON::Field(emit_null: false)]
    property bytecode : String?

    def initialize(@script_source : String, @bytecode : String?)
    end
  end

  @[Experimental]
  struct DisassembleWasmModuleResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property stream_id : String?
    @[JSON::Field(emit_null: false)]
    property total_number_of_lines : Int64
    @[JSON::Field(emit_null: false)]
    property function_body_offsets : Array(Int64)
    @[JSON::Field(emit_null: false)]
    property chunk : Cdp::NodeType

    def initialize(@stream_id : String?, @total_number_of_lines : Int64, @function_body_offsets : Array(Int64), @chunk : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct NextWasmDisassemblyChunkResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property chunk : Cdp::NodeType

    def initialize(@chunk : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct GetStackTraceResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property stack_trace : Cdp::NodeType

    def initialize(@stack_trace : Cdp::NodeType)
    end
  end

  struct RestartFrameResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property call_frames : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property async_stack_trace : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property async_stack_trace_id : Cdp::NodeType?

    def initialize(@call_frames : Array(Cdp::NodeType), @async_stack_trace : Cdp::NodeType?, @async_stack_trace_id : Cdp::NodeType?)
    end
  end

  struct SearchInContentResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property result : Array(Cdp::NodeType)

    def initialize(@result : Array(Cdp::NodeType))
    end
  end

  struct SetBreakpointResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property actual_location : Cdp::NodeType

    def initialize(@breakpoint_id : Cdp::NodeType, @actual_location : Cdp::NodeType)
    end
  end

  struct SetInstrumentationBreakpointResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : Cdp::NodeType

    def initialize(@breakpoint_id : Cdp::NodeType)
    end
  end

  struct SetBreakpointByUrlResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property locations : Array(Cdp::NodeType)

    def initialize(@breakpoint_id : Cdp::NodeType, @locations : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct SetBreakpointOnFunctionCallResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : Cdp::NodeType

    def initialize(@breakpoint_id : Cdp::NodeType)
    end
  end

  struct SetScriptSourceResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property call_frames : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property async_stack_trace : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property async_stack_trace_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property exception_details : Cdp::NodeType?

    def initialize(@call_frames : Array(Cdp::NodeType)?, @async_stack_trace : Cdp::NodeType?, @async_stack_trace_id : Cdp::NodeType?, @status : Cdp::NodeType, @exception_details : Cdp::NodeType?)
    end
  end

  # Commands
  struct ContinueToLocation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property target_call_frames : Cdp::NodeType?

    def initialize(@location : Cdp::NodeType, @target_call_frames : Cdp::NodeType?)
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

  struct EvaluateOnCallFrame
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property call_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property expression : String
    @[JSON::Field(emit_null: false)]
    property object_group : String?
    @[JSON::Field(emit_null: false)]
    property? include_command_line_api : Bool?
    @[JSON::Field(emit_null: false)]
    property? silent : Bool?
    @[JSON::Field(emit_null: false)]
    property? return_by_value : Bool?
    @[JSON::Field(emit_null: false)]
    property? generate_preview : Bool?
    @[JSON::Field(emit_null: false)]
    property? throw_on_side_effect : Bool?
    @[JSON::Field(emit_null: false)]
    property timeout : Cdp::NodeType?

    def initialize(@call_frame_id : Cdp::NodeType, @expression : String, @object_group : String?, @include_command_line_api : Bool?, @silent : Bool?, @return_by_value : Bool?, @generate_preview : Bool?, @throw_on_side_effect : Bool?, @timeout : Cdp::NodeType?)
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

  struct GetPossibleBreakpoints
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property start : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property end : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? restrict_to_function : Bool?

    def initialize(@start : Cdp::NodeType, @end : Cdp::NodeType?, @restrict_to_function : Bool?)
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

  struct GetScriptSource
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType

    def initialize(@script_id : Cdp::NodeType)
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

  @[Experimental]
  struct DisassembleWasmModule
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType

    def initialize(@script_id : Cdp::NodeType)
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
  struct NextWasmDisassemblyChunk
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
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
  struct GetStackTrace
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property stack_trace_id : Cdp::NodeType

    def initialize(@stack_trace_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : Cdp::NodeType

    def initialize(@breakpoint_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property call_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property mode : Cdp::NodeType?

    def initialize(@call_frame_id : Cdp::NodeType, @mode : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Debugger.restartFrame"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RestartFrameResult
      res = RestartFrameResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct Resume
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? terminate_on_resume : Bool?

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
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property query : String
    @[JSON::Field(emit_null: false)]
    property? case_sensitive : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_regex : Bool?

    def initialize(@script_id : Cdp::NodeType, @query : String, @case_sensitive : Bool?, @is_regex : Bool?)
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

  struct SetAsyncCallStackDepth
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property patterns : Array(String)
    @[JSON::Field(emit_null: false)]
    property? skip_anonymous : Bool?

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
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property positions : Array(Cdp::NodeType)

    def initialize(@script_id : Cdp::NodeType, @positions : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property condition : String?

    def initialize(@location : Cdp::NodeType, @condition : String?)
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

  struct SetInstrumentationBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property instrumentation : Cdp::NodeType

    def initialize(@instrumentation : Cdp::NodeType)
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

  struct SetBreakpointByUrl
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
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

  @[Experimental]
  struct SetBreakpointOnFunctionCall
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property condition : String?

    def initialize(@object_id : Cdp::NodeType, @condition : String?)
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

  struct SetBreakpointsActive
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? active : Bool

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
    @[JSON::Field(emit_null: false)]
    property state : Cdp::NodeType

    def initialize(@state : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property new_value : Cdp::NodeType

    def initialize(@new_value : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property script_source : String
    @[JSON::Field(emit_null: false)]
    property? dry_run : Bool?
    @[JSON::Field(emit_null: false)]
    property? allow_top_frame_editing : Bool?

    def initialize(@script_id : Cdp::NodeType, @script_source : String, @dry_run : Bool?, @allow_top_frame_editing : Bool?)
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

  struct SetSkipAllPauses
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? skip : Bool

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
    @[JSON::Field(emit_null: false)]
    property scope_number : Int64
    @[JSON::Field(emit_null: false)]
    property variable_name : String
    @[JSON::Field(emit_null: false)]
    property new_value : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property call_frame_id : Cdp::NodeType

    def initialize(@scope_number : Int64, @variable_name : String, @new_value : Cdp::NodeType, @call_frame_id : Cdp::NodeType)
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
    property? break_on_async_call : Bool?
    @[JSON::Field(emit_null: false)]
    property skip_list : Array(Cdp::NodeType)?

    def initialize(@break_on_async_call : Bool?, @skip_list : Array(Cdp::NodeType)?)
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
    property skip_list : Array(Cdp::NodeType)?

    def initialize(@skip_list : Array(Cdp::NodeType)?)
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
