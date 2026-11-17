require "../cdp"
require "json"
require "time"

require "../page/page"
require "../dom/dom"
require "../runtime/runtime"

module Cdp::WebMCP
  struct ToolsAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "tools", emit_null: false)]
    property tools : Array(Tool)

    def initialize(@tools : Array(Tool))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebMCP.toolsAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebMCP.toolsAdded"
    end
  end

  struct ToolsRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "tools", emit_null: false)]
    property tools : Array(RemovedTool)

    def initialize(@tools : Array(RemovedTool))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebMCP.toolsRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebMCP.toolsRemoved"
    end
  end

  struct ToolInvokedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "invocationId", emit_null: false)]
    property invocation_id : String
    @[JSON::Field(key: "input", emit_null: false)]
    property input : String
    @[JSON::Field(key: "toolName", emit_null: false)]
    property tool_name : String?
    @[JSON::Field(key: "toolId", emit_null: false)]
    property tool_id : ToolId?

    def initialize(@frame_id : Cdp::Page::FrameId, @invocation_id : String, @input : String, @tool_name : String?, @tool_id : ToolId?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebMCP.toolInvoked"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebMCP.toolInvoked"
    end
  end

  struct ToolRespondedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "invocationId", emit_null: false)]
    property invocation_id : String
    @[JSON::Field(key: "status", emit_null: false)]
    property status : InvocationStatus
    @[JSON::Field(key: "output", emit_null: false)]
    property output : JSON::Any?
    @[JSON::Field(key: "errorText", emit_null: false)]
    property error_text : String?
    @[JSON::Field(key: "exception", emit_null: false)]
    property exception : Cdp::Runtime::RemoteObject?

    def initialize(@invocation_id : String, @status : InvocationStatus, @output : JSON::Any?, @error_text : String?, @exception : Cdp::Runtime::RemoteObject?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebMCP.toolResponded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebMCP.toolResponded"
    end
  end
end
