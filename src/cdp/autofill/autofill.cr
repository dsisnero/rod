require "../cdp"
require "json"
require "time"

require "../page/page"
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
    property field_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
    @[JSON::Field(emit_null: false)]
    property card : CreditCard?
    @[JSON::Field(emit_null: false)]
    property address : Address?

    def initialize(@field_id : Cdp::DOM::BackendNodeId, @frame_id : Cdp::Page::FrameId?, @card : CreditCard?, @address : Address?)
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
    property addresses : Array(Address)

    def initialize(@addresses : Array(Address))
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
