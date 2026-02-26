require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../storage/storage"

require "./types"

#
@[Experimental]
module Cdp::IndexedDB
  struct RequestDataResult
    include JSON::Serializable
    @[JSON::Field(key: "objectStoreDataEntries", emit_null: false)]
    property object_store_data_entries : Array(DataEntry)
    @[JSON::Field(key: "hasMore", emit_null: false)]
    property? has_more : Bool

    def initialize(@object_store_data_entries : Array(DataEntry), @has_more : Bool)
    end
  end

  struct GetMetadataResult
    include JSON::Serializable
    @[JSON::Field(key: "entriesCount", emit_null: false)]
    property entries_count : Float64
    @[JSON::Field(key: "keyGeneratorValue", emit_null: false)]
    property key_generator_value : Float64

    def initialize(@entries_count : Float64, @key_generator_value : Float64)
    end
  end

  struct RequestDatabaseResult
    include JSON::Serializable
    @[JSON::Field(key: "databaseWithObjectStores", emit_null: false)]
    property database_with_object_stores : DatabaseWithObjectStores

    def initialize(@database_with_object_stores : DatabaseWithObjectStores)
    end
  end

  struct RequestDatabaseNamesResult
    include JSON::Serializable
    @[JSON::Field(key: "databaseNames", emit_null: false)]
    property database_names : Array(String)

    def initialize(@database_names : Array(String))
    end
  end

  # Commands
  struct ClearObjectStore
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String
    @[JSON::Field(key: "objectStoreName", emit_null: false)]
    property object_store_name : String

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?, @database_name : String, @object_store_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.clearObjectStore"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DeleteDatabase
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?, @database_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.deleteDatabase"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DeleteObjectStoreEntries
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String
    @[JSON::Field(key: "objectStoreName", emit_null: false)]
    property object_store_name : String
    @[JSON::Field(key: "keyRange", emit_null: false)]
    property key_range : KeyRange

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?, @database_name : String, @object_store_name : String, @key_range : KeyRange)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.deleteObjectStoreEntries"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RequestData
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String
    @[JSON::Field(key: "objectStoreName", emit_null: false)]
    property object_store_name : String
    @[JSON::Field(key: "indexName", emit_null: false)]
    property index_name : String?
    @[JSON::Field(key: "skipCount", emit_null: false)]
    property skip_count : Int64
    @[JSON::Field(key: "pageSize", emit_null: false)]
    property page_size : Int64
    @[JSON::Field(key: "keyRange", emit_null: false)]
    property key_range : KeyRange?

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?, @database_name : String, @object_store_name : String, @index_name : String?, @skip_count : Int64, @page_size : Int64, @key_range : KeyRange?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.requestData"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestDataResult
      res = RequestDataResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetMetadata
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String
    @[JSON::Field(key: "objectStoreName", emit_null: false)]
    property object_store_name : String

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?, @database_name : String, @object_store_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.getMetadata"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetMetadataResult
      res = GetMetadataResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RequestDatabase
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?, @database_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.requestDatabase"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestDatabaseResult
      res = RequestDatabaseResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct RequestDatabaseNames
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "securityOrigin", emit_null: false)]
    property security_origin : String?
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String?
    @[JSON::Field(key: "storageBucket", emit_null: false)]
    property storage_bucket : Cdp::Storage::StorageBucket?

    def initialize(@security_origin : String?, @storage_key : String?, @storage_bucket : Cdp::Storage::StorageBucket?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "IndexedDB.requestDatabaseNames"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestDatabaseNamesResult
      res = RequestDatabaseNamesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
