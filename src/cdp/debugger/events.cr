require "../cdp"
require "json"
require "time"

require "../runtime/runtime"

module Cdp::Debugger
  struct PausedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property call_frames : Array(CallFrame)
    @[JSON::Field(emit_null: false)]
    property reason : PausedReason
    @[JSON::Field(emit_null: false)]
    property data : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property hit_breakpoints : Array(String)?
    @[JSON::Field(emit_null: false)]
    property async_stack_trace : Cdp::Runtime::StackTrace?
    @[JSON::Field(emit_null: false)]
    property async_stack_trace_id : Cdp::Runtime::StackTraceId?
    @[JSON::Field(emit_null: false)]
    property async_call_stack_trace_id : Cdp::Runtime::StackTraceId?

    def initialize(@call_frames : Array(CallFrame), @reason : PausedReason, @data : JSON::Any?, @hit_breakpoints : Array(String)?, @async_stack_trace : Cdp::Runtime::StackTrace?, @async_stack_trace_id : Cdp::Runtime::StackTraceId?, @async_call_stack_trace_id : Cdp::Runtime::StackTraceId?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Debugger.paused"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Debugger.paused"
    end
  end

  struct ResumedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Debugger.resumed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Debugger.resumed"
    end
  end

  struct ScriptFailedToParseEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property start_line : Int64
    @[JSON::Field(emit_null: false)]
    property start_column : Int64
    @[JSON::Field(emit_null: false)]
    property end_line : Int64
    @[JSON::Field(emit_null: false)]
    property end_column : Int64
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::Runtime::ExecutionContextId
    @[JSON::Field(emit_null: false)]
    property hash : String
    @[JSON::Field(emit_null: false)]
    property build_id : String
    @[JSON::Field(emit_null: false)]
    property execution_context_aux_data : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property source_map_url : String?
    @[JSON::Field(emit_null: false)]
    property? has_source_url : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_module : Bool?
    @[JSON::Field(emit_null: false)]
    property length : Int64?
    @[JSON::Field(emit_null: false)]
    property stack_trace : Cdp::Runtime::StackTrace?
    @[JSON::Field(emit_null: false)]
    property code_offset : Int64?
    @[JSON::Field(emit_null: false)]
    property script_language : ScriptLanguage?
    @[JSON::Field(emit_null: false)]
    property embedder_name : String?

    def initialize(@script_id : Cdp::Runtime::ScriptId, @url : String, @start_line : Int64, @start_column : Int64, @end_line : Int64, @end_column : Int64, @execution_context_id : Cdp::Runtime::ExecutionContextId, @hash : String, @build_id : String, @execution_context_aux_data : JSON::Any?, @source_map_url : String?, @has_source_url : Bool?, @is_module : Bool?, @length : Int64?, @stack_trace : Cdp::Runtime::StackTrace?, @code_offset : Int64?, @script_language : ScriptLanguage?, @embedder_name : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Debugger.scriptFailedToParse"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Debugger.scriptFailedToParse"
    end
  end

  struct ScriptParsedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property start_line : Int64
    @[JSON::Field(emit_null: false)]
    property start_column : Int64
    @[JSON::Field(emit_null: false)]
    property end_line : Int64
    @[JSON::Field(emit_null: false)]
    property end_column : Int64
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::Runtime::ExecutionContextId
    @[JSON::Field(emit_null: false)]
    property hash : String
    @[JSON::Field(emit_null: false)]
    property build_id : String
    @[JSON::Field(emit_null: false)]
    property execution_context_aux_data : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property? is_live_edit : Bool?
    @[JSON::Field(emit_null: false)]
    property source_map_url : String?
    @[JSON::Field(emit_null: false)]
    property? has_source_url : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_module : Bool?
    @[JSON::Field(emit_null: false)]
    property length : Int64?
    @[JSON::Field(emit_null: false)]
    property stack_trace : Cdp::Runtime::StackTrace?
    @[JSON::Field(emit_null: false)]
    property code_offset : Int64?
    @[JSON::Field(emit_null: false)]
    property script_language : ScriptLanguage?
    @[JSON::Field(emit_null: false)]
    property debug_symbols : Array(DebugSymbols)?
    @[JSON::Field(emit_null: false)]
    property embedder_name : String?
    @[JSON::Field(emit_null: false)]
    property resolved_breakpoints : Array(ResolvedBreakpoint)?

    def initialize(@script_id : Cdp::Runtime::ScriptId, @url : String, @start_line : Int64, @start_column : Int64, @end_line : Int64, @end_column : Int64, @execution_context_id : Cdp::Runtime::ExecutionContextId, @hash : String, @build_id : String, @execution_context_aux_data : JSON::Any?, @is_live_edit : Bool?, @source_map_url : String?, @has_source_url : Bool?, @is_module : Bool?, @length : Int64?, @stack_trace : Cdp::Runtime::StackTrace?, @code_offset : Int64?, @script_language : ScriptLanguage?, @debug_symbols : Array(DebugSymbols)?, @embedder_name : String?, @resolved_breakpoints : Array(ResolvedBreakpoint)?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Debugger.scriptParsed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Debugger.scriptParsed"
    end
  end
end
