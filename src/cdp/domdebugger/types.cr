require "../cdp"
require "json"
require "base64"
require "time"

require "../runtime/runtime"
require "../dom/dom"

module Cdp::DOMDebugger
  alias DOMBreakpointType = String
  DOMBreakpointTypeSubtreeModified   = "subtree-modified"
  DOMBreakpointTypeAttributeModified = "attribute-modified"
  DOMBreakpointTypeNodeRemoved       = "node-removed"

  @[Experimental]
  alias CSPViolationType = String
  CSPViolationTypeTrustedtypeSinkViolation   = "trustedtype-sink-violation"
  CSPViolationTypeTrustedtypePolicyViolation = "trustedtype-policy-violation"

  struct EventListener
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String
    @[JSON::Field(key: "useCapture", emit_null: false)]
    property? use_capture : Bool
    @[JSON::Field(key: "passive", emit_null: false)]
    property? passive : Bool
    @[JSON::Field(key: "once", emit_null: false)]
    property? once : Bool
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Int64
    @[JSON::Field(key: "columnNumber", emit_null: false)]
    property column_number : Int64
    @[JSON::Field(key: "handler", emit_null: false)]
    property handler : Cdp::Runtime::RemoteObject?
    @[JSON::Field(key: "originalHandler", emit_null: false)]
    property original_handler : Cdp::Runtime::RemoteObject?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?

    def initialize(@type : String, @use_capture : Bool, @passive : Bool, @once : Bool, @script_id : Cdp::Runtime::ScriptId, @line_number : Int64, @column_number : Int64, @handler : Cdp::Runtime::RemoteObject? = nil, @original_handler : Cdp::Runtime::RemoteObject? = nil, @backend_node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end
end
