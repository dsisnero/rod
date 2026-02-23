require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# This domain provides various functionality related to drawing atop the inspected page.
@[Experimental]
module Cdp::Overlay
  struct GetHighlightObjectForTestResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property highlight : JSON::Any

    def initialize(@highlight : JSON::Any)
    end
  end

  struct GetGridHighlightObjectsForTestResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property highlights : JSON::Any

    def initialize(@highlights : JSON::Any)
    end
  end

  struct GetSourceOrderHighlightObjectForTestResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property highlight : JSON::Any

    def initialize(@highlight : JSON::Any)
    end
  end

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
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? include_distance : Bool?
    @[JSON::Field(emit_null: false)]
    property? include_style : Bool?
    @[JSON::Field(emit_null: false)]
    property color_format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? show_accessibility_info : Bool?

    def initialize(@node_id : Cdp::NodeType, @include_distance : Bool?, @include_style : Bool?, @color_format : Cdp::NodeType?, @show_accessibility_info : Bool?)
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

  struct GetGridHighlightObjectsForTest
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(Cdp::NodeType)

    def initialize(@node_ids : Array(Cdp::NodeType))
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

  struct GetSourceOrderHighlightObjectForTest
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property highlight_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property selector : String?

    def initialize(@highlight_config : Cdp::NodeType, @node_id : Cdp::NodeType?, @backend_node_id : Cdp::NodeType?, @object_id : Cdp::NodeType?, @selector : String?)
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
    @[JSON::Field(emit_null: false)]
    property quad : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property outline_color : Cdp::NodeType?

    def initialize(@quad : Cdp::NodeType, @color : Cdp::NodeType?, @outline_color : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property x : Int64
    @[JSON::Field(emit_null: false)]
    property y : Int64
    @[JSON::Field(emit_null: false)]
    property width : Int64
    @[JSON::Field(emit_null: false)]
    property height : Int64
    @[JSON::Field(emit_null: false)]
    property color : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property outline_color : Cdp::NodeType?

    def initialize(@x : Int64, @y : Int64, @width : Int64, @height : Int64, @color : Cdp::NodeType?, @outline_color : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property source_order_config : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property object_id : Cdp::NodeType?

    def initialize(@source_order_config : Cdp::NodeType, @node_id : Cdp::NodeType?, @backend_node_id : Cdp::NodeType?, @object_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property mode : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property highlight_config : Cdp::NodeType?

    def initialize(@mode : Cdp::NodeType, @highlight_config : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property? show : Bool

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
    @[JSON::Field(emit_null: false)]
    property? show : Bool

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
    @[JSON::Field(emit_null: false)]
    property? show : Bool

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
    @[JSON::Field(emit_null: false)]
    property grid_node_highlight_configs : Array(Cdp::NodeType)

    def initialize(@grid_node_highlight_configs : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property flex_node_highlight_configs : Array(Cdp::NodeType)

    def initialize(@flex_node_highlight_configs : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property scroll_snap_highlight_configs : Array(Cdp::NodeType)

    def initialize(@scroll_snap_highlight_configs : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property container_query_highlight_configs : Array(Cdp::NodeType)

    def initialize(@container_query_highlight_configs : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property inspected_element_anchor_config : Cdp::NodeType

    def initialize(@inspected_element_anchor_config : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property? result : Bool

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
    @[JSON::Field(emit_null: false)]
    property? result : Bool

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
    @[JSON::Field(emit_null: false)]
    property? show : Bool

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
    @[JSON::Field(emit_null: false)]
    property? show : Bool

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
    property hinge_config : Cdp::NodeType?

    def initialize(@hinge_config : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property isolated_element_highlight_configs : Array(Cdp::NodeType)

    def initialize(@isolated_element_highlight_configs : Array(Cdp::NodeType))
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
    property window_controls_overlay_config : Cdp::NodeType?

    def initialize(@window_controls_overlay_config : Cdp::NodeType?)
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
