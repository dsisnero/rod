require "../cdp"
require "json"
require "time"

require "../network/network"
require "../target/target"
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
    @[JSON::Field(emit_null: false)]
    property storage_key : SerializedStorageKey

    def initialize(@storage_key : SerializedStorageKey)
    end
  end

  struct GetCookiesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cookies : Array(Cdp::Network::Cookie)

    def initialize(@cookies : Array(Cdp::Network::Cookie))
    end
  end

  struct GetUsageAndQuotaResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property usage : Float64
    @[JSON::Field(emit_null: false)]
    property quota : Float64
    @[JSON::Field(emit_null: false)]
    property? override_active : Bool
    @[JSON::Field(emit_null: false)]
    property usage_breakdown : Array(UsageForType)

    def initialize(@usage : Float64, @quota : Float64, @override_active : Bool, @usage_breakdown : Array(UsageForType))
    end
  end

  @[Experimental]
  struct GetTrustTokensResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property tokens : Array(TrustTokens)

    def initialize(@tokens : Array(TrustTokens))
    end
  end

  @[Experimental]
  struct ClearTrustTokensResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? did_delete_tokens : Bool

    def initialize(@did_delete_tokens : Bool)
    end
  end

  @[Experimental]
  struct GetInterestGroupDetailsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property details : JSON::Any

    def initialize(@details : JSON::Any)
    end
  end

  @[Experimental]
  struct GetSharedStorageMetadataResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property metadata : SharedStorageMetadata

    def initialize(@metadata : SharedStorageMetadata)
    end
  end

  @[Experimental]
  struct GetSharedStorageEntriesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property entries : Array(SharedStorageEntry)

    def initialize(@entries : Array(SharedStorageEntry))
    end
  end

  @[Experimental]
  struct RunBounceTrackingMitigationsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property deleted_sites : Array(String)

    def initialize(@deleted_sites : Array(String))
    end
  end

  @[Experimental]
  struct SendPendingAttributionReportsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property num_sent : Int64

    def initialize(@num_sent : Int64)
    end
  end

  @[Experimental]
  struct GetRelatedWebsiteSetsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property sets : Array(RelatedWebsiteSet)

    def initialize(@sets : Array(RelatedWebsiteSet))
    end
  end

  @[Experimental]
  struct GetAffectedUrlsForThirdPartyCookieMetadataResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property matched_urls : Array(String)

    def initialize(@matched_urls : Array(String))
    end
  end

  # Commands
  @[Experimental]
  struct GetStorageKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?

    def initialize(@frame_id : Cdp::Page::FrameId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getStorageKey"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetStorageKeyResult
      res = GetStorageKeyResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ClearDataForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@browser_context_id : Cdp::Browser::BrowserContextID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getCookies"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCookiesResult
      res = GetCookiesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetCookies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property cookies : Array(Cdp::Network::CookieParam)
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@cookies : Array(Cdp::Network::CookieParam), @browser_context_id : Cdp::Browser::BrowserContextID?)
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
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@browser_context_id : Cdp::Browser::BrowserContextID?)
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
    @[JSON::Field(emit_null: false)]
    property origin : String

    def initialize(@origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getUsageAndQuota"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetUsageAndQuotaResult
      res = GetUsageAndQuotaResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct OverrideQuotaForOrigin
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property quota_size : Float64?

    def initialize(@origin : String, @quota_size : Float64?)
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
      res = GetTrustTokensResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct ClearTrustTokens
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property issuer_origin : String

    def initialize(@issuer_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearTrustTokens"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ClearTrustTokensResult
      res = ClearTrustTokensResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetInterestGroupDetails
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String
    @[JSON::Field(emit_null: false)]
    property name : String

    def initialize(@owner_origin : String, @name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getInterestGroupDetails"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetInterestGroupDetailsResult
      res = GetInterestGroupDetailsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetInterestGroupTracking
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setInterestGroupTracking"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetInterestGroupAuctionTracking
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setInterestGroupAuctionTracking"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetSharedStorageMetadata
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String

    def initialize(@owner_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getSharedStorageMetadata"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSharedStorageMetadataResult
      res = GetSharedStorageMetadataResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetSharedStorageEntries
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String

    def initialize(@owner_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getSharedStorageEntries"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSharedStorageEntriesResult
      res = GetSharedStorageEntriesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetSharedStorageEntry
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property? ignore_if_present : Bool?

    def initialize(@owner_origin : String, @key : String, @value : String, @ignore_if_present : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setSharedStorageEntry"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct DeleteSharedStorageEntry
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String
    @[JSON::Field(emit_null: false)]
    property key : String

    def initialize(@owner_origin : String, @key : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.deleteSharedStorageEntry"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ClearSharedStorageEntries
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String

    def initialize(@owner_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.clearSharedStorageEntries"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ResetSharedStorageBudget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner_origin : String

    def initialize(@owner_origin : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.resetSharedStorageBudget"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetSharedStorageTracking
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setSharedStorageTracking"
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
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
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
      res = RunBounceTrackingMitigationsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetAttributionReportingLocalTestingMode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setAttributionReportingLocalTestingMode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetAttributionReportingTracking
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enable : Bool

    def initialize(@enable : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setAttributionReportingTracking"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SendPendingAttributionReports
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.sendPendingAttributionReports"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SendPendingAttributionReportsResult
      res = SendPendingAttributionReportsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetRelatedWebsiteSets
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getRelatedWebsiteSets"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetRelatedWebsiteSetsResult
      res = GetRelatedWebsiteSetsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAffectedUrlsForThirdPartyCookieMetadata
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property first_party_url : String
    @[JSON::Field(emit_null: false)]
    property third_party_urls : Array(String)

    def initialize(@first_party_url : String, @third_party_urls : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.getAffectedUrlsForThirdPartyCookieMetadata"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAffectedUrlsForThirdPartyCookieMetadataResult
      res = GetAffectedUrlsForThirdPartyCookieMetadataResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetProtectedAudienceKAnonymity
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property owner : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property hashes : Array(String)

    def initialize(@owner : String, @name : String, @hashes : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Storage.setProtectedAudienceKAnonymity"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
