require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Overlay
  struct InspectNodeRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType

    def initialize(@backend_node_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.inspectNodeRequested"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Overlay.inspectNodeRequested"
    end
  end

  struct NodeHighlightRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.nodeHighlightRequested"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Overlay.nodeHighlightRequested"
    end
  end

  struct ScreenshotRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property viewport : Cdp::NodeType

    def initialize(@viewport : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.screenshotRequested"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Overlay.screenshotRequested"
    end
  end

  struct InspectPanelShowRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType

    def initialize(@backend_node_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.inspectPanelShowRequested"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Overlay.inspectPanelShowRequested"
    end
  end

  struct InspectedElementWindowRestoredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType

    def initialize(@backend_node_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.inspectedElementWindowRestored"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Overlay.inspectedElementWindowRestored"
    end
  end

  struct InspectModeCanceledEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.inspectModeCanceled"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Overlay.inspectModeCanceled"
    end
  end
end
