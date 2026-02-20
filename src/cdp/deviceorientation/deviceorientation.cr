require "json"
require "../cdp"

@[Experimental]
module Cdp::DeviceOrientation
  # Commands
  struct ClearDeviceOrientationOverride
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DeviceOrientation.clearDeviceOrientationOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDeviceOrientationOverride
    include JSON::Serializable
    include Cdp::Request

    property alpha : Float64
    property beta : Float64
    property gamma : Float64

    def initialize(@alpha : Float64, @beta : Float64, @gamma : Float64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DeviceOrientation.setDeviceOrientationOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
