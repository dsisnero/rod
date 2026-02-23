require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"

#
@[Experimental]
module Cdp::CacheStorage
  struct RequestCacheNamesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property caches : Array(Cdp::NodeType)

    def initialize(@caches : Array(Cdp::NodeType))
    end
  end

  struct RequestCachedResponseResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType

    def initialize(@response : Cdp::NodeType)
    end
  end

  struct RequestEntriesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cache_data_entries : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property return_count : Float64

    def initialize(@cache_data_entries : Array(Cdp::NodeType), @return_count : Float64)
    end
  end

  # Commands
  struct DeleteCache
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cache_id : Cdp::NodeType

    def initialize(@cache_id : Cdp::NodeType)
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
    property cache_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : String

    def initialize(@cache_id : Cdp::NodeType, @request : String)
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
    property storage_bucket : Cdp::NodeType?

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::NodeType?)
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
    property cache_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request_url : String
    @[JSON::Field(emit_null: false)]
    property request_headers : Array(Cdp::NodeType)

    def initialize(@cache_id : Cdp::NodeType, @request_url : String, @request_headers : Array(Cdp::NodeType))
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
    property cache_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property skip_count : Int64?
    @[JSON::Field(emit_null: false)]
    property page_size : Int64?
    @[JSON::Field(emit_null: false)]
    property path_filter : String?

    def initialize(@cache_id : Cdp::NodeType, @skip_count : Int64?, @page_size : Int64?, @path_filter : String?)
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
