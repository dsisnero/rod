require "../cdp"
require "json"
require "time"

module Cdp::DOMStorage
  alias SerializedStorageKey = String

  struct StorageId
    include JSON::Serializable
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : SerializedStorageKey?
    @[JSON::Field(key: "isLocalStorage", emit_null: false)]
    property? is_local_storage : Bool
  end

  # TODO: Implement type array for DOMStorage.Item
  alias Item = JSON::Any
end
