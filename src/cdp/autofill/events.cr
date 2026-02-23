require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Autofill
  struct AddressFormFilledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property filled_fields : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property address_ui : Cdp::NodeType

    def initialize(@filled_fields : Array(Cdp::NodeType), @address_ui : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Autofill.addressFormFilled"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Autofill.addressFormFilled"
    end
  end
end
