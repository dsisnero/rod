require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Storage
  struct CacheStorageContentUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
    property bucket_id : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
    property bucket_id : String
    @[JSON::Field(emit_null: false)]
    property database_name : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property storage_key : String
    @[JSON::Field(emit_null: false)]
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

  struct InterestGroupAccessedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property access_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property owner_origin : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property component_seller_origin : String?
    @[JSON::Field(emit_null: false)]
    property bid : Float64?
    @[JSON::Field(emit_null: false)]
    property bid_currency : String?
    @[JSON::Field(emit_null: false)]
    property unique_auction_id : Cdp::NodeType?

    def initialize(@access_time : Cdp::NodeType, @type : Cdp::NodeType, @owner_origin : String, @name : String, @component_seller_origin : String?, @bid : Float64?, @bid_currency : String?, @unique_auction_id : Cdp::NodeType?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.interestGroupAccessed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.interestGroupAccessed"
    end
  end

  struct InterestGroupAuctionEventOccurredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property event_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property unique_auction_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property parent_auction_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property auction_config : JSON::Any?

    def initialize(@event_time : Cdp::NodeType, @type : Cdp::NodeType, @unique_auction_id : Cdp::NodeType, @parent_auction_id : Cdp::NodeType?, @auction_config : JSON::Any?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.interestGroupAuctionEventOccurred"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.interestGroupAuctionEventOccurred"
    end
  end

  struct InterestGroupAuctionNetworkRequestCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property auctions : Array(Cdp::NodeType)

    def initialize(@type : Cdp::NodeType, @request_id : Cdp::NodeType, @auctions : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.interestGroupAuctionNetworkRequestCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.interestGroupAuctionNetworkRequestCreated"
    end
  end

  struct SharedStorageAccessedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property access_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property scope : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property method : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property main_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property owner_origin : String
    @[JSON::Field(emit_null: false)]
    property owner_site : String
    @[JSON::Field(emit_null: false)]
    property params : Cdp::NodeType

    def initialize(@access_time : Cdp::NodeType, @scope : Cdp::NodeType, @method : Cdp::NodeType, @main_frame_id : Cdp::NodeType, @owner_origin : String, @owner_site : String, @params : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.sharedStorageAccessed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.sharedStorageAccessed"
    end
  end

  struct SharedStorageWorkletOperationExecutionFinishedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property finished_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property execution_time : Int64
    @[JSON::Field(emit_null: false)]
    property method : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property operation_id : String
    @[JSON::Field(emit_null: false)]
    property worklet_target_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property main_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property owner_origin : String

    def initialize(@finished_time : Cdp::NodeType, @execution_time : Int64, @method : Cdp::NodeType, @operation_id : String, @worklet_target_id : Cdp::NodeType, @main_frame_id : Cdp::NodeType, @owner_origin : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.sharedStorageWorkletOperationExecutionFinished"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.sharedStorageWorkletOperationExecutionFinished"
    end
  end

  struct StorageBucketCreatedOrUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property bucket_info : Cdp::NodeType

    def initialize(@bucket_info : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
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
  struct AttributionReportingSourceRegisteredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property registration : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property result : Cdp::NodeType

    def initialize(@registration : Cdp::NodeType, @result : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.attributionReportingSourceRegistered"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.attributionReportingSourceRegistered"
    end
  end

  @[Experimental]
  struct AttributionReportingTriggerRegisteredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property registration : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property event_level : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property aggregatable : Cdp::NodeType

    def initialize(@registration : Cdp::NodeType, @event_level : Cdp::NodeType, @aggregatable : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.attributionReportingTriggerRegistered"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.attributionReportingTriggerRegistered"
    end
  end

  @[Experimental]
  struct AttributionReportingReportSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property body : JSON::Any
    @[JSON::Field(emit_null: false)]
    property result : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property net_error : Int64?
    @[JSON::Field(emit_null: false)]
    property net_error_name : String?
    @[JSON::Field(emit_null: false)]
    property http_status_code : Int64?

    def initialize(@url : String, @body : JSON::Any, @result : Cdp::NodeType, @net_error : Int64?, @net_error_name : String?, @http_status_code : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.attributionReportingReportSent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.attributionReportingReportSent"
    end
  end

  @[Experimental]
  struct AttributionReportingVerboseDebugReportSentEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property body : Array(JSON::Any)?
    @[JSON::Field(emit_null: false)]
    property net_error : Int64?
    @[JSON::Field(emit_null: false)]
    property net_error_name : String?
    @[JSON::Field(emit_null: false)]
    property http_status_code : Int64?

    def initialize(@url : String, @body : Array(JSON::Any)?, @net_error : Int64?, @net_error_name : String?, @http_status_code : Int64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Storage.attributionReportingVerboseDebugReportSent"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Storage.attributionReportingVerboseDebugReportSent"
    end
  end
end
