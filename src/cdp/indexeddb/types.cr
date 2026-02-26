require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../storage/storage"

module Cdp::IndexedDB
  struct DatabaseWithObjectStores
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : Float64
    @[JSON::Field(key: "objectStores", emit_null: false)]
    property object_stores : Array(ObjectStore)
  end

  struct ObjectStore
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "keyPath", emit_null: false)]
    property key_path : KeyPath
    @[JSON::Field(key: "autoIncrement", emit_null: false)]
    property? auto_increment : Bool
    @[JSON::Field(key: "indexes", emit_null: false)]
    property indexes : Array(ObjectStoreIndex)
  end

  struct ObjectStoreIndex
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "keyPath", emit_null: false)]
    property key_path : KeyPath
    @[JSON::Field(key: "unique", emit_null: false)]
    property? unique : Bool
    @[JSON::Field(key: "multiEntry", emit_null: false)]
    property? multi_entry : Bool
  end

  struct Key
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : KeyType
    @[JSON::Field(key: "number", emit_null: false)]
    property number : Float64?
    @[JSON::Field(key: "string", emit_null: false)]
    property string : String?
    @[JSON::Field(key: "date", emit_null: false)]
    property date : Float64?
    @[JSON::Field(key: "array", emit_null: false)]
    property array : Array(Key)?
  end

  struct KeyRange
    include JSON::Serializable
    @[JSON::Field(key: "lower", emit_null: false)]
    property lower : Key?
    @[JSON::Field(key: "upper", emit_null: false)]
    property upper : Key?
    @[JSON::Field(key: "lowerOpen", emit_null: false)]
    property? lower_open : Bool
    @[JSON::Field(key: "upperOpen", emit_null: false)]
    property? upper_open : Bool
  end

  struct DataEntry
    include JSON::Serializable
    @[JSON::Field(key: "key", emit_null: false)]
    property key : Cdp::Runtime::RemoteObject
    @[JSON::Field(key: "primaryKey", emit_null: false)]
    property primary_key : Cdp::Runtime::RemoteObject
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Cdp::Runtime::RemoteObject
  end

  struct KeyPath
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : KeyPathType
    @[JSON::Field(key: "string", emit_null: false)]
    property string : String?
    @[JSON::Field(key: "array", emit_null: false)]
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
