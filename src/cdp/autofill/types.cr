require "../autofill/autofill"
require "json"
require "time"
require "../dom/dom"
require "../page/page"

module Cdp::Autofill
  struct CreditCard
    include JSON::Serializable

    property number : String
    property name : String
    property expiry_month : String
    property expiry_year : String
    property cvc : String
  end

  struct AddressField
    include JSON::Serializable

    property name : String
    property value : String
  end

  struct AddressFields
    include JSON::Serializable

    property fields : Array(AddressField)
  end

  struct Address
    include JSON::Serializable

    property fields : Array(AddressField)
  end

  struct AddressUI
    include JSON::Serializable

    property address_fields : Array(AddressFields)
  end

  alias FillingStrategy = String

  struct FilledField
    include JSON::Serializable

    property html_type : String
    property id : String
    property name : String
    property value : String
    property autofill_type : String
    property filling_strategy : FillingStrategy
    property frame_id : Cdp::Page::FrameId
    property field_id : Cdp::DOM::BackendNodeId
  end
end
