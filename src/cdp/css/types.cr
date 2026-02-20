require "../css/css"
require "json"
require "time"
require "../dom/dom"
require "../page/page"

module Cdp::CSS
  alias StyleSheetOrigin = String

  struct PseudoElementMatches
    include JSON::Serializable

    property pseudo_type : Cdp::DOM::PseudoType
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : String?
    property matches : Array(RuleMatch)
  end

  struct CSSAnimationStyle
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property name : String?
    property style : CSSStyle
  end

  struct InheritedStyleEntry
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property inline_style : CSSStyle?
    property matched_css_rules : Array(RuleMatch)
  end

  struct InheritedAnimatedStyleEntry
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property animation_styles : Array(CSSAnimationStyle)?
    @[JSON::Field(emit_null: false)]
    property transitions_style : CSSStyle?
  end

  struct InheritedPseudoElementMatches
    include JSON::Serializable

    property pseudo_elements : Array(PseudoElementMatches)
  end

  struct RuleMatch
    include JSON::Serializable

    property rule : CSSRule
    property matching_selectors : Array(Int64)
  end

  struct Value
    include JSON::Serializable

    property text : String
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property specificity : Specificity?
  end

  @[Experimental]
  struct Specificity
    include JSON::Serializable

    property a : Int64
    property b : Int64
    property c : Int64
  end

  struct SelectorList
    include JSON::Serializable

    property selectors : Array(Value)
    property text : String
  end

  struct CSSStyleSheetHeader
    include JSON::Serializable

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property frame_id : Cdp::Page::FrameId
    property source_url : String
    @[JSON::Field(emit_null: false)]
    property source_map_url : String?
    property origin : StyleSheetOrigin
    property title : String
    @[JSON::Field(emit_null: false)]
    property owner_node : Cdp::DOM::BackendNodeId?
    property disabled : Bool
    @[JSON::Field(emit_null: false)]
    property has_source_url : Bool?
    property is_inline : Bool
    property is_mutable : Bool
    property is_constructed : Bool
    property start_line : Float64
    property start_column : Float64
    property length : Float64
    property end_line : Float64
    property end_column : Float64
    @[JSON::Field(emit_null: false)]
    property loading_failed : Bool?
  end

  struct CSSRule
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property selector_list : SelectorList
    @[JSON::Field(emit_null: false)]
    property nesting_selectors : Array(String)?
    property origin : StyleSheetOrigin
    property style : CSSStyle
    @[JSON::Field(emit_null: false)]
    property origin_tree_scope_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property media : Array(CSSMedia)?
    @[JSON::Field(emit_null: false)]
    property container_queries : Array(CSSContainerQuery)?
    @[JSON::Field(emit_null: false)]
    property supports : Array(CSSSupports)?
    @[JSON::Field(emit_null: false)]
    property layers : Array(CSSLayer)?
    @[JSON::Field(emit_null: false)]
    property scopes : Array(CSSScope)?
    @[JSON::Field(emit_null: false)]
    property rule_types : Array(CSSRuleType)?
    @[JSON::Field(emit_null: false)]
    property starting_styles : Array(CSSStartingStyle)?
  end

  @[Experimental]
  alias CSSRuleType = String

  struct RuleUsage
    include JSON::Serializable

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property start_offset : Float64
    property end_offset : Float64
    property used : Bool
  end

  struct SourceRange
    include JSON::Serializable

    property start_line : Int64
    property start_column : Int64
    property end_line : Int64
    property end_column : Int64
  end

  struct ShorthandEntry
    include JSON::Serializable

    property name : String
    property value : String
    @[JSON::Field(emit_null: false)]
    property important : Bool?
  end

  struct CSSComputedStyleProperty
    include JSON::Serializable

    property name : String
    property value : String
  end

  @[Experimental]
  struct ComputedStyleExtraFields
    include JSON::Serializable

    property is_appearance_base : Bool
  end

  struct CSSStyle
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property css_properties : Array(CSSProperty)
    property shorthand_entries : Array(ShorthandEntry)
    @[JSON::Field(emit_null: false)]
    property css_text : String?
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
  end

  struct CSSProperty
    include JSON::Serializable

    property name : String
    property value : String
    @[JSON::Field(emit_null: false)]
    property important : Bool?
    @[JSON::Field(emit_null: false)]
    property implicit : Bool?
    @[JSON::Field(emit_null: false)]
    property text : String?
    @[JSON::Field(emit_null: false)]
    property parsed_ok : Bool?
    @[JSON::Field(emit_null: false)]
    property disabled : Bool?
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property longhand_properties : Array(CSSProperty)?
  end

  struct CSSMedia
    include JSON::Serializable

    property text : String
    property source : MediaSource
    @[JSON::Field(emit_null: false)]
    property source_url : String?
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property media_list : Array(MediaQuery)?
  end

  struct MediaQuery
    include JSON::Serializable

    property expressions : Array(MediaQueryExpression)
    property active : Bool
  end

  struct MediaQueryExpression
    include JSON::Serializable

    property value : Float64
    property unit : String
    property feature : String
    @[JSON::Field(emit_null: false)]
    property value_range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property computed_length : Float64?
  end

  @[Experimental]
  struct CSSContainerQuery
    include JSON::Serializable

    property text : String
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property physical_axes : Cdp::DOM::PhysicalAxes?
    @[JSON::Field(emit_null: false)]
    property logical_axes : Cdp::DOM::LogicalAxes?
    @[JSON::Field(emit_null: false)]
    property queries_scroll_state : Bool?
    @[JSON::Field(emit_null: false)]
    property queries_anchored : Bool?
  end

  @[Experimental]
  struct CSSSupports
    include JSON::Serializable

    property text : String
    property active : Bool
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
  end

  @[Experimental]
  struct CSSScope
    include JSON::Serializable

    property text : String
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
  end

  @[Experimental]
  struct CSSLayer
    include JSON::Serializable

    property text : String
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
  end

  @[Experimental]
  struct CSSStartingStyle
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
  end

  @[Experimental]
  struct CSSLayerData
    include JSON::Serializable

    property name : String
    @[JSON::Field(emit_null: false)]
    property sub_layers : Array(CSSLayerData)?
    property order : Float64
  end

  struct PlatformFontUsage
    include JSON::Serializable

    property family_name : String
    property post_script_name : String
    property is_custom_font : Bool
    property glyph_count : Float64
  end

  struct FontVariationAxis
    include JSON::Serializable

    property tag : String
    property name : String
    property min_value : Float64
    property max_value : Float64
    property default_value : Float64
  end

  struct FontFace
    include JSON::Serializable

    property font_family : String
    property font_style : String
    property font_variant : String
    property font_weight : String
    property font_stretch : String
    property font_display : String
    property unicode_range : String
    property src : String
    property platform_font_family : String
    @[JSON::Field(emit_null: false)]
    property font_variation_axes : Array(FontVariationAxis)?
  end

  struct CSSTryRule
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property origin : StyleSheetOrigin
    property style : CSSStyle
  end

  struct CSSPositionTryRule
    include JSON::Serializable

    property name : Value
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property origin : StyleSheetOrigin
    property style : CSSStyle
    property active : Bool
  end

  struct CSSKeyframesRule
    include JSON::Serializable

    property animation_name : Value
    property keyframes : Array(CSSKeyframeRule)
  end

  struct CSSPropertyRegistration
    include JSON::Serializable

    property property_name : String
    @[JSON::Field(emit_null: false)]
    property initial_value : Value?
    property inherits : Bool
    property syntax : String
  end

  struct CSSAtRule
    include JSON::Serializable

    property type : CSSAtRuleType
    @[JSON::Field(emit_null: false)]
    property subsection : CSSAtRuleSubsection?
    @[JSON::Field(emit_null: false)]
    property name : Value?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property origin : StyleSheetOrigin
    property style : CSSStyle
  end

  struct CSSPropertyRule
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property origin : StyleSheetOrigin
    property property_name : Value
    property style : CSSStyle
  end

  struct CSSFunctionParameter
    include JSON::Serializable

    property name : String
    property type : String
  end

  struct CSSFunctionConditionNode
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property media : CSSMedia?
    @[JSON::Field(emit_null: false)]
    property container_queries : CSSContainerQuery?
    @[JSON::Field(emit_null: false)]
    property supports : CSSSupports?
    property children : Array(CSSFunctionNode)
    property condition_text : String
  end

  struct CSSFunctionNode
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property condition : CSSFunctionConditionNode?
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle?
  end

  struct CSSFunctionRule
    include JSON::Serializable

    property name : Value
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property origin : StyleSheetOrigin
    property parameters : Array(CSSFunctionParameter)
    property children : Array(CSSFunctionNode)
  end

  struct CSSKeyframeRule
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    property origin : StyleSheetOrigin
    property key_text : Value
    property style : CSSStyle
  end

  struct StyleDeclarationEdit
    include JSON::Serializable

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property text : String
  end

  alias MediaSource = String

  alias CSSAtRuleType = String

  alias CSSAtRuleSubsection = String
end
