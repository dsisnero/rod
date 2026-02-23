require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"

# This domain provides experimental commands only supported in headless mode.
@[Experimental]
module Cdp::HeadlessExperimental
  struct BeginFrameResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? has_damage : Bool
    @[JSON::Field(emit_null: false)]
    property screenshot_data : String?

    def initialize(@has_damage : Bool, @screenshot_data : String?)
    end
  end

  # Commands
  struct BeginFrame
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_time_ticks : Float64?
    @[JSON::Field(emit_null: false)]
    property interval : Float64?
    @[JSON::Field(emit_null: false)]
    property? no_display_updates : Bool?
    @[JSON::Field(emit_null: false)]
    property screenshot : Cdp::NodeType?

    def initialize(@frame_time_ticks : Float64?, @interval : Float64?, @no_display_updates : Bool?, @screenshot : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeadlessExperimental.beginFrame"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : BeginFrameResult
      res = BeginFrameResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
