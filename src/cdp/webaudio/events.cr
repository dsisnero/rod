require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::WebAudio
  struct ContextCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context : BaseAudioContext

    def initialize(@context : BaseAudioContext)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.contextCreated"
    end
  end

  struct ContextWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId

    def initialize(@context_id : GraphObjectId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.contextWillBeDestroyed"
    end
  end

  struct ContextChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context : BaseAudioContext

    def initialize(@context : BaseAudioContext)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.contextChanged"
    end
  end

  struct AudioListenerCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property listener : AudioListener

    def initialize(@listener : AudioListener)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioListenerCreated"
    end
  end

  struct AudioListenerWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property listener_id : GraphObjectId

    def initialize(@context_id : GraphObjectId, @listener_id : GraphObjectId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioListenerWillBeDestroyed"
    end
  end

  struct AudioNodeCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node : AudioNode

    def initialize(@node : AudioNode)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioNodeCreated"
    end
  end

  struct AudioNodeWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property node_id : GraphObjectId

    def initialize(@context_id : GraphObjectId, @node_id : GraphObjectId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioNodeWillBeDestroyed"
    end
  end

  struct AudioParamCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property param : AudioParam

    def initialize(@param : AudioParam)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioParamCreated"
    end
  end

  struct AudioParamWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property node_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property param_id : GraphObjectId

    def initialize(@context_id : GraphObjectId, @node_id : GraphObjectId, @param_id : GraphObjectId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioParamWillBeDestroyed"
    end
  end

  struct NodesConnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property destination_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?
    @[JSON::Field(emit_null: false)]
    property destination_input_index : Float64?

    def initialize(@context_id : GraphObjectId, @source_id : GraphObjectId, @destination_id : GraphObjectId, @source_output_index : Float64?, @destination_input_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodesConnected"
    end
  end

  struct NodesDisconnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property destination_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?
    @[JSON::Field(emit_null: false)]
    property destination_input_index : Float64?

    def initialize(@context_id : GraphObjectId, @source_id : GraphObjectId, @destination_id : GraphObjectId, @source_output_index : Float64?, @destination_input_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodesDisconnected"
    end
  end

  struct NodeParamConnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property destination_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?

    def initialize(@context_id : GraphObjectId, @source_id : GraphObjectId, @destination_id : GraphObjectId, @source_output_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodeParamConnected"
    end
  end

  struct NodeParamDisconnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property destination_id : GraphObjectId
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?

    def initialize(@context_id : GraphObjectId, @source_id : GraphObjectId, @destination_id : GraphObjectId, @source_output_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodeParamDisconnected"
    end
  end
end
