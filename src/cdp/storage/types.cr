require "../cdp"
require "json"
require "time"

require "../dom/dom"

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
  StorageTypeInterestGroups = "interest_groups"
  StorageTypeSharedStorage  = "shared_storage"
  StorageTypeStorageBuckets = "storage_buckets"
  StorageTypeAll            = "all"
  StorageTypeOther          = "other"

  struct UsageForType
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property storage_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property usage : Float64
  end

  @[Experimental]
  struct TrustTokens
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property issuer_origin : String
    @[JSON::Field(emit_null: false)]
    property count : Float64
  end

  alias InterestGroupAuctionId = String

  alias InterestGroupAccessType = String
  InterestGroupAccessTypeJoin                  = "join"
  InterestGroupAccessTypeLeave                 = "leave"
  InterestGroupAccessTypeUpdate                = "update"
  InterestGroupAccessTypeLoaded                = "loaded"
  InterestGroupAccessTypeBid                   = "bid"
  InterestGroupAccessTypeWin                   = "win"
  InterestGroupAccessTypeAdditionalBid         = "additionalBid"
  InterestGroupAccessTypeAdditionalBidWin      = "additionalBidWin"
  InterestGroupAccessTypeTopLevelBid           = "topLevelBid"
  InterestGroupAccessTypeTopLevelAdditionalBid = "topLevelAdditionalBid"
  InterestGroupAccessTypeClear                 = "clear"

  alias InterestGroupAuctionEventType = String
  InterestGroupAuctionEventTypeStarted        = "started"
  InterestGroupAuctionEventTypeConfigResolved = "configResolved"

  alias InterestGroupAuctionFetchType = String
  InterestGroupAuctionFetchTypeBidderJs             = "bidderJs"
  InterestGroupAuctionFetchTypeBidderWasm           = "bidderWasm"
  InterestGroupAuctionFetchTypeSellerJs             = "sellerJs"
  InterestGroupAuctionFetchTypeBidderTrustedSignals = "bidderTrustedSignals"
  InterestGroupAuctionFetchTypeSellerTrustedSignals = "sellerTrustedSignals"

  alias SharedStorageAccessScope = String
  SharedStorageAccessScopeWindow                   = "window"
  SharedStorageAccessScopeSharedStorageWorklet     = "sharedStorageWorklet"
  SharedStorageAccessScopeProtectedAudienceWorklet = "protectedAudienceWorklet"
  SharedStorageAccessScopeHeader                   = "header"

  alias SharedStorageAccessMethod = String
  SharedStorageAccessMethodAddModule       = "addModule"
  SharedStorageAccessMethodCreateWorklet   = "createWorklet"
  SharedStorageAccessMethodSelectURL       = "selectURL"
  SharedStorageAccessMethodRun             = "run"
  SharedStorageAccessMethodBatchUpdate     = "batchUpdate"
  SharedStorageAccessMethodSet             = "set"
  SharedStorageAccessMethodAppend          = "append"
  SharedStorageAccessMethodDelete          = "delete"
  SharedStorageAccessMethodClear           = "clear"
  SharedStorageAccessMethodGet             = "get"
  SharedStorageAccessMethodKeys            = "keys"
  SharedStorageAccessMethodValues          = "values"
  SharedStorageAccessMethodEntries         = "entries"
  SharedStorageAccessMethodLength          = "length"
  SharedStorageAccessMethodRemainingBudget = "remainingBudget"

  struct SharedStorageEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  struct SharedStorageMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property creation_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property length : Int64
    @[JSON::Field(emit_null: false)]
    property remaining_budget : Float64
    @[JSON::Field(emit_null: false)]
    property bytes_used : Int64
  end

  struct SharedStoragePrivateAggregationConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property aggregation_coordinator_origin : String?
    @[JSON::Field(emit_null: false)]
    property context_id : String?
    @[JSON::Field(emit_null: false)]
    property filtering_id_max_bytes : Int64
    @[JSON::Field(emit_null: false)]
    property max_contributions : Int64?
  end

  struct SharedStorageReportingMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property event_type : String
    @[JSON::Field(emit_null: false)]
    property reporting_url : String
  end

  struct SharedStorageUrlWithMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property reporting_metadata : Array(Cdp::NodeType)
  end

  struct SharedStorageAccessParams
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_source_url : String?
    @[JSON::Field(emit_null: false)]
    property data_origin : String?
    @[JSON::Field(emit_null: false)]
    property operation_name : String?
    @[JSON::Field(emit_null: false)]
    property operation_id : String?
    @[JSON::Field(emit_null: false)]
    property? keep_alive : Bool?
    @[JSON::Field(emit_null: false)]
    property private_aggregation_config : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property serialized_data : String?
    @[JSON::Field(emit_null: false)]
    property urls_with_metadata : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property urn_uuid : String?
    @[JSON::Field(emit_null: false)]
    property key : String?
    @[JSON::Field(emit_null: false)]
    property value : String?
    @[JSON::Field(emit_null: false)]
    property? ignore_if_present : Bool?
    @[JSON::Field(emit_null: false)]
    property worklet_ordinal : Int64?
    @[JSON::Field(emit_null: false)]
    property worklet_target_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property with_lock : String?
    @[JSON::Field(emit_null: false)]
    property batch_update_id : String?
    @[JSON::Field(emit_null: false)]
    property batch_size : Int64?
  end

  alias StorageBucketsDurability = String
  StorageBucketsDurabilityRelaxed = "relaxed"
  StorageBucketsDurabilityStrict  = "strict"

  struct StorageBucket
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property storage_key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String?
  end

  struct StorageBucketInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property bucket : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property expiration : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property quota : Float64
    @[JSON::Field(emit_null: false)]
    property? persistent : Bool
    @[JSON::Field(emit_null: false)]
    property durability : Cdp::NodeType
  end

  @[Experimental]
  alias AttributionReportingSourceType = String
  AttributionReportingSourceTypeNavigation = "navigation"
  AttributionReportingSourceTypeEvent      = "event"

  @[Experimental]
  alias UnsignedInt64AsBase10 = String

  @[Experimental]
  alias UnsignedInt128AsBase16 = String

  @[Experimental]
  alias SignedInt64AsBase10 = String

  @[Experimental]
  struct AttributionReportingFilterDataEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property values : Array(String)
  end

  @[Experimental]
  struct AttributionReportingFilterConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property filter_values : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property lookback_window : Int64?
  end

  @[Experimental]
  struct AttributionReportingFilterPair
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property filters : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property not_filters : Array(Cdp::NodeType)
  end

  @[Experimental]
  struct AttributionReportingAggregationKeysEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingEventReportWindows
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property start : Int64
    @[JSON::Field(emit_null: false)]
    property ends : Array(Int64)
  end

  @[Experimental]
  alias AttributionReportingTriggerDataMatching = String
  AttributionReportingTriggerDataMatchingExact   = "exact"
  AttributionReportingTriggerDataMatchingModulus = "modulus"

  @[Experimental]
  struct AttributionReportingAggregatableDebugReportingData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key_piece : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property value : Float64
    @[JSON::Field(emit_null: false)]
    property types : Array(String)
  end

  @[Experimental]
  struct AttributionReportingAggregatableDebugReportingConfig
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property budget : Float64?
    @[JSON::Field(emit_null: false)]
    property key_piece : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property debug_data : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property aggregation_coordinator_origin : String?
  end

  @[Experimental]
  struct AttributionScopesData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property values : Array(String)
    @[JSON::Field(emit_null: false)]
    property limit : Float64
    @[JSON::Field(emit_null: false)]
    property max_event_states : Float64
  end

  @[Experimental]
  struct AttributionReportingNamedBudgetDef
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property budget : Int64
  end

  @[Experimental]
  struct AttributionReportingSourceRegistration
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property expiry : Int64
    @[JSON::Field(emit_null: false)]
    property trigger_data : Array(Float64)
    @[JSON::Field(emit_null: false)]
    property event_report_windows : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property aggregatable_report_window : Int64
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_origin : String
    @[JSON::Field(emit_null: false)]
    property reporting_origin : String
    @[JSON::Field(emit_null: false)]
    property destination_sites : Array(String)
    @[JSON::Field(emit_null: false)]
    property event_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property priority : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property filter_data : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property aggregation_keys : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property debug_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property trigger_data_matching : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property destination_limit_priority : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property aggregatable_debug_reporting_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property scopes_data : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property max_event_level_reports : Int64
    @[JSON::Field(emit_null: false)]
    property named_budgets : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property? debug_reporting : Bool
    @[JSON::Field(emit_null: false)]
    property event_level_epsilon : Float64
  end

  @[Experimental]
  alias AttributionReportingSourceRegistrationResult = String
  AttributionReportingSourceRegistrationResultSuccess                                = "success"
  AttributionReportingSourceRegistrationResultInternalError                          = "internalError"
  AttributionReportingSourceRegistrationResultInsufficientSourceCapacity             = "insufficientSourceCapacity"
  AttributionReportingSourceRegistrationResultInsufficientUniqueDestinationCapacity  = "insufficientUniqueDestinationCapacity"
  AttributionReportingSourceRegistrationResultExcessiveReportingOrigins              = "excessiveReportingOrigins"
  AttributionReportingSourceRegistrationResultProhibitedByBrowserPolicy              = "prohibitedByBrowserPolicy"
  AttributionReportingSourceRegistrationResultSuccessNoised                          = "successNoised"
  AttributionReportingSourceRegistrationResultDestinationReportingLimitReached       = "destinationReportingLimitReached"
  AttributionReportingSourceRegistrationResultDestinationGlobalLimitReached          = "destinationGlobalLimitReached"
  AttributionReportingSourceRegistrationResultDestinationBothLimitsReached           = "destinationBothLimitsReached"
  AttributionReportingSourceRegistrationResultReportingOriginsPerSiteLimitReached    = "reportingOriginsPerSiteLimitReached"
  AttributionReportingSourceRegistrationResultExceedsMaxChannelCapacity              = "exceedsMaxChannelCapacity"
  AttributionReportingSourceRegistrationResultExceedsMaxScopesChannelCapacity        = "exceedsMaxScopesChannelCapacity"
  AttributionReportingSourceRegistrationResultExceedsMaxTriggerStateCardinality      = "exceedsMaxTriggerStateCardinality"
  AttributionReportingSourceRegistrationResultExceedsMaxEventStatesLimit             = "exceedsMaxEventStatesLimit"
  AttributionReportingSourceRegistrationResultDestinationPerDayReportingLimitReached = "destinationPerDayReportingLimitReached"

  @[Experimental]
  alias AttributionReportingSourceRegistrationTimeConfig = String
  AttributionReportingSourceRegistrationTimeConfigInclude = "include"
  AttributionReportingSourceRegistrationTimeConfigExclude = "exclude"

  @[Experimental]
  struct AttributionReportingAggregatableValueDictEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : Float64
    @[JSON::Field(emit_null: false)]
    property filtering_id : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingAggregatableValueEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property values : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property filters : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingEventTriggerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property priority : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property dedup_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property filters : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingAggregatableTriggerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key_piece : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_keys : Array(String)
    @[JSON::Field(emit_null: false)]
    property filters : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingAggregatableDedupKey
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property dedup_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property filters : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingNamedBudgetCandidate
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property filters : Cdp::NodeType
  end

  @[Experimental]
  struct AttributionReportingTriggerRegistration
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property filters : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property debug_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property aggregatable_dedup_keys : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property event_trigger_data : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property aggregatable_trigger_data : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property aggregatable_values : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property aggregatable_filtering_id_max_bytes : Int64
    @[JSON::Field(emit_null: false)]
    property? debug_reporting : Bool
    @[JSON::Field(emit_null: false)]
    property aggregation_coordinator_origin : String?
    @[JSON::Field(emit_null: false)]
    property source_registration_time_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property trigger_context_id : String?
    @[JSON::Field(emit_null: false)]
    property aggregatable_debug_reporting_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property scopes : Array(String)
    @[JSON::Field(emit_null: false)]
    property named_budgets : Array(Cdp::NodeType)
  end

  @[Experimental]
  alias AttributionReportingEventLevelResult = String
  AttributionReportingEventLevelResultSuccess                             = "success"
  AttributionReportingEventLevelResultSuccessDroppedLowerPriority         = "successDroppedLowerPriority"
  AttributionReportingEventLevelResultInternalError                       = "internalError"
  AttributionReportingEventLevelResultNoCapacityForAttributionDestination = "noCapacityForAttributionDestination"
  AttributionReportingEventLevelResultNoMatchingSources                   = "noMatchingSources"
  AttributionReportingEventLevelResultDeduplicated                        = "deduplicated"
  AttributionReportingEventLevelResultExcessiveAttributions               = "excessiveAttributions"
  AttributionReportingEventLevelResultPriorityTooLow                      = "priorityTooLow"
  AttributionReportingEventLevelResultNeverAttributedSource               = "neverAttributedSource"
  AttributionReportingEventLevelResultExcessiveReportingOrigins           = "excessiveReportingOrigins"
  AttributionReportingEventLevelResultNoMatchingSourceFilterData          = "noMatchingSourceFilterData"
  AttributionReportingEventLevelResultProhibitedByBrowserPolicy           = "prohibitedByBrowserPolicy"
  AttributionReportingEventLevelResultNoMatchingConfigurations            = "noMatchingConfigurations"
  AttributionReportingEventLevelResultExcessiveReports                    = "excessiveReports"
  AttributionReportingEventLevelResultFalselyAttributedSource             = "falselyAttributedSource"
  AttributionReportingEventLevelResultReportWindowPassed                  = "reportWindowPassed"
  AttributionReportingEventLevelResultNotRegistered                       = "notRegistered"
  AttributionReportingEventLevelResultReportWindowNotStarted              = "reportWindowNotStarted"
  AttributionReportingEventLevelResultNoMatchingTriggerData               = "noMatchingTriggerData"

  @[Experimental]
  alias AttributionReportingAggregatableResult = String
  AttributionReportingAggregatableResultSuccess                             = "success"
  AttributionReportingAggregatableResultInternalError                       = "internalError"
  AttributionReportingAggregatableResultNoCapacityForAttributionDestination = "noCapacityForAttributionDestination"
  AttributionReportingAggregatableResultNoMatchingSources                   = "noMatchingSources"
  AttributionReportingAggregatableResultExcessiveAttributions               = "excessiveAttributions"
  AttributionReportingAggregatableResultExcessiveReportingOrigins           = "excessiveReportingOrigins"
  AttributionReportingAggregatableResultNoHistograms                        = "noHistograms"
  AttributionReportingAggregatableResultInsufficientBudget                  = "insufficientBudget"
  AttributionReportingAggregatableResultInsufficientNamedBudget             = "insufficientNamedBudget"
  AttributionReportingAggregatableResultNoMatchingSourceFilterData          = "noMatchingSourceFilterData"
  AttributionReportingAggregatableResultNotRegistered                       = "notRegistered"
  AttributionReportingAggregatableResultProhibitedByBrowserPolicy           = "prohibitedByBrowserPolicy"
  AttributionReportingAggregatableResultDeduplicated                        = "deduplicated"
  AttributionReportingAggregatableResultReportWindowPassed                  = "reportWindowPassed"
  AttributionReportingAggregatableResultExcessiveReports                    = "excessiveReports"

  @[Experimental]
  alias AttributionReportingReportResult = String
  AttributionReportingReportResultSent             = "sent"
  AttributionReportingReportResultProhibited       = "prohibited"
  AttributionReportingReportResultFailedToAssemble = "failedToAssemble"
  AttributionReportingReportResultExpired          = "expired"

  @[Experimental]
  struct RelatedWebsiteSet
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property primary_sites : Array(String)
    @[JSON::Field(emit_null: false)]
    property associated_sites : Array(String)
    @[JSON::Field(emit_null: false)]
    property service_sites : Array(String)
  end
end
