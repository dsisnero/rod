require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Debugger
  alias BreakpointId = String

  alias CallFrameId = String

  struct Location
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType
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
    property script_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property start : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property end : Cdp::NodeType
  end

  struct CallFrame
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property call_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property function_name : String
    @[JSON::Field(emit_null: false)]
    property function_location : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property scope_chain : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property this : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property return_value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? can_be_restarted : Bool?
  end

  struct Scope
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property object : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property start_location : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property end_location : Cdp::NodeType?
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
    property script_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64?
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType?
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
  ScriptLanguageJavaScript  = "JavaScript"
  ScriptLanguageWebAssembly = "WebAssembly"

  struct DebugSymbols
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property external_url : String?
  end

  struct ResolvedBreakpoint
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property breakpoint_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
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
