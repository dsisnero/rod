require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../runtime/runtime"

module Cdp::Overlay
  struct InspectNodeRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId

    def initialize(@backend_node_id : Cdp::DOM::BackendNodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.inspectNodeRequested"
    end
  end

  struct NodeHighlightRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.nodeHighlightRequested"
    end
  end

  struct ScreenshotRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property viewport : Cdp::Page::Viewport

    def initialize(@viewport : Cdp::Page::Viewport)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.screenshotRequested"
    end
  end

  struct InspectPanelShowRequestedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId

    def initialize(@backend_node_id : Cdp::DOM::BackendNodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Overlay.inspectPanelShowRequested"
    end
  end

  struct InspectedElementWindowRestoredEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId

    def initialize(@backend_node_id : Cdp::DOM::BackendNodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
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
  end
end
