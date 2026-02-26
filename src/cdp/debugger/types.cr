require "../cdp"
require "json"
require "time"

require "../runtime/runtime"

module Cdp::Debugger
  alias BreakpointId = String

  alias CallFrameId = String

  struct Location
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Int64
    @[JSON::Field(key: "columnNumber", emit_null: false)]
    property column_number : Int64?
  end

  @[Experimental]
  struct ScriptPosition
    include JSON::Serializable
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Int64
    @[JSON::Field(key: "columnNumber", emit_null: false)]
    property column_number : Int64
  end

  @[Experimental]
  struct LocationRange
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(key: "start", emit_null: false)]
    property start : ScriptPosition
    @[JSON::Field(key: "end", emit_null: false)]
    property end : ScriptPosition
  end

  struct CallFrame
    include JSON::Serializable
    @[JSON::Field(key: "callFrameId", emit_null: false)]
    property call_frame_id : CallFrameId
    @[JSON::Field(key: "functionName", emit_null: false)]
    property function_name : String
    @[JSON::Field(key: "functionLocation", emit_null: false)]
    property function_location : Location?
    @[JSON::Field(key: "location", emit_null: false)]
    property location : Location
    @[JSON::Field(key: "scopeChain", emit_null: false)]
    property scope_chain : Array(Scope)
    @[JSON::Field(key: "this", emit_null: false)]
    property this : Cdp::Runtime::RemoteObject
    @[JSON::Field(key: "returnValue", emit_null: false)]
    property return_value : Cdp::Runtime::RemoteObject?
    @[JSON::Field(key: "canBeRestarted", emit_null: false)]
    property? can_be_restarted : Bool?
  end

  struct Scope
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : ScopeType
    @[JSON::Field(key: "object", emit_null: false)]
    property object : Cdp::Runtime::RemoteObject
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String?
    @[JSON::Field(key: "startLocation", emit_null: false)]
    property start_location : Location?
    @[JSON::Field(key: "endLocation", emit_null: false)]
    property end_location : Location?
  end

  struct SearchMatch
    include JSON::Serializable
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Float64
    @[JSON::Field(key: "lineContent", emit_null: false)]
    property line_content : String
  end

  struct BreakLocation
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Int64
    @[JSON::Field(key: "columnNumber", emit_null: false)]
    property column_number : Int64?
    @[JSON::Field(key: "type", emit_null: false)]
    property type : BreakLocationType?
  end

  @[Experimental]
  struct WasmDisassemblyChunk
    include JSON::Serializable
    @[JSON::Field(key: "lines", emit_null: false)]
    property lines : Array(String)
    @[JSON::Field(key: "bytecodeOffsets", emit_null: false)]
    property bytecode_offsets : Array(Int64)
  end

  alias ScriptLanguage = String
  ScriptLanguageJavaScript  = "JavaScript"
  ScriptLanguageWebAssembly = "WebAssembly"

  struct DebugSymbols
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : DebugSymbolsType
    @[JSON::Field(key: "externalUrl", emit_null: false)]
    property external_url : String?
  end

  struct ResolvedBreakpoint
    include JSON::Serializable
    @[JSON::Field(key: "breakpointId", emit_null: false)]
    property breakpoint_id : BreakpointId
    @[JSON::Field(key: "location", emit_null: false)]
    property location : Location
  end

  alias ScopeType = String
  ScopeTypeGlobal              = "global"
  ScopeTypeLocal               = "local"
  ScopeTypeWith                = "with"
  ScopeTypeClosure             = "closure"
  ScopeTypeCatch               = "catch"
  ScopeTypeBlock               = "block"
  ScopeTypeScript              = "script"
  ScopeTypeEval                = "eval"
  ScopeTypeModule              = "module"
  ScopeTypeWasmExpressionStack = "wasm-expression-stack"

  alias BreakLocationType = String
  BreakLocationTypeDebuggerStatement = "debuggerStatement"
  BreakLocationTypeCall              = "call"
  BreakLocationTypeReturn            = "return"

  alias DebugSymbolsType = String
  DebugSymbolsTypeSourceMap     = "SourceMap"
  DebugSymbolsTypeEmbeddedDWARF = "EmbeddedDWARF"
  DebugSymbolsTypeExternalDWARF = "ExternalDWARF"

  alias PausedReason = String
  PausedReasonAmbiguous        = "ambiguous"
  PausedReasonAssert           = "assert"
  PausedReasonCSPViolation     = "CSPViolation"
  PausedReasonDebugCommand     = "debugCommand"
  PausedReasonDOM              = "DOM"
  PausedReasonEventListener    = "EventListener"
  PausedReasonException        = "exception"
  PausedReasonInstrumentation  = "instrumentation"
  PausedReasonOOM              = "OOM"
  PausedReasonOther            = "other"
  PausedReasonPromiseRejection = "promiseRejection"
  PausedReasonXHR              = "XHR"
  PausedReasonStep             = "step"

  alias ContinueToLocationTargetCallFrames = String
  ContinueToLocationTargetCallFramesAny     = "any"
  ContinueToLocationTargetCallFramesCurrent = "current"

  alias RestartFrameMode = String
  RestartFrameModeStepInto = "StepInto"

  alias SetInstrumentationBreakpointInstrumentation = String
  SetInstrumentationBreakpointInstrumentationBeforeScriptExecution              = "beforeScriptExecution"
  SetInstrumentationBreakpointInstrumentationBeforeScriptWithSourceMapExecution = "beforeScriptWithSourceMapExecution"

  alias ExceptionsState = String
  ExceptionsStateNone     = "none"
  ExceptionsStateCaught   = "caught"
  ExceptionsStateUncaught = "uncaught"
  ExceptionsStateAll      = "all"

  alias SetScriptSourceStatus = String
  SetScriptSourceStatusOk                              = "Ok"
  SetScriptSourceStatusCompileError                    = "CompileError"
  SetScriptSourceStatusBlockedByActiveGenerator        = "BlockedByActiveGenerator"
  SetScriptSourceStatusBlockedByActiveFunction         = "BlockedByActiveFunction"
  SetScriptSourceStatusBlockedByTopLevelEsModuleChange = "BlockedByTopLevelEsModuleChange"
end
