require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../domdebugger/domdebugger"

module Cdp::DOMSnapshot
  struct DOMNode
    include JSON::Serializable
    @[JSON::Field(key: "nodeType", emit_null: false)]
    property node_type : Cdp::NodeType
    @[JSON::Field(key: "nodeName", emit_null: false)]
    property node_name : String
    @[JSON::Field(key: "nodeValue", emit_null: false)]
    property node_value : String
    @[JSON::Field(key: "textValue", emit_null: false)]
    property text_value : String?
    @[JSON::Field(key: "inputValue", emit_null: false)]
    property input_value : String?
    @[JSON::Field(key: "inputChecked", emit_null: false)]
    property? input_checked : Bool?
    @[JSON::Field(key: "optionSelected", emit_null: false)]
    property? option_selected : Bool?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(key: "childNodeIndexes", emit_null: false)]
    property child_node_indexes : Array(Int64)?
    @[JSON::Field(key: "attributes", emit_null: false)]
    property attributes : Array(NameValue)?
    @[JSON::Field(key: "pseudoElementIndexes", emit_null: false)]
    property pseudo_element_indexes : Array(Int64)?
    @[JSON::Field(key: "layoutNodeIndex", emit_null: false)]
    property layout_node_index : Int64?
    @[JSON::Field(key: "documentUrl", emit_null: false)]
    property document_url : String?
    @[JSON::Field(key: "baseUrl", emit_null: false)]
    property base_url : String?
    @[JSON::Field(key: "contentLanguage", emit_null: false)]
    property content_language : String?
    @[JSON::Field(key: "documentEncoding", emit_null: false)]
    property document_encoding : String?
    @[JSON::Field(key: "publicId", emit_null: false)]
    property public_id : String?
    @[JSON::Field(key: "systemId", emit_null: false)]
    property system_id : String?
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
    @[JSON::Field(key: "contentDocumentIndex", emit_null: false)]
    property content_document_index : Int64?
    @[JSON::Field(key: "pseudoType", emit_null: false)]
    property pseudo_type : Cdp::DOM::PseudoType?
    @[JSON::Field(key: "shadowRootType", emit_null: false)]
    property shadow_root_type : Cdp::DOM::ShadowRootType?
    @[JSON::Field(key: "isClickable", emit_null: false)]
    property? is_clickable : Bool?
    @[JSON::Field(key: "eventListeners", emit_null: false)]
    property event_listeners : Array(Cdp::DOMDebugger::EventListener)?
    @[JSON::Field(key: "currentSourceUrl", emit_null: false)]
    property current_source_url : String?
    @[JSON::Field(key: "originUrl", emit_null: false)]
    property origin_url : String?
    @[JSON::Field(key: "scrollOffsetX", emit_null: false)]
    property scroll_offset_x : Float64?
    @[JSON::Field(key: "scrollOffsetY", emit_null: false)]
    property scroll_offset_y : Float64?
  end

  struct InlineTextBox
    include JSON::Serializable
    @[JSON::Field(key: "boundingBox", emit_null: false)]
    property bounding_box : Cdp::DOM::Rect
    @[JSON::Field(key: "startCharacterIndex", emit_null: false)]
    property start_character_index : Int64
    @[JSON::Field(key: "numCharacters", emit_null: false)]
    property num_characters : Int64
  end

  struct LayoutTreeNode
    include JSON::Serializable
    @[JSON::Field(key: "domNodeIndex", emit_null: false)]
    property dom_node_index : Int64
    @[JSON::Field(key: "boundingBox", emit_null: false)]
    property bounding_box : Cdp::DOM::Rect
    @[JSON::Field(key: "layoutText", emit_null: false)]
    property layout_text : String?
    @[JSON::Field(key: "inlineTextNodes", emit_null: false)]
    property inline_text_nodes : Array(InlineTextBox)?
    @[JSON::Field(key: "styleIndex", emit_null: false)]
    property style_index : Int64?
    @[JSON::Field(key: "paintOrder", emit_null: false)]
    property paint_order : Int64?
    @[JSON::Field(key: "isStackingContext", emit_null: false)]
    property? is_stacking_context : Bool?
  end

  struct ComputedStyle
    include JSON::Serializable
    @[JSON::Field(key: "properties", emit_null: false)]
    property properties : Array(NameValue)
  end

  struct NameValue
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
  end

  alias StringIndex = Int64

  # TODO: Implement type array for DOMSnapshot.ArrayOfStrings
  alias ArrayOfStrings = JSON::Any

  struct RareStringData
    include JSON::Serializable
    @[JSON::Field(key: "index", emit_null: false)]
    property index : Array(Int64)
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Array(StringIndex)
  end

  struct RareBooleanData
    include JSON::Serializable
    @[JSON::Field(key: "index", emit_null: false)]
    property index : Array(Int64)
  end

  struct RareIntegerData
    include JSON::Serializable
    @[JSON::Field(key: "index", emit_null: false)]
    property index : Array(Int64)
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Array(Int64)
  end

  # TODO: Implement type array for DOMSnapshot.Rectangle
  alias Rectangle = JSON::Any

  struct DocumentSnapshot
    include JSON::Serializable
    @[JSON::Field(key: "documentUrl", emit_null: false)]
    property document_url : StringIndex
    @[JSON::Field(key: "title", emit_null: false)]
    property title : StringIndex
    @[JSON::Field(key: "baseUrl", emit_null: false)]
    property base_url : StringIndex
    @[JSON::Field(key: "contentLanguage", emit_null: false)]
    property content_language : StringIndex
    @[JSON::Field(key: "encodingName", emit_null: false)]
    property encoding_name : StringIndex
    @[JSON::Field(key: "publicId", emit_null: false)]
    property public_id : StringIndex
    @[JSON::Field(key: "systemId", emit_null: false)]
    property system_id : StringIndex
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : StringIndex
    @[JSON::Field(key: "nodes", emit_null: false)]
    property nodes : NodeTreeSnapshot
    @[JSON::Field(key: "layout", emit_null: false)]
    property layout : LayoutTreeSnapshot
    @[JSON::Field(key: "textBoxes", emit_null: false)]
    property text_boxes : TextBoxSnapshot
    @[JSON::Field(key: "scrollOffsetX", emit_null: false)]
    property scroll_offset_x : Float64?
    @[JSON::Field(key: "scrollOffsetY", emit_null: false)]
    property scroll_offset_y : Float64?
    @[JSON::Field(key: "contentWidth", emit_null: false)]
    property content_width : Float64?
    @[JSON::Field(key: "contentHeight", emit_null: false)]
    property content_height : Float64?
  end

  struct NodeTreeSnapshot
    include JSON::Serializable
    @[JSON::Field(key: "parentIndex", emit_null: false)]
    property parent_index : Array(Int64)?
    @[JSON::Field(key: "nodeType", emit_null: false)]
    property node_type : Array(Int64)?
    @[JSON::Field(key: "shadowRootType", emit_null: false)]
    property shadow_root_type : RareStringData?
    @[JSON::Field(key: "nodeName", emit_null: false)]
    property node_name : Array(StringIndex)?
    @[JSON::Field(key: "nodeValue", emit_null: false)]
    property node_value : Array(StringIndex)?
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Array(Cdp::DOM::BackendNodeId)?
    @[JSON::Field(key: "attributes", emit_null: false)]
    property attributes : Array(ArrayOfStrings)?
    @[JSON::Field(key: "textValue", emit_null: false)]
    property text_value : RareStringData?
    @[JSON::Field(key: "inputValue", emit_null: false)]
    property input_value : RareStringData?
    @[JSON::Field(key: "inputChecked", emit_null: false)]
    property input_checked : RareBooleanData?
    @[JSON::Field(key: "optionSelected", emit_null: false)]
    property option_selected : RareBooleanData?
    @[JSON::Field(key: "contentDocumentIndex", emit_null: false)]
    property content_document_index : RareIntegerData?
    @[JSON::Field(key: "pseudoType", emit_null: false)]
    property pseudo_type : RareStringData?
    @[JSON::Field(key: "pseudoIdentifier", emit_null: false)]
    property pseudo_identifier : RareStringData?
    @[JSON::Field(key: "isClickable", emit_null: false)]
    property is_clickable : RareBooleanData?
    @[JSON::Field(key: "currentSourceUrl", emit_null: false)]
    property current_source_url : RareStringData?
    @[JSON::Field(key: "originUrl", emit_null: false)]
    property origin_url : RareStringData?
  end

  struct LayoutTreeSnapshot
    include JSON::Serializable
    @[JSON::Field(key: "nodeIndex", emit_null: false)]
    property node_index : Array(Int64)
    @[JSON::Field(key: "styles", emit_null: false)]
    property styles : Array(ArrayOfStrings)
    @[JSON::Field(key: "bounds", emit_null: false)]
    property bounds : Array(Rectangle)
    @[JSON::Field(key: "text", emit_null: false)]
    property text : Array(StringIndex)
    @[JSON::Field(key: "stackingContexts", emit_null: false)]
    property stacking_contexts : RareBooleanData
    @[JSON::Field(key: "paintOrders", emit_null: false)]
    property paint_orders : Array(Int64)?
    @[JSON::Field(key: "offsetRects", emit_null: false)]
    property offset_rects : Array(Rectangle)?
    @[JSON::Field(key: "scrollRects", emit_null: false)]
    property scroll_rects : Array(Rectangle)?
    @[JSON::Field(key: "clientRects", emit_null: false)]
    property client_rects : Array(Rectangle)?
    @[JSON::Field(key: "blendedBackgroundColors", emit_null: false)]
    property blended_background_colors : Array(StringIndex)?
    @[JSON::Field(key: "textColorOpacities", emit_null: false)]
    property text_color_opacities : Array(Float64)?
  end

  struct TextBoxSnapshot
    include JSON::Serializable
    @[JSON::Field(key: "layoutIndex", emit_null: false)]
    property layout_index : Array(Int64)
    @[JSON::Field(key: "bounds", emit_null: false)]
    property bounds : Array(Rectangle)
    @[JSON::Field(key: "start", emit_null: false)]
    property start : Array(Int64)
    @[JSON::Field(key: "length", emit_null: false)]
    property length : Array(Int64)
  end
end
