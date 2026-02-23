require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"

module Cdp::CSS
  alias StyleSheetOrigin = String
  StyleSheetOriginInjected  = "injected"
  StyleSheetOriginUserAgent = "user-agent"
  StyleSheetOriginInspector = "inspector"
  StyleSheetOriginRegular   = "regular"

  struct PseudoElementMatches
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property pseudo_type : Cdp::DOM::PseudoType
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : String?
    @[JSON::Field(emit_null: false)]
    property matches : Array(RuleMatch)
  end

  struct CSSAnimationStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle
  end

  struct InheritedStyleEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property inline_style : CSSStyle?
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property pseudo_elements : Array(PseudoElementMatches)
  end

  struct RuleMatch
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule : CSSRule
    @[JSON::Field(emit_null: false)]
    property matching_selectors : Array(Int64)
  end

  struct Value
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property specificity : Specificity?
  end

  @[Experimental]
  struct Specificity
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property a : Int64
    @[JSON::Field(emit_null: false)]
    property b : Int64
    @[JSON::Field(emit_null: false)]
    property c : Int64
  end

  struct SelectorList
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property selectors : Array(Value)
    @[JSON::Field(emit_null: false)]
    property text : String
  end

  struct CSSStyleSheetHeader
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property source_url : String
    @[JSON::Field(emit_null: false)]
    property source_map_url : String?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property owner_node : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property? disabled : Bool
    @[JSON::Field(emit_null: false)]
    property? has_source_url : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_inline : Bool
    @[JSON::Field(emit_null: false)]
    property? is_mutable : Bool
    @[JSON::Field(emit_null: false)]
    property? is_constructed : Bool
    @[JSON::Field(emit_null: false)]
    property start_line : Float64
    @[JSON::Field(emit_null: false)]
    property start_column : Float64
    @[JSON::Field(emit_null: false)]
    property length : Float64
    @[JSON::Field(emit_null: false)]
    property end_line : Float64
    @[JSON::Field(emit_null: false)]
    property end_column : Float64
    @[JSON::Field(emit_null: false)]
    property? loading_failed : Bool?
  end

  struct CSSRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property selector_list : SelectorList
    @[JSON::Field(emit_null: false)]
    property nesting_selectors : Array(String)?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
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
  CSSRuleTypeMediaRule         = "MediaRule"
  CSSRuleTypeSupportsRule      = "SupportsRule"
  CSSRuleTypeContainerRule     = "ContainerRule"
  CSSRuleTypeLayerRule         = "LayerRule"
  CSSRuleTypeScopeRule         = "ScopeRule"
  CSSRuleTypeStyleRule         = "StyleRule"
  CSSRuleTypeStartingStyleRule = "StartingStyleRule"

  struct RuleUsage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId
    @[JSON::Field(emit_null: false)]
    property start_offset : Float64
    @[JSON::Field(emit_null: false)]
    property end_offset : Float64
    @[JSON::Field(emit_null: false)]
    property? used : Bool
  end

  struct SourceRange
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property start_line : Int64
    @[JSON::Field(emit_null: false)]
    property start_column : Int64
    @[JSON::Field(emit_null: false)]
    property end_line : Int64
    @[JSON::Field(emit_null: false)]
    property end_column : Int64
  end

  struct ShorthandEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property? important : Bool?
  end

  struct CSSComputedStyleProperty
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  @[Experimental]
  struct ComputedStyleExtraFields
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? is_appearance_base : Bool
  end

  struct CSSStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property css_properties : Array(CSSProperty)
    @[JSON::Field(emit_null: false)]
    property shorthand_entries : Array(ShorthandEntry)
    @[JSON::Field(emit_null: false)]
    property css_text : String?
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
  end

  struct CSSProperty
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property? important : Bool?
    @[JSON::Field(emit_null: false)]
    property? implicit : Bool?
    @[JSON::Field(emit_null: false)]
    property text : String?
    @[JSON::Field(emit_null: false)]
    property? parsed_ok : Bool?
    @[JSON::Field(emit_null: false)]
    property? disabled : Bool?
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property longhand_properties : Array(CSSProperty)?
  end

  struct CSSMedia
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property expressions : Array(MediaQueryExpression)
    @[JSON::Field(emit_null: false)]
    property? active : Bool
  end

  struct MediaQueryExpression
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property value : Float64
    @[JSON::Field(emit_null: false)]
    property unit : String
    @[JSON::Field(emit_null: false)]
    property feature : String
    @[JSON::Field(emit_null: false)]
    property value_range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property computed_length : Float64?
  end

  @[Experimental]
  struct CSSContainerQuery
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
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
    property? queries_scroll_state : Bool?
    @[JSON::Field(emit_null: false)]
    property? queries_anchored : Bool?
  end

  @[Experimental]
  struct CSSSupports
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property? active : Bool
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
  end

  @[Experimental]
  struct CSSScope
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
  end

  @[Experimental]
  struct CSSLayer
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property sub_layers : Array(CSSLayerData)?
    @[JSON::Field(emit_null: false)]
    property order : Float64
  end

  struct PlatformFontUsage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property family_name : String
    @[JSON::Field(emit_null: false)]
    property post_script_name : String
    @[JSON::Field(emit_null: false)]
    property? is_custom_font : Bool
    @[JSON::Field(emit_null: false)]
    property glyph_count : Float64
  end

  struct FontVariationAxis
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property tag : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property min_value : Float64
    @[JSON::Field(emit_null: false)]
    property max_value : Float64
    @[JSON::Field(emit_null: false)]
    property default_value : Float64
  end

  struct FontFace
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property font_family : String
    @[JSON::Field(emit_null: false)]
    property font_style : String
    @[JSON::Field(emit_null: false)]
    property font_variant : String
    @[JSON::Field(emit_null: false)]
    property font_weight : String
    @[JSON::Field(emit_null: false)]
    property font_stretch : String
    @[JSON::Field(emit_null: false)]
    property font_display : String
    @[JSON::Field(emit_null: false)]
    property unicode_range : String
    @[JSON::Field(emit_null: false)]
    property src : String
    @[JSON::Field(emit_null: false)]
    property platform_font_family : String
    @[JSON::Field(emit_null: false)]
    property font_variation_axes : Array(FontVariationAxis)?
  end

  struct CSSTryRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle
  end

  struct CSSPositionTryRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : Value
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle
    @[JSON::Field(emit_null: false)]
    property? active : Bool
  end

  struct CSSKeyframesRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property animation_name : Value
    @[JSON::Field(emit_null: false)]
    property keyframes : Array(CSSKeyframeRule)
  end

  struct CSSPropertyRegistration
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property property_name : String
    @[JSON::Field(emit_null: false)]
    property initial_value : Value?
    @[JSON::Field(emit_null: false)]
    property? inherits : Bool
    @[JSON::Field(emit_null: false)]
    property syntax : String
  end

  struct CSSAtRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : CSSAtRuleType
    @[JSON::Field(emit_null: false)]
    property subsection : CSSAtRuleSubsection?
    @[JSON::Field(emit_null: false)]
    property name : Value?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle
  end

  struct CSSPropertyRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property property_name : Value
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle
  end

  struct CSSFunctionParameter
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property children : Array(CSSFunctionNode)
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property name : Value
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property parameters : Array(CSSFunctionParameter)
    @[JSON::Field(emit_null: false)]
    property children : Array(CSSFunctionNode)
  end

  struct CSSKeyframeRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(emit_null: false)]
    property key_text : Value
    @[JSON::Field(emit_null: false)]
    property style : CSSStyle
  end

  struct StyleDeclarationEdit
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId
    @[JSON::Field(emit_null: false)]
    property range : SourceRange
    @[JSON::Field(emit_null: false)]
    property text : String
  end

  alias MediaSource = String
  MediaSourceMediaRule   = "mediaRule"
  MediaSourceImportRule  = "importRule"
  MediaSourceLinkedSheet = "linkedSheet"
  MediaSourceInlineSheet = "inlineSheet"

  alias CSSAtRuleType = String
  CSSAtRuleTypeFontFace          = "font-face"
  CSSAtRuleTypeFontFeatureValues = "font-feature-values"
  CSSAtRuleTypeFontPaletteValues = "font-palette-values"

  alias CSSAtRuleSubsection = String
  CSSAtRuleSubsectionSwash            = "swash"
  CSSAtRuleSubsectionAnnotation       = "annotation"
  CSSAtRuleSubsectionOrnaments        = "ornaments"
  CSSAtRuleSubsectionStylistic        = "stylistic"
  CSSAtRuleSubsectionStyleset         = "styleset"
  CSSAtRuleSubsectionCharacterVariant = "character-variant"
end
