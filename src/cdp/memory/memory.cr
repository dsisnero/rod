require "json"
require "../cdp"
require "./types"

@[Experimental]
module Cdp::Memory
  # Commands
  struct GetDOMCounters
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.getDOMCounters"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDOMCountersResult
      res = GetDOMCountersResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetDOMCountersResult
    include JSON::Serializable

    property documents : Int64
    property nodes : Int64
    property js_event_listeners : Int64

    def initialize(@documents : Int64, @nodes : Int64, @js_event_listeners : Int64)
    end
  end

  struct GetDOMCountersForLeakDetection
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.getDOMCountersForLeakDetection"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDOMCountersForLeakDetectionResult
      res = GetDOMCountersForLeakDetectionResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetDOMCountersForLeakDetectionResult
    include JSON::Serializable

    property counters : Array(DOMCounter)

    def initialize(@counters : Array(DOMCounter))
    end
  end

  struct PrepareForLeakDetection
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.prepareForLeakDetection"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ForciblyPurgeJavaScriptMemory
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.forciblyPurgeJavaScriptMemory"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetPressureNotificationsSuppressed
    include JSON::Serializable
    include Cdp::Request

    property suppressed : Bool

    def initialize(@suppressed : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.setPressureNotificationsSuppressed"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SimulatePressureNotification
    include JSON::Serializable
    include Cdp::Request

    property level : PressureLevel

    def initialize(@level : PressureLevel)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.simulatePressureNotification"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StartSampling
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property sampling_interval : Int64?
    @[JSON::Field(emit_null: false)]
    property suppress_randomness : Bool?

    def initialize(@sampling_interval : Int64?, @suppress_randomness : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.startSampling"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopSampling
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.stopSampling"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetAllTimeSamplingProfile
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.getAllTimeSamplingProfile"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAllTimeSamplingProfileResult
      res = GetAllTimeSamplingProfileResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetAllTimeSamplingProfileResult
    include JSON::Serializable

    property profile : SamplingProfile

    def initialize(@profile : SamplingProfile)
    end
  end

  struct GetBrowserSamplingProfile
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.getBrowserSamplingProfile"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBrowserSamplingProfileResult
      res = GetBrowserSamplingProfileResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetBrowserSamplingProfileResult
    include JSON::Serializable

    property profile : SamplingProfile

    def initialize(@profile : SamplingProfile)
    end
  end

  struct GetSamplingProfile
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Memory.getSamplingProfile"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSamplingProfileResult
      res = GetSamplingProfileResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetSamplingProfileResult
    include JSON::Serializable

    property profile : SamplingProfile

    def initialize(@profile : SamplingProfile)
    end
  end
end
