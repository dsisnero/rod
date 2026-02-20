require "json"
require "../cdp"
require "./types"

# The SystemInfo domain defines methods and events for querying low-level system information.
@[Experimental]
module Cdp::SystemInfo
  # Commands
  struct GetInfo
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SystemInfo.getInfo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetInfoResult
      res = GetInfoResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetInfoResult
    include JSON::Serializable

    property gpu : GPUInfo
    property model_name : String
    property model_version : String
    property command_line : String

    def initialize(@gpu : GPUInfo, @model_name : String, @model_version : String, @command_line : String)
    end
  end

  struct GetFeatureState
    include JSON::Serializable
    include Cdp::Request

    property feature_state : String

    def initialize(@feature_state : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SystemInfo.getFeatureState"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFeatureStateResult
      res = GetFeatureStateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetFeatureStateResult
    include JSON::Serializable

    property feature_enabled : Bool

    def initialize(@feature_enabled : Bool)
    end
  end

  struct GetProcessInfo
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "SystemInfo.getProcessInfo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetProcessInfoResult
      res = GetProcessInfoResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetProcessInfoResult
    include JSON::Serializable

    property process_info : Array(ProcessInfo)

    def initialize(@process_info : Array(ProcessInfo))
    end
  end
end
