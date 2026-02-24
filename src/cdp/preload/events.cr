require "../cdp"
require "json"
require "time"

require "../network/network"
require "../dom/dom"
require "../page/page"

module Cdp::Preload
  struct RuleSetUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property rule_set : RuleSet

    def initialize(@rule_set : RuleSet)
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
    property id : RuleSetId

    def initialize(@id : RuleSetId)
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
    property key : PreloadingAttemptKey
    @[JSON::Field(emit_null: false)]
    property pipeline_id : PreloadPipelineId
    @[JSON::Field(emit_null: false)]
    property initiating_frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property prefetch_url : String
    @[JSON::Field(emit_null: false)]
    property status : PreloadingStatus
    @[JSON::Field(emit_null: false)]
    property prefetch_status : PrefetchStatus
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::Network::RequestId

    def initialize(@key : PreloadingAttemptKey, @pipeline_id : PreloadPipelineId, @initiating_frame_id : Cdp::Page::FrameId, @prefetch_url : String, @status : PreloadingStatus, @prefetch_status : PrefetchStatus, @request_id : Cdp::Network::RequestId)
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
    property key : PreloadingAttemptKey
    @[JSON::Field(emit_null: false)]
    property pipeline_id : PreloadPipelineId
    @[JSON::Field(emit_null: false)]
    property status : PreloadingStatus
    @[JSON::Field(emit_null: false)]
    property prerender_status : PrerenderFinalStatus?
    @[JSON::Field(emit_null: false)]
    property disallowed_mojo_interface : String?
    @[JSON::Field(emit_null: false)]
    property mismatched_headers : Array(PrerenderMismatchedHeaders)?

    def initialize(@key : PreloadingAttemptKey, @pipeline_id : PreloadPipelineId, @status : PreloadingStatus, @prerender_status : PrerenderFinalStatus?, @disallowed_mojo_interface : String?, @mismatched_headers : Array(PrerenderMismatchedHeaders)?)
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
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(emit_null: false)]
    property preloading_attempt_sources : Array(PreloadingAttemptSource)

    def initialize(@loader_id : Cdp::Network::LoaderId, @preloading_attempt_sources : Array(PreloadingAttemptSource))
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
