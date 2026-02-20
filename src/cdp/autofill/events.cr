require "../autofill/autofill"
require "json"
require "time"
require "../dom/dom"
require "../page/page"

module Cdp::Autofill
  struct AddressFormFilledEvent
    include JSON::Serializable
    include Cdp::Event

    property filled_fields : Array(FilledField)
    property address_ui : AddressUI

    def initialize(@filled_fields : Array(FilledField), @address_ui : AddressUI)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Autofill.addressFormFilled"
    end
  end
end
