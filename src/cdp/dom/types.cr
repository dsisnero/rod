require "../dom/dom"
require "json"
require "time"
require "../runtime/runtime"
require "../page/page"

module Cdp::DOM
  alias NodeId = Int64

  alias BackendNodeId = Int64

  alias StyleSheetId = String

  struct BackendNode
    include JSON::Serializable

    property node_type : Cdp::NodeType
    property node_name : String
    property backend_node_id : BackendNodeId
  end

  alias PseudoType = String

  alias ShadowRootType = String

  alias CompatibilityMode = String

  alias PhysicalAxes = String

  alias LogicalAxes = String

  alias ScrollOrientation = String

  struct Node
    include JSON::Serializable

    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property parent_id : NodeId?
    property backend_node_id : BackendNodeId
    property node_type : Cdp::NodeType
    property node_name : String
    property local_name : String
    property node_value : String
    @[JSON::Field(emit_null: false)]
    property child_node_count : Int64?
    @[JSON::Field(emit_null: false)]
    property children : Array(Node)?
    @[JSON::Field(emit_null: false)]
    property attributes : Array(String)?
    @[JSON::Field(emit_null: false)]
    property document_url : String?
    @[JSON::Field(emit_null: false)]
    property base_url : String?
    @[JSON::Field(emit_null: false)]
    property public_id : String?
    @[JSON::Field(emit_null: false)]
    property system_id : String?
    @[JSON::Field(emit_null: false)]
    property internal_subset : String?
    @[JSON::Field(emit_null: false)]
    property xml_version : String?
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property value : String?
    @[JSON::Field(emit_null: false)]
    property pseudo_type : PseudoType?
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : String?
    @[JSON::Field(emit_null: false)]
    property shadow_root_type : ShadowRootType?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
    @[JSON::Field(emit_null: false)]
    property content_document : Node?
    @[JSON::Field(emit_null: false)]
    property shadow_roots : Array(Node)?
    @[JSON::Field(emit_null: false)]
    property template_content : Node?
    @[JSON::Field(emit_null: false)]
    property pseudo_elements : Array(Node)?
    @[JSON::Field(emit_null: false)]
    property distributed_nodes : Array(BackendNode)?
    @[JSON::Field(emit_null: false)]
    property is_svg : Bool?
    @[JSON::Field(emit_null: false)]
    property compatibility_mode : CompatibilityMode?
    @[JSON::Field(emit_null: false)]
    property assigned_slot : BackendNode?
    @[JSON::Field(emit_null: false)]
    property is_scrollable : Bool?
    @[JSON::Field(emit_null: false)]
    property affected_by_starting_styles : Bool?
    @[JSON::Field(emit_null: false)]
    property adopted_style_sheets : Array(StyleSheetId)?
    property parent : Node?
    property invalidated : Channel(Nil)
    property state : NodeState
    property mutex : Mutex
  end

  struct DetachedElementInfo
    include JSON::Serializable

    property tree_node : Node
    property retained_node_ids : Array(NodeId)
  end

  struct RGBA
    include JSON::Serializable

    property r : Int64
    property g : Int64
    property b : Int64
    @[JSON::Field(emit_null: false)]
    property a : Float64?
  end

  # TODO: Implement type array for DOM.Quad
  alias Quad = JSON::Any

  struct BoxModel
    include JSON::Serializable

    property content : Quad
    property padding : Quad
    property border : Quad
    property margin : Quad
    property width : Int64
    property height : Int64
    @[JSON::Field(emit_null: false)]
    property shape_outside : ShapeOutsideInfo?
  end

  struct ShapeOutsideInfo
    include JSON::Serializable

    property bounds : Quad
    property shape : Array(JSON::Any)
    property margin_shape : Array(JSON::Any)
  end

  struct Rect
    include JSON::Serializable

    property x : Float64
    property y : Float64
    property width : Float64
    property height : Float64
  end

  struct CSSComputedStyleProperty
    include JSON::Serializable

    property name : String
    property value : String
  end

  alias EnableIncludeWhitespace = String

  alias GetElementByRelationRelation = String
end
