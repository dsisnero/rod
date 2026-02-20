require "../domstorage/domstorage"
require "json"
require "time"

module Cdp::DOMStorage
  alias SerializedStorageKey = String

  struct StorageId
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property security_origin : String?
    @[JSON::Field(emit_null: false)]
    property storage_key : SerializedStorageKey?
    property is_local_storage : Bool
  end

  # TODO: Implement type array for DOMStorage.Item
  alias Item = JSON::Any
end
