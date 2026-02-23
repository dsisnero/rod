
require "../cdp"
require "json"
require "time"

require "../network/network"
require "../io/io"
require "../page/page"

module Cdp::Fetch
  struct RequestPausedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property request : Cdp::Network::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::Network::ResourceType
    @[JSON::Field(emit_null: false)]
    property response_error_reason : Cdp::Network::ErrorReason?
    @[JSON::Field(emit_null: false)]
    property response_status_code : Int64?
    @[JSON::Field(emit_null: false)]
    property response_status_text : String?
    @[JSON::Field(emit_null: false)]
    property response_headers : Array(HeaderEntry)?
    @[JSON::Field(emit_null: false)]
    property network_id : Cdp::Network::RequestId?
    @[JSON::Field(emit_null: false)]
    property redirected_request_id : RequestId?

    def initialize(@request_id : RequestId, @request : Cdp::Network::Request, @frame_id : Cdp::Page::FrameId, @resource_type : Cdp::Network::ResourceType, @response_error_reason : Cdp::Network::ErrorReason?, @response_status_code : Int64?, @response_status_text : String?, @response_headers : Array(HeaderEntry)?, @network_id : Cdp::Network::RequestId?, @redirected_request_id : RequestId?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Fetch.requestPaused"
    end
  end

  struct AuthRequiredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId
    @[JSON::Field(emit_null: false)]
    property request : Cdp::Network::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::Network::ResourceType
    @[JSON::Field(emit_null: false)]
    property auth_challenge : AuthChallenge

    def initialize(@request_id : RequestId, @request : Cdp::Network::Request, @frame_id : Cdp::Page::FrameId, @resource_type : Cdp::Network::ResourceType, @auth_challenge : AuthChallenge)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Fetch.authRequired"
    end
  end

end
