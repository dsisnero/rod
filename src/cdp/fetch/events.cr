require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Fetch
  struct RequestPausedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response_error_reason : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property response_status_code : Int64?
    @[JSON::Field(emit_null: false)]
    property response_status_text : String?
    @[JSON::Field(emit_null: false)]
    property response_headers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property network_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property redirected_request_id : Cdp::NodeType?

    def initialize(@request_id : Cdp::NodeType, @request : Cdp::NodeType, @frame_id : Cdp::NodeType, @resource_type : Cdp::NodeType, @response_error_reason : Cdp::NodeType?, @response_status_code : Int64?, @response_status_text : String?, @response_headers : Array(Cdp::NodeType)?, @network_id : Cdp::NodeType?, @redirected_request_id : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Fetch.requestPaused"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Fetch.requestPaused"
    end
  end

  struct AuthRequiredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property auth_challenge : Cdp::NodeType

    def initialize(@request_id : Cdp::NodeType, @request : Cdp::NodeType, @frame_id : Cdp::NodeType, @resource_type : Cdp::NodeType, @auth_challenge : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Fetch.authRequired"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Fetch.authRequired"
    end
  end
end
