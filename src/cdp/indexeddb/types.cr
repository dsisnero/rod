require "../cdp"
require "json"
require "base64"
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

    def initialize(@name : String, @version : Float64, @object_stores : Array(ObjectStore))
    end
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

    def initialize(@name : String, @key_path : KeyPath, @auto_increment : Bool, @indexes : Array(ObjectStoreIndex))
    end
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

    def initialize(@name : String, @key_path : KeyPath, @unique : Bool, @multi_entry : Bool)
    end
  end

  class Key
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

    def initialize(@type : KeyType, @number : Float64? = nil, @string : String? = nil, @date : Float64? = nil, @array : Array(Key)? = nil)
    end
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

    def initialize(@lower_open : Bool, @upper_open : Bool, @lower : Key? = nil, @upper : Key? = nil)
    end
  end

  struct DataEntry
    include JSON::Serializable
    @[JSON::Field(key: "key", emit_null: false)]
    property key : Cdp::Runtime::RemoteObject
    @[JSON::Field(key: "primaryKey", emit_null: false)]
    property primary_key : Cdp::Runtime::RemoteObject
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Cdp::Runtime::RemoteObject

    def initialize(@key : Cdp::Runtime::RemoteObject, @primary_key : Cdp::Runtime::RemoteObject, @value : Cdp::Runtime::RemoteObject)
    end
  end

  struct KeyPath
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : KeyPathType
    @[JSON::Field(key: "string", emit_null: false)]
    property string : String?
    @[JSON::Field(key: "array", emit_null: false)]
    property array : Array(String)?

    def initialize(@type : KeyPathType, @string : String? = nil, @array : Array(String)? = nil)
    end
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
