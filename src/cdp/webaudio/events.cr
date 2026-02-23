require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::WebAudio
  struct ContextCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context : Cdp::NodeType

    def initialize(@context : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.contextCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.contextCreated"
    end
  end

  struct ContextWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType

    def initialize(@context_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.contextWillBeDestroyed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.contextWillBeDestroyed"
    end
  end

  struct ContextChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context : Cdp::NodeType

    def initialize(@context : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.contextChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.contextChanged"
    end
  end

  struct AudioListenerCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property listener : Cdp::NodeType

    def initialize(@listener : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioListenerCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.audioListenerCreated"
    end
  end

  struct AudioListenerWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property listener_id : Cdp::NodeType

    def initialize(@context_id : Cdp::NodeType, @listener_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioListenerWillBeDestroyed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.audioListenerWillBeDestroyed"
    end
  end

  struct AudioNodeCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node : Cdp::NodeType

    def initialize(@node : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioNodeCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.audioNodeCreated"
    end
  end

  struct AudioNodeWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@context_id : Cdp::NodeType, @node_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioNodeWillBeDestroyed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.audioNodeWillBeDestroyed"
    end
  end

  struct AudioParamCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property param : Cdp::NodeType

    def initialize(@param : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioParamCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.audioParamCreated"
    end
  end

  struct AudioParamWillBeDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property param_id : Cdp::NodeType

    def initialize(@context_id : Cdp::NodeType, @node_id : Cdp::NodeType, @param_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.audioParamWillBeDestroyed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.audioParamWillBeDestroyed"
    end
  end

  struct NodesConnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property destination_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?
    @[JSON::Field(emit_null: false)]
    property destination_input_index : Float64?

    def initialize(@context_id : Cdp::NodeType, @source_id : Cdp::NodeType, @destination_id : Cdp::NodeType, @source_output_index : Float64?, @destination_input_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodesConnected"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.nodesConnected"
    end
  end

  struct NodesDisconnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property destination_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?
    @[JSON::Field(emit_null: false)]
    property destination_input_index : Float64?

    def initialize(@context_id : Cdp::NodeType, @source_id : Cdp::NodeType, @destination_id : Cdp::NodeType, @source_output_index : Float64?, @destination_input_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodesDisconnected"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.nodesDisconnected"
    end
  end

  struct NodeParamConnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property destination_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?

    def initialize(@context_id : Cdp::NodeType, @source_id : Cdp::NodeType, @destination_id : Cdp::NodeType, @source_output_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodeParamConnected"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.nodeParamConnected"
    end
  end

  struct NodeParamDisconnectedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property context_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property destination_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_output_index : Float64?

    def initialize(@context_id : Cdp::NodeType, @source_id : Cdp::NodeType, @destination_id : Cdp::NodeType, @source_output_index : Float64?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "WebAudio.nodeParamDisconnected"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "WebAudio.nodeParamDisconnected"
    end
  end
end
