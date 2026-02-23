
require "../cdp"
require "json"
require "time"

require "../network/network"
require "../target/target"
require "../page/page"
require "../browser/browser"

module Cdp::Storage
  alias SerializedStorageKey = String

  alias StorageType = String

  struct UsageForType
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property storage_type : StorageType
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

  alias InterestGroupAuctionEventType = String

  alias InterestGroupAuctionFetchType = String

  alias SharedStorageAccessScope = String

  alias SharedStorageAccessMethod = String

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
    property creation_time : Cdp::Network::TimeSinceEpoch
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
    property reporting_metadata : Array(SharedStorageReportingMetadata)
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
    property keep_alive : Bool?
    @[JSON::Field(emit_null: false)]
    property private_aggregation_config : SharedStoragePrivateAggregationConfig?
    @[JSON::Field(emit_null: false)]
    property serialized_data : String?
    @[JSON::Field(emit_null: false)]
    property urls_with_metadata : Array(SharedStorageUrlWithMetadata)?
    @[JSON::Field(emit_null: false)]
    property urn_uuid : String?
    @[JSON::Field(emit_null: false)]
    property key : String?
    @[JSON::Field(emit_null: false)]
    property value : String?
    @[JSON::Field(emit_null: false)]
    property ignore_if_present : Bool?
    @[JSON::Field(emit_null: false)]
    property worklet_ordinal : Int64?
    @[JSON::Field(emit_null: false)]
    property worklet_target_id : Cdp::Target::TargetID?
    @[JSON::Field(emit_null: false)]
    property with_lock : String?
    @[JSON::Field(emit_null: false)]
    property batch_update_id : String?
    @[JSON::Field(emit_null: false)]
    property batch_size : Int64?
  end

  alias StorageBucketsDurability = String

  struct StorageBucket
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property storage_key : SerializedStorageKey
    @[JSON::Field(emit_null: false)]
    property name : String?
  end

  struct StorageBucketInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property bucket : StorageBucket
    @[JSON::Field(emit_null: false)]
    property id : String
    @[JSON::Field(emit_null: false)]
    property expiration : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property quota : Float64
    @[JSON::Field(emit_null: false)]
    property persistent : Bool
    @[JSON::Field(emit_null: false)]
    property durability : StorageBucketsDurability
  end

  @[Experimental]
  alias AttributionReportingSourceType = String

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
    property filter_values : Array(AttributionReportingFilterDataEntry)
    @[JSON::Field(emit_null: false)]
    property lookback_window : Int64?
  end

  @[Experimental]
  struct AttributionReportingFilterPair
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property filters : Array(AttributionReportingFilterConfig)
    @[JSON::Field(emit_null: false)]
    property not_filters : Array(AttributionReportingFilterConfig)
  end

  @[Experimental]
  struct AttributionReportingAggregationKeysEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : UnsignedInt128AsBase16
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

  @[Experimental]
  struct AttributionReportingAggregatableDebugReportingData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key_piece : UnsignedInt128AsBase16
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
    property key_piece : UnsignedInt128AsBase16
    @[JSON::Field(emit_null: false)]
    property debug_data : Array(AttributionReportingAggregatableDebugReportingData)
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
    property time : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property expiry : Int64
    @[JSON::Field(emit_null: false)]
    property trigger_data : Array(Float64)
    @[JSON::Field(emit_null: false)]
    property event_report_windows : AttributionReportingEventReportWindows
    @[JSON::Field(emit_null: false)]
    property aggregatable_report_window : Int64
    @[JSON::Field(emit_null: false)]
    property type : AttributionReportingSourceType
    @[JSON::Field(emit_null: false)]
    property source_origin : String
    @[JSON::Field(emit_null: false)]
    property reporting_origin : String
    @[JSON::Field(emit_null: false)]
    property destination_sites : Array(String)
    @[JSON::Field(emit_null: false)]
    property event_id : UnsignedInt64AsBase10
    @[JSON::Field(emit_null: false)]
    property priority : SignedInt64AsBase10
    @[JSON::Field(emit_null: false)]
    property filter_data : Array(AttributionReportingFilterDataEntry)
    @[JSON::Field(emit_null: false)]
    property aggregation_keys : Array(AttributionReportingAggregationKeysEntry)
    @[JSON::Field(emit_null: false)]
    property debug_key : UnsignedInt64AsBase10?
    @[JSON::Field(emit_null: false)]
    property trigger_data_matching : AttributionReportingTriggerDataMatching
    @[JSON::Field(emit_null: false)]
    property destination_limit_priority : SignedInt64AsBase10
    @[JSON::Field(emit_null: false)]
    property aggregatable_debug_reporting_config : AttributionReportingAggregatableDebugReportingConfig
    @[JSON::Field(emit_null: false)]
    property scopes_data : AttributionScopesData?
    @[JSON::Field(emit_null: false)]
    property max_event_level_reports : Int64
    @[JSON::Field(emit_null: false)]
    property named_budgets : Array(AttributionReportingNamedBudgetDef)
    @[JSON::Field(emit_null: false)]
    property debug_reporting : Bool
    @[JSON::Field(emit_null: false)]
    property event_level_epsilon : Float64
  end

  @[Experimental]
  alias AttributionReportingSourceRegistrationResult = String

  @[Experimental]
  alias AttributionReportingSourceRegistrationTimeConfig = String

  @[Experimental]
  struct AttributionReportingAggregatableValueDictEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : Float64
    @[JSON::Field(emit_null: false)]
    property filtering_id : UnsignedInt64AsBase10
  end

  @[Experimental]
  struct AttributionReportingAggregatableValueEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property values : Array(AttributionReportingAggregatableValueDictEntry)
    @[JSON::Field(emit_null: false)]
    property filters : AttributionReportingFilterPair
  end

  @[Experimental]
  struct AttributionReportingEventTriggerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data : UnsignedInt64AsBase10
    @[JSON::Field(emit_null: false)]
    property priority : SignedInt64AsBase10
    @[JSON::Field(emit_null: false)]
    property dedup_key : UnsignedInt64AsBase10?
    @[JSON::Field(emit_null: false)]
    property filters : AttributionReportingFilterPair
  end

  @[Experimental]
  struct AttributionReportingAggregatableTriggerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key_piece : UnsignedInt128AsBase16
    @[JSON::Field(emit_null: false)]
    property source_keys : Array(String)
    @[JSON::Field(emit_null: false)]
    property filters : AttributionReportingFilterPair
  end

  @[Experimental]
  struct AttributionReportingAggregatableDedupKey
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property dedup_key : UnsignedInt64AsBase10?
    @[JSON::Field(emit_null: false)]
    property filters : AttributionReportingFilterPair
  end

  @[Experimental]
  struct AttributionReportingNamedBudgetCandidate
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property filters : AttributionReportingFilterPair
  end

  @[Experimental]
  struct AttributionReportingTriggerRegistration
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property filters : AttributionReportingFilterPair
    @[JSON::Field(emit_null: false)]
    property debug_key : UnsignedInt64AsBase10?
    @[JSON::Field(emit_null: false)]
    property aggregatable_dedup_keys : Array(AttributionReportingAggregatableDedupKey)
    @[JSON::Field(emit_null: false)]
    property event_trigger_data : Array(AttributionReportingEventTriggerData)
    @[JSON::Field(emit_null: false)]
    property aggregatable_trigger_data : Array(AttributionReportingAggregatableTriggerData)
    @[JSON::Field(emit_null: false)]
    property aggregatable_values : Array(AttributionReportingAggregatableValueEntry)
    @[JSON::Field(emit_null: false)]
    property aggregatable_filtering_id_max_bytes : Int64
    @[JSON::Field(emit_null: false)]
    property debug_reporting : Bool
    @[JSON::Field(emit_null: false)]
    property aggregation_coordinator_origin : String?
    @[JSON::Field(emit_null: false)]
    property source_registration_time_config : AttributionReportingSourceRegistrationTimeConfig
    @[JSON::Field(emit_null: false)]
    property trigger_context_id : String?
    @[JSON::Field(emit_null: false)]
    property aggregatable_debug_reporting_config : AttributionReportingAggregatableDebugReportingConfig
    @[JSON::Field(emit_null: false)]
    property scopes : Array(String)
    @[JSON::Field(emit_null: false)]
    property named_budgets : Array(AttributionReportingNamedBudgetCandidate)
  end

  @[Experimental]
  alias AttributionReportingEventLevelResult = String

  @[Experimental]
  alias AttributionReportingAggregatableResult = String

  @[Experimental]
  alias AttributionReportingReportResult = String

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
