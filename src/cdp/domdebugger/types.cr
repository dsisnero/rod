require "../domdebugger/domdebugger"
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

    property type : String
    property use_capture : Bool
    property passive : Bool
    property once : Bool
    property script_id : Cdp::Runtime::ScriptId
    property line_number : Int64
    property column_number : Int64
    @[JSON::Field(emit_null: false)]
    property handler : Cdp::Runtime::RemoteObject?
    @[JSON::Field(emit_null: false)]
    property original_handler : Cdp::Runtime::RemoteObject?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
  end
end
