require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"

# The SystemInfo domain defines methods and events for querying low-level system information.
@[Experimental]
module Cdp::SystemInfo
  struct GetInfoResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property gpu : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property model_name : String
    @[JSON::Field(emit_null: false)]
    property model_version : String
    @[JSON::Field(emit_null: false)]
    property command_line : String

    def initialize(@gpu : Cdp::NodeType, @model_name : String, @model_version : String, @command_line : String)
    end
  end

  struct GetFeatureStateResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? feature_enabled : Bool

    def initialize(@feature_enabled : Bool)
    end
  end

  struct GetProcessInfoResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property process_info : Array(Cdp::NodeType)

    def initialize(@process_info : Array(Cdp::NodeType))
    end
  end

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

  struct GetFeatureState
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
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
end
