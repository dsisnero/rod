require "../cdp"
require "json"
require "time"

require "../page/page"
require "../runtime/runtime"
require "../network/network"

require "./types"

# A domain for ad-related metrics and data.
@[Experimental]
module Cdp::Ads
  struct GetAdMetricsResult
    include JSON::Serializable
    @[JSON::Field(key: "metrics", emit_null: false)]
    property metrics : AdMetrics

    def initialize(@metrics : AdMetrics)
    end
  end

  struct GetAdScriptsResult
    include JSON::Serializable
    @[JSON::Field(key: "newScripts", emit_null: false)]
    property new_scripts : Array(AdScript)

    def initialize(@new_scripts : Array(AdScript))
    end
  end

  # Commands
  struct GetAdMetrics
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Ads.getAdMetrics"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAdMetricsResult
      Cdp.call(proto_req, self, GetAdMetricsResult, c)
    end
  end

  struct GetAdScripts
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Ads.getAdScripts"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAdScriptsResult
      Cdp.call(proto_req, self, GetAdScriptsResult, c)
    end
  end
end
