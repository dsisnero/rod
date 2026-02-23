
require "../cdp"
require "json"
require "time"


require "./events"

# The Tethering domain defines methods and events for browser port binding.
@[Experimental]
module Cdp::Tethering

  # Commands
  struct Bind
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property port : Int64

    def initialize(@port : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tethering.bind"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Unbind
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property port : Int64

    def initialize(@port : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tethering.unbind"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

end
