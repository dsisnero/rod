
require "../cdp"
require "json"
require "time"



# EventBreakpoints permits setting JavaScript breakpoints on operations and events
# occurring in native code invoked from JavaScript. Once breakpoint is hit, it is
# reported through Debugger domain, similarly to regular breakpoints being hit.
@[Experimental]
module Cdp::EventBreakpoints

  # Commands
  struct SetInstrumentationBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property event_name : String

    def initialize(@event_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "EventBreakpoints.setInstrumentationBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveInstrumentationBreakpoint
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property event_name : String

    def initialize(@event_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "EventBreakpoints.removeInstrumentationBreakpoint"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize()
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "EventBreakpoints.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

end
