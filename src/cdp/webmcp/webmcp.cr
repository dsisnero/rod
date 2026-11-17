require "../cdp"
require "json"
require "time"

require "../page/page"
require "../dom/dom"
require "../runtime/runtime"

require "./types"
require "./events"

#
@[Experimental]
module Cdp::WebMCP
  struct InvokeToolResult
    include JSON::Serializable
    @[JSON::Field(key: "invocationId", emit_null: false)]
    property invocation_id : String

    def initialize(@invocation_id : String)
    end
  end

  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebMCP.enable"
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
      "WebMCP.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct InvokeTool
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "toolId", emit_null: false)]
    property tool_id : ToolId?
    @[JSON::Field(key: "input", emit_null: false)]
    property input : JSON::Any

    def initialize(@frame_id : Cdp::Page::FrameId, @input : JSON::Any, @tool_id : ToolId? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebMCP.invokeTool"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : InvokeToolResult
      Cdp.call(proto_req, self, InvokeToolResult, c)
    end
  end

  struct CancelInvocation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "invocationId", emit_null: false)]
    property invocation_id : String

    def initialize(@invocation_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebMCP.cancelInvocation"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
