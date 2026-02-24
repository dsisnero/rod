require "../cdp"
require "json"
require "time"

require "../page/page"
require "../dom/dom"

module Cdp::Autofill
  struct AddressFormFilledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property filled_fields : Array(FilledField)
    @[JSON::Field(emit_null: false)]
    property address_ui : AddressUI

    def initialize(@filled_fields : Array(FilledField), @address_ui : AddressUI)
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
