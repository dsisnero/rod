require "../webaudio/webaudio"
require "json"
require "time"

module Cdp::WebAudio
  alias GraphObjectId = String

  alias ContextType = String

  alias ContextState = String

  alias NodeType = String

  alias ChannelCountMode = String

  alias ChannelInterpretation = String

  alias ParamType = String

  alias AutomationRate = String

  struct ContextRealtimeData
    include JSON::Serializable

    property current_time : Float64
    property render_capacity : Float64
    property callback_interval_mean : Float64
    property callback_interval_variance : Float64
  end

  struct BaseAudioContext
    include JSON::Serializable

    property context_id : GraphObjectId
    property context_type : ContextType
    property context_state : ContextState
    @[JSON::Field(emit_null: false)]
    property realtime_data : ContextRealtimeData?
    property callback_buffer_size : Float64
    property max_output_channel_count : Float64
    property sample_rate : Float64
  end

  struct AudioListener
    include JSON::Serializable

    property listener_id : GraphObjectId
    property context_id : GraphObjectId
  end

  struct AudioNode
    include JSON::Serializable

    property node_id : GraphObjectId
    property context_id : GraphObjectId
    property node_type : Cdp::NodeType
    property number_of_inputs : Float64
    property number_of_outputs : Float64
    property channel_count : Float64
    property channel_count_mode : ChannelCountMode
    property channel_interpretation : ChannelInterpretation
  end

  struct AudioParam
    include JSON::Serializable

    property param_id : GraphObjectId
    property node_id : GraphObjectId
    property context_id : GraphObjectId
    property param_type : ParamType
    property rate : AutomationRate
    property default_value : Float64
    property min_value : Float64
    property max_value : Float64
  end
end
