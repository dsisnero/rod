require "../indexeddb/indexeddb"
require "json"
require "time"
require "../storage/storage"

module Cdp::IndexedDB
  struct DatabaseWithObjectStores
    include JSON::Serializable

    property name : String
    property version : Float64
    property object_stores : Array(ObjectStore)
  end

  struct ObjectStore
    include JSON::Serializable

    property name : String
    property key_path : KeyPath
    property auto_increment : Bool
    property indexes : Array(ObjectStoreIndex)
  end

  struct ObjectStoreIndex
    include JSON::Serializable

    property name : String
    property key_path : KeyPath
    property unique : Bool
    property multi_entry : Bool
  end

  struct Key
    include JSON::Serializable

    property type : KeyType
    @[JSON::Field(emit_null: false)]
    property number : Float64?
    @[JSON::Field(emit_null: false)]
    property string : String?
    @[JSON::Field(emit_null: false)]
    property date : Float64?
    @[JSON::Field(emit_null: false)]
    property array : Array(Key)?
  end

  struct KeyRange
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property lower : Key?
    @[JSON::Field(emit_null: false)]
    property upper : Key?
    property lower_open : Bool
    property upper_open : Bool
  end

  struct DataEntry
    include JSON::Serializable

    property key : Cdp::Runtime::RemoteObject
    property primary_key : Cdp::Runtime::RemoteObject
    property value : Cdp::Runtime::RemoteObject
  end

  struct KeyPath
    include JSON::Serializable

    property type : KeyPathType
    @[JSON::Field(emit_null: false)]
    property string : String?
    @[JSON::Field(emit_null: false)]
    property array : Array(String)?
  end

  alias KeyType = String

  alias KeyPathType = String
end
