require "../cdp"
require "json"
require "time"

require "../page/page"
require "../runtime/runtime"

module Cdp::DOM
  alias NodeId = Int64

  alias BackendNodeId = Int64

  alias StyleSheetId = String

  struct BackendNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_name : String
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId
  end

  alias PseudoType = String
  PseudoTypeFirstLine                   = "first-line"
  PseudoTypeFirstLetter                 = "first-letter"
  PseudoTypeCheckmark                   = "checkmark"
  PseudoTypeBefore                      = "before"
  PseudoTypeAfter                       = "after"
  PseudoTypePickerIcon                  = "picker-icon"
  PseudoTypeInterestHint                = "interest-hint"
  PseudoTypeMarker                      = "marker"
  PseudoTypeBackdrop                    = "backdrop"
  PseudoTypeColumn                      = "column"
  PseudoTypeSelection                   = "selection"
  PseudoTypeSearchText                  = "search-text"
  PseudoTypeTargetText                  = "target-text"
  PseudoTypeSpellingError               = "spelling-error"
  PseudoTypeGrammarError                = "grammar-error"
  PseudoTypeHighlight                   = "highlight"
  PseudoTypeFirstLineInherited          = "first-line-inherited"
  PseudoTypeScrollMarker                = "scroll-marker"
  PseudoTypeScrollMarkerGroup           = "scroll-marker-group"
  PseudoTypeScrollButton                = "scroll-button"
  PseudoTypeScrollbar                   = "scrollbar"
  PseudoTypeScrollbarThumb              = "scrollbar-thumb"
  PseudoTypeScrollbarButton             = "scrollbar-button"
  PseudoTypeScrollbarTrack              = "scrollbar-track"
  PseudoTypeScrollbarTrackPiece         = "scrollbar-track-piece"
  PseudoTypeScrollbarCorner             = "scrollbar-corner"
  PseudoTypeResizer                     = "resizer"
  PseudoTypeInputListButton             = "input-list-button"
  PseudoTypeViewTransition              = "view-transition"
  PseudoTypeViewTransitionGroup         = "view-transition-group"
  PseudoTypeViewTransitionImagePair     = "view-transition-image-pair"
  PseudoTypeViewTransitionGroupChildren = "view-transition-group-children"
  PseudoTypeViewTransitionOld           = "view-transition-old"
  PseudoTypeViewTransitionNew           = "view-transition-new"
  PseudoTypePlaceholder                 = "placeholder"
  PseudoTypeFileSelectorButton          = "file-selector-button"
  PseudoTypeDetailsContent              = "details-content"
  PseudoTypePicker                      = "picker"
  PseudoTypePermissionIcon              = "permission-icon"
  PseudoTypeOverscrollAreaParent        = "overscroll-area-parent"

  alias ShadowRootType = String
  ShadowRootTypeUserAgent = "user-agent"
  ShadowRootTypeOpen      = "open"
  ShadowRootTypeClosed    = "closed"

  alias CompatibilityMode = String
  CompatibilityModeQuirksMode        = "QuirksMode"
  CompatibilityModeLimitedQuirksMode = "LimitedQuirksMode"
  CompatibilityModeNoQuirksMode      = "NoQuirksMode"

  alias PhysicalAxes = String
  PhysicalAxesHorizontal = "Horizontal"
  PhysicalAxesVertical   = "Vertical"
  PhysicalAxesBoth       = "Both"

  alias LogicalAxes = String
  LogicalAxesInline = "Inline"
  LogicalAxesBlock  = "Block"
  LogicalAxesBoth   = "Both"

  alias ScrollOrientation = String
  ScrollOrientationHorizontal = "horizontal"
  ScrollOrientationVertical   = "vertical"

  class Node
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property parent_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property backend_node_id : BackendNodeId
    @[JSON::Field(emit_null: false)]
    property node_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_name : String
    @[JSON::Field(emit_null: false)]
    property local_name : String
    @[JSON::Field(emit_null: false)]
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
    property imported_document : Node?
    @[JSON::Field(emit_null: false)]
    property distributed_nodes : Array(BackendNode)?
    @[JSON::Field(emit_null: false)]
    property? is_svg : Bool?
    @[JSON::Field(emit_null: false)]
    property compatibility_mode : CompatibilityMode?
    @[JSON::Field(emit_null: false)]
    property assigned_slot : BackendNode?
    @[JSON::Field(emit_null: false)]
    property? is_scrollable : Bool?
    @[JSON::Field(emit_null: false)]
    property? affected_by_starting_styles : Bool?
    @[JSON::Field(emit_null: false)]
    property adopted_style_sheets : Array(StyleSheetId)?
    @[JSON::Field(emit_null: false)]
    property parent : DOM::Node?
    @[JSON::Field(emit_null: false)]
    property invalidated : Channel(Nil)
    @[JSON::Field(emit_null: false)]
    property state : NodeState
    @[JSON::Field(emit_null: false)]
    property mutex : Mutex

    # AttributeValue returns the named attribute for the node.
    def attribute_value(name : String) : String
      value = attribute(name)
      value || ""
    end

    # Attribute returns the named attribute for the node and if it exists.
    def attribute(name : String) : String?
      if attrs = @attributes
        attrs.each_slice(2) do |pair|
          if pair[0] == name
            return pair[1]
          end
        end
      end
      nil
    end
  end

  # NodeState is the state of a DOM node.
  @[Flags]
  enum NodeState : UInt8
    # Node state flags
    NodeReady           = 1 << 7
    NodeChildReady      = 1 << 6
    NodeDescendantReady = 1 << 5
    NodeAttached        = 1 << 4
    NodeHasShadowRoot   = 1 << 3
    NodeMutated         = 1 << 2
  end

  struct DetachedElementInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property tree_node : Node
    @[JSON::Field(emit_null: false)]
    property retained_node_ids : Array(NodeId)
  end

  struct RGBA
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property r : Int64
    @[JSON::Field(emit_null: false)]
    property g : Int64
    @[JSON::Field(emit_null: false)]
    property b : Int64
    @[JSON::Field(emit_null: false)]
    property a : Float64?
  end

  # TODO: Implement type array for DOM.Quad
  alias Quad = JSON::Any

  struct BoxModel
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property content : Quad
    @[JSON::Field(emit_null: false)]
    property padding : Quad
    @[JSON::Field(emit_null: false)]
    property border : Quad
    @[JSON::Field(emit_null: false)]
    property margin : Quad
    @[JSON::Field(emit_null: false)]
    property width : Int64
    @[JSON::Field(emit_null: false)]
    property height : Int64
    @[JSON::Field(emit_null: false)]
    property shape_outside : ShapeOutsideInfo?
  end

  struct ShapeOutsideInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property bounds : Quad
    @[JSON::Field(emit_null: false)]
    property shape : Array(JSON::Any)
    @[JSON::Field(emit_null: false)]
    property margin_shape : Array(JSON::Any)
  end

  struct Rect
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property x : Float64
    @[JSON::Field(emit_null: false)]
    property y : Float64
    @[JSON::Field(emit_null: false)]
    property width : Float64
    @[JSON::Field(emit_null: false)]
    property height : Float64
  end

  struct CSSComputedStyleProperty
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  alias EnableIncludeWhitespace = String
  EnableIncludeWhitespaceNone = "none"
  EnableIncludeWhitespaceAll  = "all"

  alias GetElementByRelationRelation = String
  GetElementByRelationRelationPopoverTarget  = "PopoverTarget"
  GetElementByRelationRelationInterestTarget = "InterestTarget"
  GetElementByRelationRelationCommandFor     = "CommandFor"
end
