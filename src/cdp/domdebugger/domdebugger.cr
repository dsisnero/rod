require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../dom/dom"

require "./types"

# DOM debugging allows setting breakpoints on particular DOM operations and events. JavaScript
# execution will stop on these operations as if there was a regular breakpoint set.
module Cdp::DOMDebugger
  struct GetEventListenersResult
    include JSON::Serializable
    @[JSON::Field(key: "listeners", emit_null: false)]
    property listeners : Array(EventListener)

    def initialize(@listeners : Array(EventListener))
    end
  end

  # Commands
  struct GetEventListeners
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "objectId", emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId
    @[JSON::Field(key: "depth", emit_null: false)]
    property depth : Int64?
    @[JSON::Field(key: "pierce", emit_null: false)]
    property? pierce : Bool?

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId, @depth : Int64?, @pierce : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.getEventListeners"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetEventListenersResult
      res = GetEventListenersResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RemoveDOMBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
    @[JSON::Field(key: "type", emit_null: false)]
    property type : DOMBreakpointType

    def initialize(@node_id : Cdp::DOM::NodeId, @type : DOMBreakpointType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.removeDOMBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveEventListenerBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "eventName", emit_null: false)]
    property event_name : String
    @[JSON::Field(key: "targetName", emit_null: false)]
    property target_name : String?

    def initialize(@event_name : String, @target_name : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.removeEventListenerBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveXHRBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String

    def initialize(@url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.removeXHRBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetBreakOnCSPViolation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "violationTypes", emit_null: false)]
    property violation_types : Array(CSPViolationType)

    def initialize(@violation_types : Array(CSPViolationType))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.setBreakOnCSPViolation"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDOMBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::NodeId
    @[JSON::Field(key: "type", emit_null: false)]
    property type : DOMBreakpointType

    def initialize(@node_id : Cdp::DOM::NodeId, @type : DOMBreakpointType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.setDOMBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetEventListenerBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "eventName", emit_null: false)]
    property event_name : String
    @[JSON::Field(key: "targetName", emit_null: false)]
    property target_name : String?

    def initialize(@event_name : String, @target_name : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.setEventListenerBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetXHRBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String

    def initialize(@url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DOMDebugger.setXHRBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
