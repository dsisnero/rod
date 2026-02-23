
require "../cdp"
require "json"
require "time"

require "../page/page"
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
    property fields : Array(AddressField)
  end

  struct Address
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property fields : Array(AddressField)
  end

  struct AddressUI
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property address_fields : Array(AddressFields)
  end

  alias FillingStrategy = String

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
    property filling_strategy : FillingStrategy
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property field_id : Cdp::DOM::BackendNodeId
  end

   end
