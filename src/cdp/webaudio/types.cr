require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::WebAudio
  alias GraphObjectId = String

  alias ContextType = String
  ContextTypeRealtime = "realtime"
  ContextTypeOffline  = "offline"

  alias ContextState = String
  ContextStateSuspended   = "suspended"
  ContextStateRunning     = "running"
  ContextStateClosed      = "closed"
  ContextStateInterrupted = "interrupted"

  alias NodeType = String

  alias ChannelCountMode = String
  ChannelCountModeClampedMax = "clamped-max"
  ChannelCountModeExplicit   = "explicit"
  ChannelCountModeMax        = "max"

  alias ChannelInterpretation = String
  ChannelInterpretationDiscrete = "discrete"
  ChannelInterpretationSpeakers = "speakers"

  alias ParamType = String

  alias AutomationRate = String
  AutomationRateARate = "a-rate"
  AutomationRateKRate = "k-rate"

  struct ContextRealtimeData
    include JSON::Serializable
    @[JSON::Field(key: "currentTime", emit_null: false)]
    property current_time : Float64
    @[JSON::Field(key: "renderCapacity", emit_null: false)]
    property render_capacity : Float64
    @[JSON::Field(key: "callbackIntervalMean", emit_null: false)]
    property callback_interval_mean : Float64
    @[JSON::Field(key: "callbackIntervalVariance", emit_null: false)]
    property callback_interval_variance : Float64
  end

  struct BaseAudioContext
    include JSON::Serializable
    @[JSON::Field(key: "contextId", emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(key: "contextType", emit_null: false)]
    property context_type : ContextType
    @[JSON::Field(key: "contextState", emit_null: false)]
    property context_state : ContextState
    @[JSON::Field(key: "realtimeData", emit_null: false)]
    property realtime_data : ContextRealtimeData?
    @[JSON::Field(key: "callbackBufferSize", emit_null: false)]
    property callback_buffer_size : Float64
    @[JSON::Field(key: "maxOutputChannelCount", emit_null: false)]
    property max_output_channel_count : Float64
    @[JSON::Field(key: "sampleRate", emit_null: false)]
    property sample_rate : Float64
  end

  struct AudioListener
    include JSON::Serializable
    @[JSON::Field(key: "listenerId", emit_null: false)]
    property listener_id : GraphObjectId
    @[JSON::Field(key: "contextId", emit_null: false)]
    property context_id : GraphObjectId
  end

  struct AudioNode
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : GraphObjectId
    @[JSON::Field(key: "contextId", emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(key: "nodeType", emit_null: false)]
    property node_type : Cdp::NodeType
    @[JSON::Field(key: "numberOfInputs", emit_null: false)]
    property number_of_inputs : Float64
    @[JSON::Field(key: "numberOfOutputs", emit_null: false)]
    property number_of_outputs : Float64
    @[JSON::Field(key: "channelCount", emit_null: false)]
    property channel_count : Float64
    @[JSON::Field(key: "channelCountMode", emit_null: false)]
    property channel_count_mode : ChannelCountMode
    @[JSON::Field(key: "channelInterpretation", emit_null: false)]
    property channel_interpretation : ChannelInterpretation
  end

  struct AudioParam
    include JSON::Serializable
    @[JSON::Field(key: "paramId", emit_null: false)]
    property param_id : GraphObjectId
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : GraphObjectId
    @[JSON::Field(key: "contextId", emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(key: "paramType", emit_null: false)]
    property param_type : ParamType
    @[JSON::Field(key: "rate", emit_null: false)]
    property rate : AutomationRate
    @[JSON::Field(key: "defaultValue", emit_null: false)]
    property default_value : Float64
    @[JSON::Field(key: "minValue", emit_null: false)]
    property min_value : Float64
    @[JSON::Field(key: "maxValue", emit_null: false)]
    property max_value : Float64
  end
end
