
require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../dom/dom"

module Cdp::DOMDebugger
  alias DOMBreakpointType = String

  @[Experimental]
  alias CSPViolationType = String

  struct EventListener
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : String
    @[JSON::Field(emit_null: false)]
    property use_capture : Bool
    @[JSON::Field(emit_null: false)]
    property passive : Bool
    @[JSON::Field(emit_null: false)]
    property once : Bool
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64
    @[JSON::Field(emit_null: false)]
    property handler : Cdp::Runtime::RemoteObject?
    @[JSON::Field(emit_null: false)]
    property original_handler : Cdp::Runtime::RemoteObject?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
  end

   end
