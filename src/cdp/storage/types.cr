require "../cdp"
require "json"
require "base64"
require "time"

require "../network/network"
require "../page/page"
require "../browser/browser"

module Cdp::Storage
  alias SerializedStorageKey = String

  alias StorageType = String
  StorageTypeCookies        = "cookies"
  StorageTypeFileSystems    = "file_systems"
  StorageTypeIndexeddb      = "indexeddb"
  StorageTypeLocalStorage   = "local_storage"
  StorageTypeShaderCache    = "shader_cache"
  StorageTypeWebsql         = "websql"
  StorageTypeServiceWorkers = "service_workers"
  StorageTypeCacheStorage   = "cache_storage"
  StorageTypeStorageBuckets = "storage_buckets"
  StorageTypeAll            = "all"
  StorageTypeOther          = "other"

  struct UsageForType
    include JSON::Serializable
    @[JSON::Field(key: "storageType", emit_null: false)]
    property storage_type : StorageType
    @[JSON::Field(key: "usage", emit_null: false)]
    property usage : Float64

    def initialize(@storage_type : StorageType, @usage : Float64)
    end
  end

  @[Experimental]
  struct TrustTokens
    include JSON::Serializable
    @[JSON::Field(key: "issuerOrigin", emit_null: false)]
    property issuer_origin : String
    @[JSON::Field(key: "count", emit_null: false)]
    property count : Float64

    def initialize(@issuer_origin : String, @count : Float64)
    end
  end

  @[Experimental]
  struct PrivateVerificationToken
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "issuerOrigin", emit_null: false)]
    property issuer_origin : String
    @[JSON::Field(key: "keyId", emit_null: false)]
    property key_id : Int64
    @[JSON::Field(key: "expiration", emit_null: false)]
    property expiration : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "creationTime", emit_null: false)]
    property creation_time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "version", emit_null: false)]
    property version : Int64
    @[JSON::Field(key: "token", emit_null: false)]
    property token : String

    def initialize(@id : String, @issuer_origin : String, @key_id : Int64, @expiration : Cdp::Network::TimeSinceEpoch, @creation_time : Cdp::Network::TimeSinceEpoch, @version : Int64, @token : String)
    end
  end

  @[Experimental]
  struct PrivateVerificationTokensIssuerConfig
    include JSON::Serializable
    @[JSON::Field(key: "issuerOrigin", emit_null: false)]
    property issuer_origin : String
    @[JSON::Field(key: "redeemerOrigins", emit_null: false)]
    property redeemer_origins : Array(String)

    def initialize(@issuer_origin : String, @redeemer_origins : Array(String))
    end
  end

  alias StorageBucketsDurability = String
  StorageBucketsDurabilityRelaxed = "relaxed"
  StorageBucketsDurabilityStrict  = "strict"

  struct StorageBucket
    include JSON::Serializable
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : SerializedStorageKey
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String?

    def initialize(@storage_key : SerializedStorageKey, @name : String? = nil)
    end
  end

  struct StorageBucketInfo
    include JSON::Serializable
    @[JSON::Field(key: "bucket", emit_null: false)]
    property bucket : StorageBucket
    @[JSON::Field(key: "id", emit_null: false)]
    property id : String
    @[JSON::Field(key: "expiration", emit_null: false)]
    property expiration : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "quota", emit_null: false)]
    property quota : Float64
    @[JSON::Field(key: "persistent", emit_null: false)]
    property? persistent : Bool
    @[JSON::Field(key: "durability", emit_null: false)]
    property durability : StorageBucketsDurability

    def initialize(@bucket : StorageBucket, @id : String, @expiration : Cdp::Network::TimeSinceEpoch, @quota : Float64, @persistent : Bool, @durability : StorageBucketsDurability)
    end
  end
end
