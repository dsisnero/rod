require "../cdp"
require "json"
require "time"

require "../storage/storage"

module Cdp::CacheStorage
  alias CacheId = String

  alias CachedResponseType = String
  CachedResponseTypeBasic          = "basic"
  CachedResponseTypeCors           = "cors"
  CachedResponseTypeDefault        = "default"
  CachedResponseTypeError          = "error"
  CachedResponseTypeOpaqueResponse = "opaqueResponse"
  CachedResponseTypeOpaqueRedirect = "opaqueRedirect"

  struct DataEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property request_url : String
    @[JSON::Field(emit_null: false)]
    property request_method : String
    @[JSON::Field(emit_null: false)]
    property request_headers : Array(Header)
    @[JSON::Field(emit_null: false)]
    property response_time : Float64
    @[JSON::Field(emit_null: false)]
    property response_status : Int64
    @[JSON::Field(emit_null: false)]
    property response_status_text : String
    @[JSON::Field(emit_null: false)]
    property response_type : CachedResponseType
    @[JSON::Field(emit_null: false)]
    property response_headers : Array(Header)
  end

  struct Cache
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cache_id : CacheId
    @[JSON::Field(emit_null: false)]
    property security_origin : String
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(emit_null: false)]
    property cache_name : String
  end

  struct Header
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  struct CachedResponse
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property body : String
  end
end
