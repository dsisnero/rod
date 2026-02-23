require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::CSS
  alias StyleSheetOrigin = String
  StyleSheetOriginInjected  = "injected"
  StyleSheetOriginUserAgent = "user-agent"
  StyleSheetOriginInspector = "inspector"
  StyleSheetOriginRegular   = "regular"

  struct PseudoElementMatches
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property pseudo_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : String?
    @[JSON::Field(emit_null: false)]
    property matches : Array(Cdp::NodeType)
  end

  struct CSSAnimationStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
  end

  struct InheritedStyleEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property inline_style : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property matched_css_rules : Array(Cdp::NodeType)
  end

  struct InheritedAnimatedStyleEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property animation_styles : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property transitions_style : Cdp::NodeType?
  end

  struct InheritedPseudoElementMatches
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property pseudo_elements : Array(Cdp::NodeType)
  end

  struct RuleMatch
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property matching_selectors : Array(Int64)
  end

  struct Value
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property specificity : Cdp::NodeType?
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
    property selectors : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property text : String
  end

  struct CSSStyleSheetHeader
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_url : String
    @[JSON::Field(emit_null: false)]
    property source_map_url : String?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property owner_node : Cdp::NodeType?
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
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property selector_list : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property nesting_selectors : Array(String)?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property origin_tree_scope_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property media : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property container_queries : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property supports : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property layers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property scopes : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property rule_types : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property starting_styles : Array(Cdp::NodeType)?
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
    property style_sheet_id : Cdp::NodeType
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
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property css_properties : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property shorthand_entries : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property css_text : String?
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
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
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property longhand_properties : Array(Cdp::NodeType)?
  end

  struct CSSMedia
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property source : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_url : String?
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property media_list : Array(Cdp::NodeType)?
  end

  struct MediaQuery
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property expressions : Array(Cdp::NodeType)
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
    property value_range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property computed_length : Float64?
  end

  @[Experimental]
  struct CSSContainerQuery
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property physical_axes : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property logical_axes : Cdp::NodeType?
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
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
  end

  @[Experimental]
  struct CSSScope
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
  end

  @[Experimental]
  struct CSSLayer
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
  end

  @[Experimental]
  struct CSSStartingStyle
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
  end

  @[Experimental]
  struct CSSLayerData
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property sub_layers : Array(Cdp::NodeType)?
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
    property font_variation_axes : Array(Cdp::NodeType)?
  end

  struct CSSTryRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
  end

  struct CSSPositionTryRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? active : Bool
  end

  struct CSSKeyframesRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property animation_name : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property keyframes : Array(Cdp::NodeType)
  end

  struct CSSPropertyRegistration
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property property_name : String
    @[JSON::Field(emit_null: false)]
    property initial_value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? inherits : Bool
    @[JSON::Field(emit_null: false)]
    property syntax : String
  end

  struct CSSAtRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property subsection : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property name : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
  end

  struct CSSPropertyRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property property_name : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
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
    property media : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property container_queries : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property supports : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property children : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property condition_text : String
  end

  struct CSSFunctionNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property condition : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType?
  end

  struct CSSFunctionRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property parameters : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property children : Array(Cdp::NodeType)
  end

  struct CSSKeyframeRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key_text : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style : Cdp::NodeType
  end

  struct StyleDeclarationEdit
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
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
