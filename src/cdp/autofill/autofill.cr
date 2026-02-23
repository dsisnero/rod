require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Defines commands and events for Autofill.
@[Experimental]
module Cdp::Autofill
  # Commands
  struct Trigger
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property field_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property card : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property address : Cdp::NodeType?

    def initialize(@field_id : Cdp::NodeType, @frame_id : Cdp::NodeType?, @card : Cdp::NodeType?, @address : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Autofill.trigger"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetAddresses
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property addresses : Array(Cdp::NodeType)

    def initialize(@addresses : Array(Cdp::NodeType))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Autofill.setAddresses"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Autofill.disable"
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
      "Autofill.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
