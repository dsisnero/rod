require "../cdp"
require "json"
require "base64"
require "time"

require "../page/page"
require "../dom/dom"
require "../runtime/runtime"

module Cdp::WebMCP
  struct Annotation
    include JSON::Serializable
    @[JSON::Field(key: "readOnly", emit_null: false)]
    property? read_only : Bool?
    @[JSON::Field(key: "untrustedContent", emit_null: false)]
    property? untrusted_content : Bool?
    @[JSON::Field(key: "consequential", emit_null: false)]
    property? consequential : Bool?
    @[JSON::Field(key: "debugging", emit_null: false)]
    property? debugging : Bool?
    @[JSON::Field(key: "autosubmit", emit_null: false)]
    property? autosubmit : Bool?

    def initialize(@read_only : Bool? = nil, @untrusted_content : Bool? = nil, @consequential : Bool? = nil, @debugging : Bool? = nil, @autosubmit : Bool? = nil)
    end
  end

  alias InvocationStatus = String
  InvocationStatusCompleted = "Completed"
  InvocationStatusCanceled  = "Canceled"
  InvocationStatusError     = "Error"

  alias ToolId = String

  struct Tool
    include JSON::Serializable
    @[JSON::Field(key: "toolId", emit_null: false)]
    property tool_id : ToolId
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "description", emit_null: false)]
    property description : String
    @[JSON::Field(key: "inputSchema", emit_null: false)]
    property input_schema : JSON::Any?
    @[JSON::Field(key: "outputSchema", emit_null: false)]
    property output_schema : JSON::Any?
    @[JSON::Field(key: "annotations", emit_null: false)]
    property annotations : Annotation?
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "stackTrace", emit_null: false)]
    property stack_trace : Cdp::Runtime::StackTrace?

    def initialize(@tool_id : ToolId, @name : String, @description : String, @frame_id : Cdp::Page::FrameId, @input_schema : JSON::Any? = nil, @output_schema : JSON::Any? = nil, @annotations : Annotation? = nil, @backend_node_id : Cdp::DOM::BackendNodeId? = nil, @stack_trace : Cdp::Runtime::StackTrace? = nil)
    end
  end

  struct RemovedTool
    include JSON::Serializable
    @[JSON::Field(key: "toolId", emit_null: false)]
    property tool_id : ToolId
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId

    def initialize(@tool_id : ToolId, @name : String, @frame_id : Cdp::Page::FrameId)
    end
  end
end
