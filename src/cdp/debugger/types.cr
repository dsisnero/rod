
require "../cdp"
require "json"
require "time"

require "../runtime/runtime"

module Cdp::Debugger
  alias BreakpointId = String

  alias CallFrameId = String

  struct Location
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64?
  end

  @[Experimental]
  struct ScriptPosition
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64
  end

  @[Experimental]
  struct LocationRange
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property start : ScriptPosition
    @[JSON::Field(emit_null: false)]
    property end : ScriptPosition
  end

  struct CallFrame
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property call_frame_id : CallFrameId
    @[JSON::Field(emit_null: false)]
    property function_name : String
    @[JSON::Field(emit_null: false)]
    property function_location : Location?
    @[JSON::Field(emit_null: false)]
    property location : Location
    @[JSON::Field(emit_null: false)]
    property scope_chain : Array(Scope)
    @[JSON::Field(emit_null: false)]
    property this : Cdp::Runtime::RemoteObject
    @[JSON::Field(emit_null: false)]
    property return_value : Cdp::Runtime::RemoteObject?
    @[JSON::Field(emit_null: false)]
    property can_be_restarted : Bool?
  end

  struct Scope
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : ScopeType
    @[JSON::Field(emit_null: false)]
    property object : Cdp::Runtime::RemoteObject
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property start_location : Location?
    @[JSON::Field(emit_null: false)]
    property end_location : Location?
  end

  struct SearchMatch
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property line_number : Float64
    @[JSON::Field(emit_null: false)]
    property line_content : String
  end

  struct BreakLocation
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64?
    @[JSON::Field(emit_null: false)]
    property type : BreakLocationType?
  end

  @[Experimental]
  struct WasmDisassemblyChunk
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property lines : Array(String)
    @[JSON::Field(emit_null: false)]
    property bytecode_offsets : Array(Int64)
  end

  alias ScriptLanguage = String

  struct DebugSymbols
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : DebugSymbolsType
    @[JSON::Field(emit_null: false)]
    property external_url : String?
  end

  struct ResolvedBreakpoint
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : BreakpointId
    @[JSON::Field(emit_null: false)]
    property location : Location
  end

  alias ScopeType = String

  alias BreakLocationType = String

  alias DebugSymbolsType = String

  alias PausedReason = String

  alias ContinueToLocationTargetCallFrames = String

  alias RestartFrameMode = String

  alias SetInstrumentationBreakpointInstrumentation = String

  alias ExceptionsState = String

  alias SetScriptSourceStatus = String

   end
