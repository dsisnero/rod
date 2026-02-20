require "../layertree/layertree"
require "json"
require "time"
require "../dom/dom"

module Cdp::LayerTree
  alias LayerId = String

  alias SnapshotId = String

  struct ScrollRect
    include JSON::Serializable

    property rect : Cdp::DOM::Rect
    property type : ScrollRectType
  end

  struct StickyPositionConstraint
    include JSON::Serializable

    property sticky_box_rect : Cdp::DOM::Rect
    property containing_block_rect : Cdp::DOM::Rect
    @[JSON::Field(emit_null: false)]
    property nearest_layer_shifting_sticky_box : LayerId?
    @[JSON::Field(emit_null: false)]
    property nearest_layer_shifting_containing_block : LayerId?
  end

  struct PictureTile
    include JSON::Serializable

    property x : Float64
    property y : Float64
    property picture : String
  end

  struct Layer
    include JSON::Serializable

    property layer_id : LayerId
    @[JSON::Field(emit_null: false)]
    property parent_layer_id : LayerId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    property offset_x : Float64
    property offset_y : Float64
    property width : Float64
    property height : Float64
    @[JSON::Field(emit_null: false)]
    property transform : Array(Float64)?
    @[JSON::Field(emit_null: false)]
    property anchor_x : Float64?
    @[JSON::Field(emit_null: false)]
    property anchor_y : Float64?
    @[JSON::Field(emit_null: false)]
    property anchor_z : Float64?
    property paint_count : Int64
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
