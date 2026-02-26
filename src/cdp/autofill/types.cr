require "../cdp"
require "json"
require "time"

require "../page/page"
require "../dom/dom"

module Cdp::Autofill
  struct CreditCard
    include JSON::Serializable
    @[JSON::Field(key: "number", emit_null: false)]
    property number : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "expiryMonth", emit_null: false)]
    property expiry_month : String
    @[JSON::Field(key: "expiryYear", emit_null: false)]
    property expiry_year : String
    @[JSON::Field(key: "cvc", emit_null: false)]
    property cvc : String
  end

  struct AddressField
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
  end

  struct AddressFields
    include JSON::Serializable
    @[JSON::Field(key: "fields", emit_null: false)]
    property fields : Array(AddressField)
  end

  struct Address
    include JSON::Serializable
    @[JSON::Field(key: "fields", emit_null: false)]
    property fields : Array(AddressField)
  end

  struct AddressUI
    include JSON::Serializable
    @[JSON::Field(key: "addressFields", emit_null: false)]
    property address_fields : Array(AddressFields)
  end

  alias FillingStrategy = String
  FillingStrategyAutocompleteAttribute = "autocompleteAttribute"
  FillingStrategyAutofillInferred      = "autofillInferred"

  struct FilledField
    include JSON::Serializable
    @[JSON::Field(key: "htmlType", emit_null: false)]
    property html_type : String
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "autofillType", emit_null: false)]
    property autofill_type : String
    @[JSON::Field(key: "fillingStrategy", emit_null: false)]
    property filling_strategy : FillingStrategy
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "fieldId", emit_null: false)]
    property field_id : Cdp::DOM::BackendNodeId
  end
end
