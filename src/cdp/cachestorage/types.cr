require "../cachestorage/cachestorage"
require "json"
require "time"
require "../storage/storage"

module Cdp::CacheStorage
  alias CacheId = String

  alias CachedResponseType = String

  struct DataEntry
    include JSON::Serializable

    property request_url : String
    property request_method : String
    property request_headers : Array(Header)
    property response_time : Float64
    property response_status : Int64
    property response_status_text : String
    property response_type : CachedResponseType
    property response_headers : Array(Header)
  end

  struct Cache
    include JSON::Serializable

    property cache_id : CacheId
    property security_origin : String
    property storage_key : String
    @[JSON::Field(emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    property cache_name : String
  end

  struct Header
    include JSON::Serializable

    property name : String
    property value : String
  end

  struct CachedResponse
    include JSON::Serializable

    property body : String
  end
end
