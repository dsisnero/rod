require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::LayerTree
  struct LayerPaintedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property layer_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property clip : Cdp::NodeType

    def initialize(@layer_id : Cdp::NodeType, @clip : Cdp::NodeType)
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
    property layers : Array(Cdp::NodeType)?

    def initialize(@layers : Array(Cdp::NodeType)?)
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
