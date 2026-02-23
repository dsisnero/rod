require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# A domain for interacting with Cast, Presentation API, and Remote Playback API
# functionalities.
@[Experimental]
module Cdp::Cast
  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property presentation_url : String?

    def initialize(@presentation_url : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Cast.enable"
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
      "Cast.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetSinkToUse
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property sink_name : String

    def initialize(@sink_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Cast.setSinkToUse"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StartDesktopMirroring
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property sink_name : String

    def initialize(@sink_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Cast.startDesktopMirroring"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StartTabMirroring
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property sink_name : String

    def initialize(@sink_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Cast.startTabMirroring"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopCasting
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property sink_name : String

    def initialize(@sink_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Cast.stopCasting"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
