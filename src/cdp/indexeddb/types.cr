require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::IndexedDB
  struct DatabaseWithObjectStores
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property version : Float64
    @[JSON::Field(emit_null: false)]
    property object_stores : Array(Cdp::NodeType)
  end

  struct ObjectStore
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property key_path : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? auto_increment : Bool
    @[JSON::Field(emit_null: false)]
    property indexes : Array(Cdp::NodeType)
  end

  struct ObjectStoreIndex
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property key_path : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? unique : Bool
    @[JSON::Field(emit_null: false)]
    property? multi_entry : Bool
  end

  struct Key
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property number : Float64?
    @[JSON::Field(emit_null: false)]
    property string : String?
    @[JSON::Field(emit_null: false)]
    property date : Float64?
    @[JSON::Field(emit_null: false)]
    property array : Array(Cdp::NodeType)?
  end

  struct KeyRange
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property lower : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property upper : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? lower_open : Bool
    @[JSON::Field(emit_null: false)]
    property? upper_open : Bool
  end

  struct DataEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property primary_key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType
  end

  struct KeyPath
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property string : String?
    @[JSON::Field(emit_null: false)]
    property array : Array(String)?
  end

  alias KeyType = String
  KeyTypeNumberType = "number"
  KeyTypeStringType = "string"
  KeyTypeDate       = "date"
  KeyTypeArray      = "array"

  alias KeyPathType = String
  KeyPathTypeNull       = "null"
  KeyPathTypeStringType = "string"
  KeyPathTypeArray      = "array"
end
