
require "../cdp"
require "json"
require "time"

require "../storage/storage"

require "./types"

#
@[Experimental]
module Cdp::CacheStorage
  struct RequestCacheNamesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property caches : Array(Cache)

    def initialize(@caches : Array(Cache))
    end
  end

  struct RequestCachedResponseResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property response : CachedResponse

    def initialize(@response : CachedResponse)
    end
  end

  struct RequestEntriesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cache_data_entries : Array(DataEntry)
    @[JSON::Field(emit_null: false)]
    property return_count : Float64

    def initialize(@cache_data_entries : Array(DataEntry), @return_count : Float64)
    end
  end


  # Commands
  struct DeleteCache
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cache_id : CacheId

    def initialize(@cache_id : CacheId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CacheStorage.deleteCache"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DeleteEntry
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cache_id : CacheId
    @[JSON::Field(emit_null: false)]
    property request : String

    def initialize(@cache_id : CacheId, @request : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CacheStorage.deleteEntry"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RequestCacheNames
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property security_origin : String?
    @[JSON::Field(emit_null: false)]
    property storage_key : String?
    @[JSON::Field(emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CacheStorage.requestCacheNames"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestCacheNamesResult
      res = RequestCacheNamesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RequestCachedResponse
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cache_id : CacheId
    @[JSON::Field(emit_null: false)]
    property request_url : String
    @[JSON::Field(emit_null: false)]
    property request_headers : Array(Header)

    def initialize(@cache_id : CacheId, @request_url : String, @request_headers : Array(Header))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CacheStorage.requestCachedResponse"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestCachedResponseResult
      res = RequestCachedResponseResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RequestEntries
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cache_id : CacheId
    @[JSON::Field(emit_null: false)]
    property skip_count : Int64?
    @[JSON::Field(emit_null: false)]
    property page_size : Int64?
    @[JSON::Field(emit_null: false)]
    property path_filter : String?

    def initialize(@cache_id : CacheId, @skip_count : Int64?, @page_size : Int64?, @path_filter : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CacheStorage.requestEntries"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestEntriesResult
      res = RequestEntriesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

end
