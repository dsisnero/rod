require "../cdp"
require "json"
require "base64"
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
    @[JSON::Field(key: "documentURL", emit_null: false)]
    property document_url : String?
    @[JSON::Field(key: "baseURL", emit_null: false)]
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
    @[JSON::Field(key: "currentSourceURL", emit_null: false)]
    property current_source_url : String?
    @[JSON::Field(key: "originURL", emit_null: false)]
    property origin_url : String?
    @[JSON::Field(key: "scrollOffsetX", emit_null: false)]
    property scroll_offset_x : Float64?
    @[JSON::Field(key: "scrollOffsetY", emit_null: false)]
    property scroll_offset_y : Float64?

    def initialize(@node_type : Cdp::NodeType, @node_name : String, @node_value : String, @backend_node_id : Cdp::DOM::BackendNodeId, @text_value : String? = nil, @input_value : String? = nil, @input_checked : Bool? = nil, @option_selected : Bool? = nil, @child_node_indexes : Array(Int64)? = nil, @attributes : Array(NameValue)? = nil, @pseudo_element_indexes : Array(Int64)? = nil, @layout_node_index : Int64? = nil, @document_url : String? = nil, @base_url : String? = nil, @content_language : String? = nil, @document_encoding : String? = nil, @public_id : String? = nil, @system_id : String? = nil, @frame_id : Cdp::Page::FrameId? = nil, @content_document_index : Int64? = nil, @pseudo_type : Cdp::DOM::PseudoType? = nil, @shadow_root_type : Cdp::DOM::ShadowRootType? = nil, @is_clickable : Bool? = nil, @event_listeners : Array(Cdp::DOMDebugger::EventListener)? = nil, @current_source_url : String? = nil, @origin_url : String? = nil, @scroll_offset_x : Float64? = nil, @scroll_offset_y : Float64? = nil)
    end
  end

  struct InlineTextBox
    include JSON::Serializable
    @[JSON::Field(key: "boundingBox", emit_null: false)]
    property bounding_box : Cdp::DOM::Rect
    @[JSON::Field(key: "startCharacterIndex", emit_null: false)]
    property start_character_index : Int64
    @[JSON::Field(key: "numCharacters", emit_null: false)]
    property num_characters : Int64

    def initialize(@bounding_box : Cdp::DOM::Rect, @start_character_index : Int64, @num_characters : Int64)
    end
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

    def initialize(@dom_node_index : Int64, @bounding_box : Cdp::DOM::Rect, @layout_text : String? = nil, @inline_text_nodes : Array(InlineTextBox)? = nil, @style_index : Int64? = nil, @paint_order : Int64? = nil, @is_stacking_context : Bool? = nil)
    end
  end

  struct ComputedStyle
    include JSON::Serializable
    @[JSON::Field(key: "properties", emit_null: false)]
    property properties : Array(NameValue)

    def initialize(@properties : Array(NameValue))
    end
  end

  struct NameValue
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String

    def initialize(@name : String, @value : String)
    end
  end

  alias StringIndex = Int64

  # TODO: Implement type array for ArrayOfStrings
  alias ArrayOfStrings = JSON::Any

  struct RareStringData
    include JSON::Serializable
    @[JSON::Field(key: "index", emit_null: false)]
    property index : Array(Int64)
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Array(StringIndex)

    def initialize(@index : Array(Int64), @value : Array(StringIndex))
    end
  end

  struct RareBooleanData
    include JSON::Serializable
    @[JSON::Field(key: "index", emit_null: false)]
    property index : Array(Int64)

    def initialize(@index : Array(Int64))
    end
  end

  struct RareIntegerData
    include JSON::Serializable
    @[JSON::Field(key: "index", emit_null: false)]
    property index : Array(Int64)
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Array(Int64)

    def initialize(@index : Array(Int64), @value : Array(Int64))
    end
  end

  # TODO: Implement type array for Rectangle
  alias Rectangle = JSON::Any

  struct DocumentSnapshot
    include JSON::Serializable
    @[JSON::Field(key: "documentURL", emit_null: false)]
    property document_url : StringIndex
    @[JSON::Field(key: "title", emit_null: false)]
    property title : StringIndex
    @[JSON::Field(key: "baseURL", emit_null: false)]
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

    def initialize(@document_url : StringIndex, @title : StringIndex, @base_url : StringIndex, @content_language : StringIndex, @encoding_name : StringIndex, @public_id : StringIndex, @system_id : StringIndex, @frame_id : StringIndex, @nodes : NodeTreeSnapshot, @layout : LayoutTreeSnapshot, @text_boxes : TextBoxSnapshot, @scroll_offset_x : Float64? = nil, @scroll_offset_y : Float64? = nil, @content_width : Float64? = nil, @content_height : Float64? = nil)
    end
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
    @[JSON::Field(key: "currentSourceURL", emit_null: false)]
    property current_source_url : RareStringData?
    @[JSON::Field(key: "originURL", emit_null: false)]
    property origin_url : RareStringData?

    def initialize(@parent_index : Array(Int64)? = nil, @node_type : Array(Int64)? = nil, @shadow_root_type : RareStringData? = nil, @node_name : Array(StringIndex)? = nil, @node_value : Array(StringIndex)? = nil, @backend_node_id : Array(Cdp::DOM::BackendNodeId)? = nil, @attributes : Array(ArrayOfStrings)? = nil, @text_value : RareStringData? = nil, @input_value : RareStringData? = nil, @input_checked : RareBooleanData? = nil, @option_selected : RareBooleanData? = nil, @content_document_index : RareIntegerData? = nil, @pseudo_type : RareStringData? = nil, @pseudo_identifier : RareStringData? = nil, @is_clickable : RareBooleanData? = nil, @current_source_url : RareStringData? = nil, @origin_url : RareStringData? = nil)
    end
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

    def initialize(@node_index : Array(Int64), @styles : Array(ArrayOfStrings), @bounds : Array(Rectangle), @text : Array(StringIndex), @stacking_contexts : RareBooleanData, @paint_orders : Array(Int64)? = nil, @offset_rects : Array(Rectangle)? = nil, @scroll_rects : Array(Rectangle)? = nil, @client_rects : Array(Rectangle)? = nil, @blended_background_colors : Array(StringIndex)? = nil, @text_color_opacities : Array(Float64)? = nil)
    end
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

    def initialize(@layout_index : Array(Int64), @bounds : Array(Rectangle), @start : Array(Int64), @length : Array(Int64))
    end
  end
end
