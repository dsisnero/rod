
require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::LayerTree
  alias LayerId = String

  alias SnapshotId = String

  struct ScrollRect
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property type : ScrollRectType
  end

  struct StickyPositionConstraint
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property sticky_box_rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property containing_block_rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property nearest_layer_shifting_sticky_box : LayerId?
    @[JSON::Field(emit_null: false)]
    property nearest_layer_shifting_containing_block : LayerId?
  end

  struct PictureTile
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property x : Float64
    @[JSON::Field(emit_null: false)]
    property y : Float64
    @[JSON::Field(emit_null: false)]
    property picture : String
  end

  struct Layer
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property layer_id : LayerId
    @[JSON::Field(emit_null: false)]
    property parent_layer_id : LayerId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property offset_x : Float64
    @[JSON::Field(emit_null: false)]
    property offset_y : Float64
    @[JSON::Field(emit_null: false)]
    property width : Float64
    @[JSON::Field(emit_null: false)]
    property height : Float64
    @[JSON::Field(emit_null: false)]
    property transform : Array(Float64)?
    @[JSON::Field(emit_null: false)]
    property anchor_x : Float64?
    @[JSON::Field(emit_null: false)]
    property anchor_y : Float64?
    @[JSON::Field(emit_null: false)]
    property anchor_z : Float64?
    @[JSON::Field(emit_null: false)]
    property paint_count : Int64
    @[JSON::Field(emit_null: false)]
    property draws_content : Bool
    @[JSON::Field(emit_null: false)]
    property invisible : Bool?
    @[JSON::Field(emit_null: false)]
    property scroll_rects : Array(ScrollRect)?
    @[JSON::Field(emit_null: false)]
    property sticky_position_constraint : StickyPositionConstraint?
  end

  # TODO: Implement type array for LayerTree.PaintProfile
  alias PaintProfile = JSON::Any

  alias ScrollRectType = String

   end
