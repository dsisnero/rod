require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

#
module Cdp::Profiler
  struct GetBestEffortCoverageResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property result : Array(Cdp::NodeType)

    def initialize(@result : Array(Cdp::NodeType))
    end
  end

  struct StartPreciseCoverageResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property timestamp : Float64

    def initialize(@timestamp : Float64)
    end
  end

  struct StopResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property profile : Cdp::NodeType

    def initialize(@profile : Cdp::NodeType)
    end
  end

  struct TakePreciseCoverageResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property result : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property timestamp : Float64

    def initialize(@result : Array(Cdp::NodeType), @timestamp : Float64)
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
      "Profiler.disable"
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
      "Profiler.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetBestEffortCoverage
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.getBestEffortCoverage"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBestEffortCoverageResult
      res = GetBestEffortCoverageResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetSamplingInterval
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property interval : Int64

    def initialize(@interval : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.setSamplingInterval"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Start
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.start"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StartPreciseCoverage
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? call_count : Bool?
    @[JSON::Field(emit_null: false)]
    property? detailed : Bool?
    @[JSON::Field(emit_null: false)]
    property? allow_triggered_updates : Bool?

    def initialize(@call_count : Bool?, @detailed : Bool?, @allow_triggered_updates : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.startPreciseCoverage"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : StartPreciseCoverageResult
      res = StartPreciseCoverageResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct Stop
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.stop"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : StopResult
      res = StopResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct StopPreciseCoverage
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.stopPreciseCoverage"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct TakePreciseCoverage
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Profiler.takePreciseCoverage"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : TakePreciseCoverageResult
      res = TakePreciseCoverageResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
