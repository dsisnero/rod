require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::DOMSnapshot
  struct DOMNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_name : String
    @[JSON::Field(emit_null: false)]
    property node_value : String
    @[JSON::Field(emit_null: false)]
    property text_value : String?
    @[JSON::Field(emit_null: false)]
    property input_value : String?
    @[JSON::Field(emit_null: false)]
    property? input_checked : Bool?
    @[JSON::Field(emit_null: false)]
    property? option_selected : Bool?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property child_node_indexes : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property attributes : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property pseudo_element_indexes : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property layout_node_index : Int64?
    @[JSON::Field(emit_null: false)]
    property document_url : String?
    @[JSON::Field(emit_null: false)]
    property base_url : String?
    @[JSON::Field(emit_null: false)]
    property content_language : String?
    @[JSON::Field(emit_null: false)]
    property document_encoding : String?
    @[JSON::Field(emit_null: false)]
    property public_id : String?
    @[JSON::Field(emit_null: false)]
    property system_id : String?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property content_document_index : Int64?
    @[JSON::Field(emit_null: false)]
    property pseudo_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property shadow_root_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? is_clickable : Bool?
    @[JSON::Field(emit_null: false)]
    property event_listeners : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property current_source_url : String?
    @[JSON::Field(emit_null: false)]
    property origin_url : String?
    @[JSON::Field(emit_null: false)]
    property scroll_offset_x : Float64?
    @[JSON::Field(emit_null: false)]
    property scroll_offset_y : Float64?
  end

  struct InlineTextBox
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property bounding_box : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property start_character_index : Int64
    @[JSON::Field(emit_null: false)]
    property num_characters : Int64
  end

  struct LayoutTreeNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property dom_node_index : Int64
    @[JSON::Field(emit_null: false)]
    property bounding_box : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property layout_text : String?
    @[JSON::Field(emit_null: false)]
    property inline_text_nodes : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property style_index : Int64?
    @[JSON::Field(emit_null: false)]
    property paint_order : Int64?
    @[JSON::Field(emit_null: false)]
    property? is_stacking_context : Bool?
  end

  struct ComputedStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property properties : Array(Cdp::NodeType)
  end

  struct NameValue
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  alias StringIndex = Int64

  # TODO: Implement type array for DOMSnapshot.ArrayOfStrings
  alias ArrayOfStrings = JSON::Any

  struct RareStringData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property index : Array(Int64)
    @[JSON::Field(emit_null: false)]
    property value : Array(Cdp::NodeType)
  end

  struct RareBooleanData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property index : Array(Int64)
  end

  struct RareIntegerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property index : Array(Int64)
    @[JSON::Field(emit_null: false)]
    property value : Array(Int64)
  end

  # TODO: Implement type array for DOMSnapshot.Rectangle
  alias Rectangle = JSON::Any

  struct DocumentSnapshot
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property document_url : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property title : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property base_url : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property content_language : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property encoding_name : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property public_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property system_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property nodes : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property layout : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property text_boxes : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property scroll_offset_x : Float64?
    @[JSON::Field(emit_null: false)]
    property scroll_offset_y : Float64?
    @[JSON::Field(emit_null: false)]
    property content_width : Float64?
    @[JSON::Field(emit_null: false)]
    property content_height : Float64?
  end

  struct NodeTreeSnapshot
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property parent_index : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property node_type : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property shadow_root_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property node_name : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property node_value : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property attributes : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property text_value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property input_value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property input_checked : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property option_selected : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property content_document_index : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property pseudo_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property is_clickable : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property current_source_url : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin_url : Cdp::NodeType?
  end

  struct LayoutTreeSnapshot
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_index : Array(Int64)
    @[JSON::Field(emit_null: false)]
    property styles : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property bounds : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property text : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property stacking_contexts : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property paint_orders : Array(Int64)?
    @[JSON::Field(emit_null: false)]
    property offset_rects : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property scroll_rects : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property client_rects : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property blended_background_colors : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property text_color_opacities : Array(Float64)?
  end

  struct TextBoxSnapshot
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property layout_index : Array(Int64)
    @[JSON::Field(emit_null: false)]
    property bounds : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property start : Array(Int64)
    @[JSON::Field(emit_null: false)]
    property length : Array(Int64)
  end
end
