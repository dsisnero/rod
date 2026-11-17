require "../cdp"
require "json"
require "time"

require "../network/network"
require "../page/page"
require "../browser/browser"

require "./types"
require "./events"

#
@[Experimental]
module Cdp::Storage
  @[Experimental]
  struct GetStorageKeyResult
    include JSON::Serializable
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : SerializedStorageKey

    def initialize(@storage_key : SerializedStorageKey)
    end
  end

  struct GetCookiesResult
    include JSON::Serializable
    @[JSON::Field(key: "cookies", emit_null: false)]
    property cookies : Array(Cdp::Network::Cookie)

    def initialize(@cookies : Array(Cdp::Network::Cookie))
    end
  end

  struct GetUsageAndQuotaResult
    include JSON::Serializable
    @[JSON::Field(key: "usage", emit_null: false)]
    property usage : Float64
    @[JSON::Field(key: "quota", emit_null: false)]
    property quota : Float64
    @[JSON::Field(key: "overrideActive", emit_null: false)]
    property? override_active : Bool
    @[JSON::Field(key: "usageBreakdown", emit_null: false)]
    property usage_breakdown : Array(UsageForType)

    def initialize(@usage : Float64, @quota : Float64, @override_active : Bool, @usage_breakdown : Array(UsageForType))
    end
  end

  @[Experimental]
  struct GetTrustTokensResult
    include JSON::Serializable
    @[JSON::Field(key: "tokens", emit_null: false)]
    property tokens : Array(TrustTokens)

    def initialize(@tokens : Array(TrustTokens))
    end
  end

  @[Experimental]
  struct ClearTrustTokensResult
    include JSON::Serializable
    @[JSON::Field(key: "didDeleteTokens", emit_null: false)]
    property? did_delete_tokens : Bool

    def initialize(@did_delete_tokens : Bool)
    end
  end

  @[Experimental]
  struct GetPrivateVerificationTokensResult
    include JSON::Serializable
    @[JSON::Field(key: "tokens", emit_null: false)]
    property tokens : Array(PrivateVerificationToken)

    def initialize(@tokens : Array(PrivateVerificationToken))
    end
  end

  @[Experimental]
  struct GetPrivateVerificationTokensIssuerConfigsResult
    include JSON::Serializable
    @[JSON::Field(key: "configs", emit_null: false)]
    property configs : Array(PrivateVerificationTokensIssuerConfig)

    def initialize(@configs : Array(PrivateVerificationTokensIssuerConfig))
    end
  end

  @[Experimental]
  struct RunBounceTrackingMitigationsResult
    include JSON::Serializable
    @[JSON::Field(key: "deletedSites", emit_null: false)]
    property deleted_sites : Array(String)

    def initialize(@deleted_sites : Array(String))
    end
  end

  # Commands
  @[Experimental]
  struct GetStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId?

    def initialize(@frame_id : Cdp::Page::FrameId? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getStorageKey"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetStorageKeyResult
      Cdp.call(proto_req, self, GetStorageKeyResult, c)
    end
  end

  struct ClearDataForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "storageTypes", emit_null: false)]
    property storage_types : String

    def initialize(@origin : String, @storage_types : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearDataForOrigin"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearDataForStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
    @[JSON::Field(key: "storageTypes", emit_null: false)]
    property storage_types : String

    def initialize(@storage_key : String, @storage_types : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearDataForStorageKey"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@browser_context_id : Cdp::Browser::BrowserContextID? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getCookies"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCookiesResult
      Cdp.call(proto_req, self, GetCookiesResult, c)
    end
  end

  struct SetCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "cookies", emit_null: false)]
    property cookies : Array(Cdp::Network::CookieParam)
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@cookies : Array(Cdp::Network::CookieParam), @browser_context_id : Cdp::Browser::BrowserContextID? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setCookies"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ClearCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@browser_context_id : Cdp::Browser::BrowserContextID? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearCookies"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetUsageAndQuota
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getUsageAndQuota"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetUsageAndQuotaResult
      Cdp.call(proto_req, self, GetUsageAndQuotaResult, c)
    end
  end

  @[Experimental]
  struct OverrideQuotaForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "quotaSize", emit_null: false)]
    property quota_size : Float64?

    def initialize(@origin : String, @quota_size : Float64? = nil)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.overrideQuotaForOrigin"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct TrackCacheStorageForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.trackCacheStorageForOrigin"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct TrackCacheStorageForStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String

    def initialize(@storage_key : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.trackCacheStorageForStorageKey"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct TrackIndexedDBForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.trackIndexedDBForOrigin"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct TrackIndexedDBForStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String

    def initialize(@storage_key : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.trackIndexedDBForStorageKey"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct UntrackCacheStorageForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.untrackCacheStorageForOrigin"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct UntrackCacheStorageForStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String

    def initialize(@storage_key : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.untrackCacheStorageForStorageKey"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct UntrackIndexedDBForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.untrackIndexedDBForOrigin"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct UntrackIndexedDBForStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String

    def initialize(@storage_key : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.untrackIndexedDBForStorageKey"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetTrustTokens
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getTrustTokens"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetTrustTokensResult
      Cdp.call(proto_req, self, GetTrustTokensResult, c)
    end
  end

  @[Experimental]
  struct ClearTrustTokens
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "issuerOrigin", emit_null: false)]
    property issuer_origin : String

    def initialize(@issuer_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearTrustTokens"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ClearTrustTokensResult
      Cdp.call(proto_req, self, ClearTrustTokensResult, c)
    end
  end

  @[Experimental]
  struct GetPrivateVerificationTokens
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getPrivateVerificationTokens"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPrivateVerificationTokensResult
      Cdp.call(proto_req, self, GetPrivateVerificationTokensResult, c)
    end
  end

  @[Experimental]
  struct GetPrivateVerificationTokensIssuerConfigs
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getPrivateVerificationTokensIssuerConfigs"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPrivateVerificationTokensIssuerConfigsResult
      Cdp.call(proto_req, self, GetPrivateVerificationTokensIssuerConfigsResult, c)
    end
  end

  @[Experimental]
  struct ClearPrivateVerificationTokens
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "issuerOrigin", emit_null: false)]
    property issuer_origin : String

    def initialize(@issuer_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearPrivateVerificationTokens"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct DeletePrivateVerificationToken
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "tokenId", emit_null: false)]
    property token_id : String

    def initialize(@token_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.deletePrivateVerificationToken"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetPrivateVerificationTokensTracking
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "enable", emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setPrivateVerificationTokensTracking"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetStorageBucketTracking
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
    @[JSON::Field(key: "enable", emit_null: false)]
    property? enable : Bool

    def initialize(@storage_key : String, @enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setStorageBucketTracking"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct DeleteStorageBucket
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "bucket", emit_null: false)]
    property bucket : StorageBucket

    def initialize(@bucket : StorageBucket)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.deleteStorageBucket"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct RunBounceTrackingMitigations
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.runBounceTrackingMitigations"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RunBounceTrackingMitigationsResult
      Cdp.call(proto_req, self, RunBounceTrackingMitigationsResult, c)
    end
  end
end
