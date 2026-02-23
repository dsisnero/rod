require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

#
module Cdp::Performance
  struct GetMetricsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property metrics : Array(Cdp::NodeType)

    def initialize(@metrics : Array(Cdp::NodeType))
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
      "Performance.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property time_domain : Cdp::NodeType?

    def initialize(@time_domain : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Performance.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetMetrics
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Performance.getMetrics"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetMetricsResult
      res = GetMetricsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
