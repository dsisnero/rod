require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../runtime/runtime"

require "./types"
require "./events"

#
@[Experimental]
module Cdp::Animation
  struct GetCurrentTimeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property current_time : Float64

    def initialize(@current_time : Float64)
    end
  end

  struct GetPlaybackRateResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property playback_rate : Float64

    def initialize(@playback_rate : Float64)
    end
  end

  struct ResolveAnimationResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property remote_object : Cdp::Runtime::RemoteObject

    def initialize(@remote_object : Cdp::Runtime::RemoteObject)
    end
  end

  # Commands
  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.disable"
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
      "Animation.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetCurrentTime
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property id : String

    def initialize(@id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.getCurrentTime"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCurrentTimeResult
      res = GetCurrentTimeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetPlaybackRate
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.getPlaybackRate"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPlaybackRateResult
      res = GetPlaybackRateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ReleaseAnimations
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property animations : Array(String)

    def initialize(@animations : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.releaseAnimations"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ResolveAnimation
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property animation_id : String

    def initialize(@animation_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.resolveAnimation"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ResolveAnimationResult
      res = ResolveAnimationResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SeekAnimations
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property animations : Array(String)
    @[JSON::Field(emit_null: false)]
    property current_time : Float64

    def initialize(@animations : Array(String), @current_time : Float64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.seekAnimations"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetPaused
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property animations : Array(String)
    @[JSON::Field(emit_null: false)]
    property? paused : Bool

    def initialize(@animations : Array(String), @paused : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.setPaused"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetPlaybackRate
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property playback_rate : Float64

    def initialize(@playback_rate : Float64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.setPlaybackRate"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetTiming
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property animation_id : String
    @[JSON::Field(emit_null: false)]
    property duration : Float64
    @[JSON::Field(emit_null: false)]
    property delay : Float64

    def initialize(@animation_id : String, @duration : Float64, @delay : Float64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Animation.setTiming"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
