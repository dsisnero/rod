require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::LayerTree
  alias LayerId = String

  alias SnapshotId = String

  struct ScrollRect
    include JSON::Serializable
    @[JSON::Field(key: "rect", emit_null: false)]
    property rect : Cdp::DOM::Rect
    @[JSON::Field(key: "type", emit_null: false)]
    property type : ScrollRectType
  end

  struct StickyPositionConstraint
    include JSON::Serializable
    @[JSON::Field(key: "stickyBoxRect", emit_null: false)]
    property sticky_box_rect : Cdp::DOM::Rect
    @[JSON::Field(key: "containingBlockRect", emit_null: false)]
    property containing_block_rect : Cdp::DOM::Rect
    @[JSON::Field(key: "nearestLayerShiftingStickyBox", emit_null: false)]
    property nearest_layer_shifting_sticky_box : LayerId?
    @[JSON::Field(key: "nearestLayerShiftingContainingBlock", emit_null: false)]
    property nearest_layer_shifting_containing_block : LayerId?
  end

  struct PictureTile
    include JSON::Serializable
    @[JSON::Field(key: "x", emit_null: false)]
    property x : Float64
    @[JSON::Field(key: "y", emit_null: false)]
    property y : Float64
    @[JSON::Field(key: "picture", emit_null: false)]
    property picture : String
  end

  struct Layer
    include JSON::Serializable
    @[JSON::Field(key: "layerId", emit_null: false)]
    property layer_id : LayerId
    @[JSON::Field(key: "parentLayerId", emit_null: false)]
    property parent_layer_id : LayerId?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "offsetX", emit_null: false)]
    property offset_x : Float64
    @[JSON::Field(key: "offsetY", emit_null: false)]
    property offset_y : Float64
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Float64
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Float64
    @[JSON::Field(key: "transform", emit_null: false)]
    property transform : Array(Float64)?
    @[JSON::Field(key: "anchorX", emit_null: false)]
    property anchor_x : Float64?
    @[JSON::Field(key: "anchorY", emit_null: false)]
    property anchor_y : Float64?
    @[JSON::Field(key: "anchorZ", emit_null: false)]
    property anchor_z : Float64?
    @[JSON::Field(key: "paintCount", emit_null: false)]
    property paint_count : Int64
    @[JSON::Field(key: "drawsContent", emit_null: false)]
    property? draws_content : Bool
    @[JSON::Field(key: "invisible", emit_null: false)]
    property? invisible : Bool?
    @[JSON::Field(key: "scrollRects", emit_null: false)]
    property scroll_rects : Array(ScrollRect)?
    @[JSON::Field(key: "stickyPositionConstraint", emit_null: false)]
    property sticky_position_constraint : StickyPositionConstraint?
  end

  # TODO: Implement type array for LayerTree.PaintProfile
  alias PaintProfile = JSON::Any

  alias ScrollRectType = String
  ScrollRectTypeRepaintsOnScroll  = "RepaintsOnScroll"
  ScrollRectTypeTouchEventHandler = "TouchEventHandler"
  ScrollRectTypeWheelEventHandler = "WheelEventHandler"
end
