require "../cdp"
require "json"
require "time"

require "../network/network"
require "../page/page"
require "../browser/browser"

module Cdp::Storage
  struct CacheStorageContentUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
    @[JSON::Field(key: "bucketId", emit_null: false)]
    property bucket_id : String
    @[JSON::Field(key: "cacheName", emit_null: false)]
    property cache_name : String

    def initialize(@origin : String, @storage_key : String, @bucket_id : String, @cache_name : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.cacheStorageContentUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.cacheStorageContentUpdated"
    end
  end

  struct CacheStorageListUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
    @[JSON::Field(key: "bucketId", emit_null: false)]
    property bucket_id : String

    def initialize(@origin : String, @storage_key : String, @bucket_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.cacheStorageListUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.cacheStorageListUpdated"
    end
  end

  struct IndexedDBContentUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
    @[JSON::Field(key: "bucketId", emit_null: false)]
    property bucket_id : String
    @[JSON::Field(key: "databaseName", emit_null: false)]
    property database_name : String
    @[JSON::Field(key: "objectStoreName", emit_null: false)]
    property object_store_name : String

    def initialize(@origin : String, @storage_key : String, @bucket_id : String, @database_name : String, @object_store_name : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.indexedDBContentUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.indexedDBContentUpdated"
    end
  end

  struct IndexedDBListUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
    @[JSON::Field(key: "bucketId", emit_null: false)]
    property bucket_id : String

    def initialize(@origin : String, @storage_key : String, @bucket_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.indexedDBListUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.indexedDBListUpdated"
    end
  end

  struct StorageBucketCreatedOrUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "bucketInfo", emit_null: false)]
    property bucket_info : StorageBucketInfo

    def initialize(@bucket_info : StorageBucketInfo)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.storageBucketCreatedOrUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.storageBucketCreatedOrUpdated"
    end
  end

  struct StorageBucketDeletedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "bucketId", emit_null: false)]
    property bucket_id : String

    def initialize(@bucket_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.storageBucketDeleted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.storageBucketDeleted"
    end
  end

  @[Experimental]
  struct PrivateVerificationTokensUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.privateVerificationTokensUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.privateVerificationTokensUpdated"
    end
  end
end
