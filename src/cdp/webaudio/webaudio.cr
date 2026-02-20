require "json"
require "../cdp"
require "./types"

# This domain allows inspection of Web Audio API.
# https://webaudio.github.io/web-audio-api/
@[Experimental]
module Cdp::WebAudio
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

    property context_id : GraphObjectId

    def initialize(@context_id : GraphObjectId)
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

  struct GetRealtimeDataResult
    include JSON::Serializable

    property realtime_data : ContextRealtimeData

    def initialize(@realtime_data : ContextRealtimeData)
    end
  end
end
