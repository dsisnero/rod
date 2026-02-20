require "../preload/preload"
require "json"
require "time"
require "../page/page"
require "../network/network"

module Cdp::Preload
  alias RuleSetId = String

  struct RuleSet
    include JSON::Serializable

    property id : RuleSetId
    property loader_id : Cdp::Network::LoaderId
    property source_text : String
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::Network::RequestId?
    @[JSON::Field(emit_null: false)]
    property error_type : RuleSetErrorType?
    @[JSON::Field(emit_null: false)]
    property tag : String?
  end

  alias RuleSetErrorType = String

  alias SpeculationAction = String

  alias SpeculationTargetHint = String

  struct PreloadingAttemptKey
    include JSON::Serializable

    property loader_id : Cdp::Network::LoaderId
    property action : SpeculationAction
    property url : String
    @[JSON::Field(emit_null: false)]
    property target_hint : SpeculationTargetHint?
  end

  struct PreloadingAttemptSource
    include JSON::Serializable

    property key : PreloadingAttemptKey
    property rule_set_ids : Array(RuleSetId)
    property node_ids : Array(Cdp::DOM::BackendNodeId)
  end

  alias PreloadPipelineId = String

  alias PrerenderFinalStatus = String

  alias PreloadingStatus = String

  alias PrefetchStatus = String

  struct PrerenderMismatchedHeaders
    include JSON::Serializable

    property header_name : String
    @[JSON::Field(emit_null: false)]
    property initial_value : String?
    @[JSON::Field(emit_null: false)]
    property activation_value : String?
  end
end
