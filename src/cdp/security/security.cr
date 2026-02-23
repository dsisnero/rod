require "../cdp"
require "json"
require "time"

require "../network/network"

require "./types"
require "./events"

#
module Cdp::Security
  # Commands
  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Security.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Security.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetIgnoreCertificateErrors
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? ignore : Bool

    def initialize(@ignore : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Security.setIgnoreCertificateErrors"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
