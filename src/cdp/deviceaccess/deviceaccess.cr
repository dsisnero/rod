require "json"
require "../cdp"
require "./types"

@[Experimental]
module Cdp::DeviceAccess
  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DeviceAccess.enable"
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
      "DeviceAccess.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SelectPrompt
    include JSON::Serializable
    include Cdp::Request

    property id : RequestId
    property device_id : DeviceId

    def initialize(@id : RequestId, @device_id : DeviceId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DeviceAccess.selectPrompt"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CancelPrompt
    include JSON::Serializable
    include Cdp::Request

    property id : RequestId

    def initialize(@id : RequestId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DeviceAccess.cancelPrompt"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
