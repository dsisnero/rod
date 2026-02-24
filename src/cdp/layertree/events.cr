require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::LayerTree
  struct LayerPaintedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property layer_id : LayerId
    @[JSON::Field(emit_null: false)]
    property clip : Cdp::DOM::Rect

    def initialize(@layer_id : LayerId, @clip : Cdp::DOM::Rect)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "LayerTree.layerPainted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "LayerTree.layerPainted"
    end
  end

  struct LayerTreeDidChangeEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property layers : Array(Layer)?

    def initialize(@layers : Array(Layer)?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "LayerTree.layerTreeDidChange"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "LayerTree.layerTreeDidChange"
    end
  end
end
