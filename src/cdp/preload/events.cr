require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Preload
  struct RuleSetUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property rule_set : Cdp::NodeType

    def initialize(@rule_set : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Preload.ruleSetUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Preload.ruleSetUpdated"
    end
  end

  struct RuleSetRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType

    def initialize(@id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Preload.ruleSetRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Preload.ruleSetRemoved"
    end
  end

  struct PreloadEnabledStateUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property? disabled_by_preference : Bool
    @[JSON::Field(emit_null: false)]
    property? disabled_by_data_saver : Bool
    @[JSON::Field(emit_null: false)]
    property? disabled_by_battery_saver : Bool
    @[JSON::Field(emit_null: false)]
    property? disabled_by_holdback_prefetch_speculation_rules : Bool
    @[JSON::Field(emit_null: false)]
    property? disabled_by_holdback_prerender_speculation_rules : Bool

    def initialize(@disabled_by_preference : Bool, @disabled_by_data_saver : Bool, @disabled_by_battery_saver : Bool, @disabled_by_holdback_prefetch_speculation_rules : Bool, @disabled_by_holdback_prerender_speculation_rules : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Preload.preloadEnabledStateUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Preload.preloadEnabledStateUpdated"
    end
  end

  struct PrefetchStatusUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property pipeline_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property initiating_frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property prefetch_url : String
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property prefetch_status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType

    def initialize(@key : Cdp::NodeType, @pipeline_id : Cdp::NodeType, @initiating_frame_id : Cdp::NodeType, @prefetch_url : String, @status : Cdp::NodeType, @prefetch_status : Cdp::NodeType, @request_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Preload.prefetchStatusUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Preload.prefetchStatusUpdated"
    end
  end

  struct PrerenderStatusUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property pipeline_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property prerender_status : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property disallowed_mojo_interface : String?
    @[JSON::Field(emit_null: false)]
    property mismatched_headers : Array(Cdp::NodeType)?

    def initialize(@key : Cdp::NodeType, @pipeline_id : Cdp::NodeType, @status : Cdp::NodeType, @prerender_status : Cdp::NodeType?, @disallowed_mojo_interface : String?, @mismatched_headers : Array(Cdp::NodeType)?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Preload.prerenderStatusUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Preload.prerenderStatusUpdated"
    end
  end

  struct PreloadingAttemptSourcesUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property preloading_attempt_sources : Array(Cdp::NodeType)

    def initialize(@loader_id : Cdp::NodeType, @preloading_attempt_sources : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Preload.preloadingAttemptSourcesUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Preload.preloadingAttemptSourcesUpdated"
    end
  end
end
