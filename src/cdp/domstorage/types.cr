require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::DOMStorage
  alias SerializedStorageKey = String

  struct StorageId
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property security_origin : String?
    @[JSON::Field(emit_null: false)]
    property storage_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? is_local_storage : Bool
  end

  # TODO: Implement type array for DOMStorage.Item
  alias Item = JSON::Any
end
