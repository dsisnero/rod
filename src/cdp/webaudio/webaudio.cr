require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# This domain allows inspection of Web Audio API.
# https://webaudio.github.io/web-audio-api/
@[Experimental]
module Cdp::WebAudio
  struct GetRealtimeDataResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property realtime_data : Cdp::NodeType

    def initialize(@realtime_data : Cdp::NodeType)
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
      "WebAudio.enable"
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
      "WebAudio.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetRealtimeData
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType

    def initialize(@context_id : Cdp::NodeType)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "WebAudio.getRealtimeData"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetRealtimeDataResult
      res = GetRealtimeDataResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
