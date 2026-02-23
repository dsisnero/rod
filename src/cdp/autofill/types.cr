require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Autofill
  struct CreditCard
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property number : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property expiry_month : String
    @[JSON::Field(emit_null: false)]
    property expiry_year : String
    @[JSON::Field(emit_null: false)]
    property cvc : String
  end

  struct AddressField
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  struct AddressFields
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property fields : Array(Cdp::NodeType)
  end

  struct Address
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property fields : Array(Cdp::NodeType)
  end

  struct AddressUI
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property address_fields : Array(Cdp::NodeType)
  end

  alias FillingStrategy = String
  FillingStrategyAutocompleteAttribute = "autocompleteAttribute"
  FillingStrategyAutofillInferred      = "autofillInferred"

  struct FilledField
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property html_type : String
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property autofill_type : String
    @[JSON::Field(emit_null: false)]
    property filling_strategy : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property field_id : Cdp::NodeType
  end
end
