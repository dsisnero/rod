require "json"
require "../cdp"
require "../dom/dom"
require "../runtime/runtime"
require "../page/page"
require "./types"

# This domain provides various functionality related to drawing atop the inspected page.
@[Experimental]
module Cdp::Overlay
  # Commands
  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetHighlightObjectForTest
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId
    @[JSON::Field(emit_null: false)]
    property include_distance : Bool?
    @[JSON::Field(emit_null: false)]
    property include_style : Bool?
    @[JSON::Field(emit_null: false)]
    property color_format : ColorFormat?
    @[JSON::Field(emit_null: false)]
    property show_accessibility_info : Bool?

    def initialize(@node_id : Cdp::DOM::NodeId, @include_distance : Bool?, @include_style : Bool?, @color_format : ColorFormat?, @show_accessibility_info : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.getHighlightObjectForTest"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetHighlightObjectForTestResult
      res = GetHighlightObjectForTestResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetHighlightObjectForTestResult
    include JSON::Serializable

    property highlight : JSON::Any

    def initialize(@highlight : JSON::Any)
    end
  end

  struct GetGridHighlightObjectsForTest
    include JSON::Serializable
    include Cdp::Request

    property node_ids : Array(Cdp::DOM::NodeId)

    def initialize(@node_ids : Array(Cdp::DOM::NodeId))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.getGridHighlightObjectsForTest"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetGridHighlightObjectsForTestResult
      res = GetGridHighlightObjectsForTestResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetGridHighlightObjectsForTestResult
    include JSON::Serializable

    property highlights : JSON::Any

    def initialize(@highlights : JSON::Any)
    end
  end

  struct GetSourceOrderHighlightObjectForTest
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.getSourceOrderHighlightObjectForTest"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSourceOrderHighlightObjectForTestResult
      res = GetSourceOrderHighlightObjectForTestResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetSourceOrderHighlightObjectForTestResult
    include JSON::Serializable

    property highlight : JSON::Any

    def initialize(@highlight : JSON::Any)
    end
  end

  struct HideHighlight
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.hideHighlight"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct HighlightNode
    include JSON::Serializable
    include Cdp::Request

    property highlight_config : HighlightConfig
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?
    @[JSON::Field(emit_null: false)]
    property selector : String?

    def initialize(@highlight_config : HighlightConfig, @node_id : Cdp::DOM::NodeId?, @backend_node_id : Cdp::DOM::BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?, @selector : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.highlightNode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct HighlightQuad
    include JSON::Serializable
    include Cdp::Request

    property quad : Cdp::DOM::Quad
    @[JSON::Field(emit_null: false)]
    property color : Cdp::DOM::RGBA?
    @[JSON::Field(emit_null: false)]
    property outline_color : Cdp::DOM::RGBA?

    def initialize(@quad : Cdp::DOM::Quad, @color : Cdp::DOM::RGBA?, @outline_color : Cdp::DOM::RGBA?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.highlightQuad"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct HighlightRect
    include JSON::Serializable
    include Cdp::Request

    property x : Int64
    property y : Int64
    property width : Int64
    property height : Int64
    @[JSON::Field(emit_null: false)]
    property color : Cdp::DOM::RGBA?
    @[JSON::Field(emit_null: false)]
    property outline_color : Cdp::DOM::RGBA?

    def initialize(@x : Int64, @y : Int64, @width : Int64, @height : Int64, @color : Cdp::DOM::RGBA?, @outline_color : Cdp::DOM::RGBA?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.highlightRect"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct HighlightSourceOrder
    include JSON::Serializable
    include Cdp::Request

    property source_order_config : SourceOrderConfig
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::Runtime::RemoteObjectId?

    def initialize(@source_order_config : SourceOrderConfig, @node_id : Cdp::DOM::NodeId?, @backend_node_id : Cdp::DOM::BackendNodeId?, @object_id : Cdp::Runtime::RemoteObjectId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.highlightSourceOrder"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetInspectMode
    include JSON::Serializable
    include Cdp::Request

    property mode : InspectMode
    @[JSON::Field(emit_null: false)]
    property highlight_config : HighlightConfig?

    def initialize(@mode : InspectMode, @highlight_config : HighlightConfig?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setInspectMode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowAdHighlights
    include JSON::Serializable
    include Cdp::Request

    property show : Bool

    def initialize(@show : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowAdHighlights"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetPausedInDebuggerMessage
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property message : String?

    def initialize(@message : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setPausedInDebuggerMessage"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowDebugBorders
    include JSON::Serializable
    include Cdp::Request

    property show : Bool

    def initialize(@show : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowDebugBorders"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowFPSCounter
    include JSON::Serializable
    include Cdp::Request

    property show : Bool

    def initialize(@show : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowFPSCounter"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowGridOverlays
    include JSON::Serializable
    include Cdp::Request

    property grid_node_highlight_configs : Array(GridNodeHighlightConfig)

    def initialize(@grid_node_highlight_configs : Array(GridNodeHighlightConfig))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowGridOverlays"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowFlexOverlays
    include JSON::Serializable
    include Cdp::Request

    property flex_node_highlight_configs : Array(FlexNodeHighlightConfig)

    def initialize(@flex_node_highlight_configs : Array(FlexNodeHighlightConfig))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowFlexOverlays"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowScrollSnapOverlays
    include JSON::Serializable
    include Cdp::Request

    property scroll_snap_highlight_configs : Array(ScrollSnapHighlightConfig)

    def initialize(@scroll_snap_highlight_configs : Array(ScrollSnapHighlightConfig))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowScrollSnapOverlays"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowContainerQueryOverlays
    include JSON::Serializable
    include Cdp::Request

    property container_query_highlight_configs : Array(ContainerQueryHighlightConfig)

    def initialize(@container_query_highlight_configs : Array(ContainerQueryHighlightConfig))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowContainerQueryOverlays"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowInspectedElementAnchor
    include JSON::Serializable
    include Cdp::Request

    property inspected_element_anchor_config : InspectedElementAnchorConfig

    def initialize(@inspected_element_anchor_config : InspectedElementAnchorConfig)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowInspectedElementAnchor"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowPaintRects
    include JSON::Serializable
    include Cdp::Request

    property result : Bool

    def initialize(@result : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowPaintRects"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowLayoutShiftRegions
    include JSON::Serializable
    include Cdp::Request

    property result : Bool

    def initialize(@result : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowLayoutShiftRegions"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowScrollBottleneckRects
    include JSON::Serializable
    include Cdp::Request

    property show : Bool

    def initialize(@show : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowScrollBottleneckRects"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowViewportSizeOnResize
    include JSON::Serializable
    include Cdp::Request

    property show : Bool

    def initialize(@show : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowViewportSizeOnResize"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowHinge
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property hinge_config : HingeConfig?

    def initialize(@hinge_config : HingeConfig?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowHinge"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowIsolatedElements
    include JSON::Serializable
    include Cdp::Request

    property isolated_element_highlight_configs : Array(IsolatedElementHighlightConfig)

    def initialize(@isolated_element_highlight_configs : Array(IsolatedElementHighlightConfig))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowIsolatedElements"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetShowWindowControlsOverlay
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property window_controls_overlay_config : WindowControlsOverlayConfig?

    def initialize(@window_controls_overlay_config : WindowControlsOverlayConfig?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Overlay.setShowWindowControlsOverlay"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
