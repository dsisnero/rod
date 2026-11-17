require "../cdp"
require "json"
require "base64"
require "time"

module Cdp::Extensions
  alias StorageArea = String
  StorageAreaSession = "session"
  StorageAreaLocal   = "local"
  StorageAreaSync    = "sync"
  StorageAreaManaged = "managed"

  struct ExtensionInfo
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "version", emit_null: false)]
    property version : String
    @[JSON::Field(key: "path", emit_null: false)]
    property path : String
    @[JSON::Field(key: "enabled", emit_null: false)]
    property? enabled : Bool

    def initialize(@id : String, @name : String, @version : String, @path : String, @enabled : Bool)
    end
  end
end
