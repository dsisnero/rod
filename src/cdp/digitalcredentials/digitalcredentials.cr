require "../cdp"
require "json"
require "time"

require "../page/page"

require "./types"

# This domain allows interacting with the Digital Credentials API for automation.
@[Experimental]
module Cdp::DigitalCredentials
  # Commands
  struct SetVirtualWalletBehavior
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "action", emit_null: false)]
    property action : VirtualWalletAction
    @[JSON::Field(key: "protocol", emit_null: false)]
    property protocol : String?
    @[JSON::Field(key: "response", emit_null: false)]
    property response : JSON::Any?
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId?

    def initialize(@action : VirtualWalletAction, @protocol : String? = nil, @response : JSON::Any? = nil, @frame_id : Cdp::Page::FrameId? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "DigitalCredentials.setVirtualWalletBehavior"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
