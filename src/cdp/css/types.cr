require "../cdp"
require "json"
require "base64"
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
    @[JSON::Field(key: "pseudoType", emit_null: false)]
    property pseudo_type : Cdp::DOM::PseudoType
    @[JSON::Field(key: "pseudoIdentifier", emit_null: false)]
    property pseudo_identifier : String?
    @[JSON::Field(key: "matches", emit_null: false)]
    property matches : Array(RuleMatch)

    def initialize(@pseudo_type : Cdp::DOM::PseudoType, @matches : Array(RuleMatch), @pseudo_identifier : String? = nil)
    end
  end

  struct CSSAnimationStyle
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String?
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle

    def initialize(@style : CSSStyle, @name : String? = nil)
    end
  end

  struct InheritedStyleEntry
    include JSON::Serializable
    @[JSON::Field(key: "inlineStyle", emit_null: false)]
    property inline_style : CSSStyle?
    @[JSON::Field(key: "matchedCSSRules", emit_null: false)]
    property matched_css_rules : Array(RuleMatch)

    def initialize(@matched_css_rules : Array(RuleMatch), @inline_style : CSSStyle? = nil)
    end
  end

  struct InheritedAnimatedStyleEntry
    include JSON::Serializable
    @[JSON::Field(key: "animationStyles", emit_null: false)]
    property animation_styles : Array(CSSAnimationStyle)?
    @[JSON::Field(key: "transitionsStyle", emit_null: false)]
    property transitions_style : CSSStyle?

    def initialize(@animation_styles : Array(CSSAnimationStyle)? = nil, @transitions_style : CSSStyle? = nil)
    end
  end

  struct InheritedPseudoElementMatches
    include JSON::Serializable
    @[JSON::Field(key: "pseudoElements", emit_null: false)]
    property pseudo_elements : Array(PseudoElementMatches)

    def initialize(@pseudo_elements : Array(PseudoElementMatches))
    end
  end

  struct RuleMatch
    include JSON::Serializable
    @[JSON::Field(key: "rule", emit_null: false)]
    property rule : CSSRule
    @[JSON::Field(key: "matchingSelectors", emit_null: false)]
    property matching_selectors : Array(Int64)

    def initialize(@rule : CSSRule, @matching_selectors : Array(Int64))
    end
  end

  struct Value
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "specificity", emit_null: false)]
    property specificity : Specificity?

    def initialize(@text : String, @range : SourceRange? = nil, @specificity : Specificity? = nil)
    end
  end

  @[Experimental]
  struct SpecificityComponent
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "a", emit_null: false)]
    property a : Int64
    @[JSON::Field(key: "b", emit_null: false)]
    property b : Int64
    @[JSON::Field(key: "c", emit_null: false)]
    property c : Int64

    def initialize(@text : String, @a : Int64, @b : Int64, @c : Int64)
    end
  end

  @[Experimental]
  struct Specificity
    include JSON::Serializable
    @[JSON::Field(key: "a", emit_null: false)]
    property a : Int64
    @[JSON::Field(key: "b", emit_null: false)]
    property b : Int64
    @[JSON::Field(key: "c", emit_null: false)]
    property c : Int64
    @[JSON::Field(key: "components", emit_null: false)]
    property components : Array(SpecificityComponent)?

    def initialize(@a : Int64, @b : Int64, @c : Int64, @components : Array(SpecificityComponent)? = nil)
    end
  end

  struct SelectorList
    include JSON::Serializable
    @[JSON::Field(key: "selectors", emit_null: false)]
    property selectors : Array(Value)
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String

    def initialize(@selectors : Array(Value), @text : String)
    end
  end

  struct CSSStyleSheetHeader
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "sourceURL", emit_null: false)]
    property source_url : String
    @[JSON::Field(key: "sourceMapURL", emit_null: false)]
    property source_map_url : String?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String
    @[JSON::Field(key: "ownerNode", emit_null: false)]
    property owner_node : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "disabled", emit_null: false)]
    property? disabled : Bool
    @[JSON::Field(key: "hasSourceURL", emit_null: false)]
    property? has_source_url : Bool?
    @[JSON::Field(key: "isInline", emit_null: false)]
    property? is_inline : Bool
    @[JSON::Field(key: "isMutable", emit_null: false)]
    property? is_mutable : Bool
    @[JSON::Field(key: "isConstructed", emit_null: false)]
    property? is_constructed : Bool
    @[JSON::Field(key: "startLine", emit_null: false)]
    property start_line : Float64
    @[JSON::Field(key: "startColumn", emit_null: false)]
    property start_column : Float64
    @[JSON::Field(key: "length", emit_null: false)]
    property length : Float64
    @[JSON::Field(key: "endLine", emit_null: false)]
    property end_line : Float64
    @[JSON::Field(key: "endColumn", emit_null: false)]
    property end_column : Float64
    @[JSON::Field(key: "loadingFailed", emit_null: false)]
    property? loading_failed : Bool?

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @frame_id : Cdp::Page::FrameId, @source_url : String, @origin : StyleSheetOrigin, @title : String, @disabled : Bool, @is_inline : Bool, @is_mutable : Bool, @is_constructed : Bool, @start_line : Float64, @start_column : Float64, @length : Float64, @end_line : Float64, @end_column : Float64, @source_map_url : String? = nil, @owner_node : Cdp::DOM::BackendNodeId? = nil, @has_source_url : Bool? = nil, @loading_failed : Bool? = nil)
    end
  end

  struct CSSRule
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "selectorList", emit_null: false)]
    property selector_list : SelectorList
    @[JSON::Field(key: "nestingSelectors", emit_null: false)]
    property nesting_selectors : Array(String)?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle
    @[JSON::Field(key: "originTreeScopeNodeId", emit_null: false)]
    property origin_tree_scope_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "media", emit_null: false)]
    property media : Array(CSSMedia)?
    @[JSON::Field(key: "containerQueries", emit_null: false)]
    property container_queries : Array(CSSContainerQuery)?
    @[JSON::Field(key: "supports", emit_null: false)]
    property supports : Array(CSSSupports)?
    @[JSON::Field(key: "layers", emit_null: false)]
    property layers : Array(CSSLayer)?
    @[JSON::Field(key: "scopes", emit_null: false)]
    property scopes : Array(CSSScope)?
    @[JSON::Field(key: "ruleTypes", emit_null: false)]
    property rule_types : Array(CSSRuleType)?
    @[JSON::Field(key: "startingStyles", emit_null: false)]
    property starting_styles : Array(CSSStartingStyle)?
    @[JSON::Field(key: "navigations", emit_null: false)]
    property navigations : Array(CSSNavigation)?

    def initialize(@selector_list : SelectorList, @origin : StyleSheetOrigin, @style : CSSStyle, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil, @nesting_selectors : Array(String)? = nil, @origin_tree_scope_node_id : Cdp::DOM::BackendNodeId? = nil, @media : Array(CSSMedia)? = nil, @container_queries : Array(CSSContainerQuery)? = nil, @supports : Array(CSSSupports)? = nil, @layers : Array(CSSLayer)? = nil, @scopes : Array(CSSScope)? = nil, @rule_types : Array(CSSRuleType)? = nil, @starting_styles : Array(CSSStartingStyle)? = nil, @navigations : Array(CSSNavigation)? = nil)
    end
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
  CSSRuleTypeNavigationRule    = "NavigationRule"

  struct RuleUsage
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId
    @[JSON::Field(key: "startOffset", emit_null: false)]
    property start_offset : Float64
    @[JSON::Field(key: "endOffset", emit_null: false)]
    property end_offset : Float64
    @[JSON::Field(key: "used", emit_null: false)]
    property? used : Bool

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @start_offset : Float64, @end_offset : Float64, @used : Bool)
    end
  end

  struct SourceRange
    include JSON::Serializable
    @[JSON::Field(key: "startLine", emit_null: false)]
    property start_line : Int64
    @[JSON::Field(key: "startColumn", emit_null: false)]
    property start_column : Int64
    @[JSON::Field(key: "endLine", emit_null: false)]
    property end_line : Int64
    @[JSON::Field(key: "endColumn", emit_null: false)]
    property end_column : Int64

    def initialize(@start_line : Int64, @start_column : Int64, @end_line : Int64, @end_column : Int64)
    end
  end

  struct ShorthandEntry
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "important", emit_null: false)]
    property? important : Bool?

    def initialize(@name : String, @value : String, @important : Bool? = nil)
    end
  end

  struct CSSComputedStyleProperty
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String

    def initialize(@name : String, @value : String)
    end
  end

  @[Experimental]
  struct ComputedStyleExtraFields
    include JSON::Serializable
    @[JSON::Field(key: "isAppearanceBase", emit_null: false)]
    property? is_appearance_base : Bool

    def initialize(@is_appearance_base : Bool)
    end
  end

  struct CSSStyle
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "cssProperties", emit_null: false)]
    property css_properties : Array(CSSProperty)
    @[JSON::Field(key: "shorthandEntries", emit_null: false)]
    property shorthand_entries : Array(ShorthandEntry)
    @[JSON::Field(key: "cssText", emit_null: false)]
    property css_text : String?
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?

    def initialize(@css_properties : Array(CSSProperty), @shorthand_entries : Array(ShorthandEntry), @style_sheet_id : Cdp::DOM::StyleSheetId? = nil, @css_text : String? = nil, @range : SourceRange? = nil)
    end
  end

  class CSSProperty
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "important", emit_null: false)]
    property? important : Bool?
    @[JSON::Field(key: "implicit", emit_null: false)]
    property? implicit : Bool?
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String?
    @[JSON::Field(key: "parsedOk", emit_null: false)]
    property? parsed_ok : Bool?
    @[JSON::Field(key: "disabled", emit_null: false)]
    property? disabled : Bool?
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "longhandProperties", emit_null: false)]
    property longhand_properties : Array(CSSProperty)?

    def initialize(@name : String, @value : String, @important : Bool? = nil, @implicit : Bool? = nil, @text : String? = nil, @parsed_ok : Bool? = nil, @disabled : Bool? = nil, @range : SourceRange? = nil, @longhand_properties : Array(CSSProperty)? = nil)
    end
  end

  struct CSSMedia
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "source", emit_null: false)]
    property source : MediaSource
    @[JSON::Field(key: "sourceURL", emit_null: false)]
    property source_url : String?
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "mediaList", emit_null: false)]
    property media_list : Array(MediaQuery)?

    def initialize(@text : String, @source : MediaSource, @source_url : String? = nil, @range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil, @media_list : Array(MediaQuery)? = nil)
    end
  end

  struct MediaQuery
    include JSON::Serializable
    @[JSON::Field(key: "expressions", emit_null: false)]
    property expressions : Array(MediaQueryExpression)
    @[JSON::Field(key: "active", emit_null: false)]
    property? active : Bool

    def initialize(@expressions : Array(MediaQueryExpression), @active : Bool)
    end
  end

  struct MediaQueryExpression
    include JSON::Serializable
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Float64
    @[JSON::Field(key: "unit", emit_null: false)]
    property unit : String
    @[JSON::Field(key: "feature", emit_null: false)]
    property feature : String
    @[JSON::Field(key: "valueRange", emit_null: false)]
    property value_range : SourceRange?
    @[JSON::Field(key: "computedLength", emit_null: false)]
    property computed_length : Float64?

    def initialize(@value : Float64, @unit : String, @feature : String, @value_range : SourceRange? = nil, @computed_length : Float64? = nil)
    end
  end

  @[Experimental]
  struct CSSContainerQuery
    include JSON::Serializable
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String?
    @[JSON::Field(key: "physicalAxes", emit_null: false)]
    property physical_axes : Cdp::DOM::PhysicalAxes?
    @[JSON::Field(key: "logicalAxes", emit_null: false)]
    property logical_axes : Cdp::DOM::LogicalAxes?
    @[JSON::Field(key: "queriesScrollState", emit_null: false)]
    property? queries_scroll_state : Bool?
    @[JSON::Field(key: "queriesAnchored", emit_null: false)]
    property? queries_anchored : Bool?
    @[JSON::Field(key: "conditionText", emit_null: false)]
    property condition_text : String

    def initialize(@condition_text : String, @range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil, @name : String? = nil, @physical_axes : Cdp::DOM::PhysicalAxes? = nil, @logical_axes : Cdp::DOM::LogicalAxes? = nil, @queries_scroll_state : Bool? = nil, @queries_anchored : Bool? = nil)
    end
  end

  @[Experimental]
  struct CSSSupports
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "active", emit_null: false)]
    property? active : Bool
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?

    def initialize(@text : String, @active : Bool, @range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  @[Experimental]
  struct CSSNavigation
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "active", emit_null: false)]
    property? active : Bool?
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?

    def initialize(@text : String, @active : Bool? = nil, @range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  @[Experimental]
  struct CSSScope
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?

    def initialize(@text : String, @range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  @[Experimental]
  struct CSSLayer
    include JSON::Serializable
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?

    def initialize(@text : String, @range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  @[Experimental]
  struct CSSStartingStyle
    include JSON::Serializable
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?

    def initialize(@range : SourceRange? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  @[Experimental]
  class CSSLayerData
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "subLayers", emit_null: false)]
    property sub_layers : Array(CSSLayerData)?
    @[JSON::Field(key: "order", emit_null: false)]
    property order : Float64

    def initialize(@name : String, @order : Float64, @sub_layers : Array(CSSLayerData)? = nil)
    end
  end

  struct PlatformFontUsage
    include JSON::Serializable
    @[JSON::Field(key: "familyName", emit_null: false)]
    property family_name : String
    @[JSON::Field(key: "postScriptName", emit_null: false)]
    property post_script_name : String
    @[JSON::Field(key: "isCustomFont", emit_null: false)]
    property? is_custom_font : Bool
    @[JSON::Field(key: "glyphCount", emit_null: false)]
    property glyph_count : Float64

    def initialize(@family_name : String, @post_script_name : String, @is_custom_font : Bool, @glyph_count : Float64)
    end
  end

  struct FontVariationAxis
    include JSON::Serializable
    @[JSON::Field(key: "tag", emit_null: false)]
    property tag : String
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "minValue", emit_null: false)]
    property min_value : Float64
    @[JSON::Field(key: "maxValue", emit_null: false)]
    property max_value : Float64
    @[JSON::Field(key: "defaultValue", emit_null: false)]
    property default_value : Float64

    def initialize(@tag : String, @name : String, @min_value : Float64, @max_value : Float64, @default_value : Float64)
    end
  end

  struct FontFace
    include JSON::Serializable
    @[JSON::Field(key: "fontFamily", emit_null: false)]
    property font_family : String
    @[JSON::Field(key: "fontStyle", emit_null: false)]
    property font_style : String
    @[JSON::Field(key: "fontVariant", emit_null: false)]
    property font_variant : String
    @[JSON::Field(key: "fontWeight", emit_null: false)]
    property font_weight : String
    @[JSON::Field(key: "fontStretch", emit_null: false)]
    property font_stretch : String
    @[JSON::Field(key: "fontDisplay", emit_null: false)]
    property font_display : String
    @[JSON::Field(key: "unicodeRange", emit_null: false)]
    property unicode_range : String
    @[JSON::Field(key: "src", emit_null: false)]
    property src : String
    @[JSON::Field(key: "platformFontFamily", emit_null: false)]
    property platform_font_family : String
    @[JSON::Field(key: "fontVariationAxes", emit_null: false)]
    property font_variation_axes : Array(FontVariationAxis)?

    def initialize(@font_family : String, @font_style : String, @font_variant : String, @font_weight : String, @font_stretch : String, @font_display : String, @unicode_range : String, @src : String, @platform_font_family : String, @font_variation_axes : Array(FontVariationAxis)? = nil)
    end
  end

  struct CSSTryRule
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle

    def initialize(@origin : StyleSheetOrigin, @style : CSSStyle, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  struct CSSPositionTryRule
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : Value
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle
    @[JSON::Field(key: "active", emit_null: false)]
    property? active : Bool

    def initialize(@name : Value, @origin : StyleSheetOrigin, @style : CSSStyle, @active : Bool, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  struct CSSKeyframesRule
    include JSON::Serializable
    @[JSON::Field(key: "animationName", emit_null: false)]
    property animation_name : Value
    @[JSON::Field(key: "keyframes", emit_null: false)]
    property keyframes : Array(CSSKeyframeRule)

    def initialize(@animation_name : Value, @keyframes : Array(CSSKeyframeRule))
    end
  end

  struct CSSPropertyRegistration
    include JSON::Serializable
    @[JSON::Field(key: "propertyName", emit_null: false)]
    property property_name : String
    @[JSON::Field(key: "initialValue", emit_null: false)]
    property initial_value : Value?
    @[JSON::Field(key: "inherits", emit_null: false)]
    property? inherits : Bool
    @[JSON::Field(key: "syntax", emit_null: false)]
    property syntax : String

    def initialize(@property_name : String, @inherits : Bool, @syntax : String, @initial_value : Value? = nil)
    end
  end

  struct CSSAtRule
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : CSSAtRuleType
    @[JSON::Field(key: "subsection", emit_null: false)]
    property subsection : CSSAtRuleSubsection?
    @[JSON::Field(key: "name", emit_null: false)]
    property name : Value?
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle

    def initialize(@type : CSSAtRuleType, @origin : StyleSheetOrigin, @style : CSSStyle, @subsection : CSSAtRuleSubsection? = nil, @name : Value? = nil, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  struct CSSPropertyRule
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "propertyName", emit_null: false)]
    property property_name : Value
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle

    def initialize(@origin : StyleSheetOrigin, @property_name : Value, @style : CSSStyle, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  struct CSSFunctionParameter
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String

    def initialize(@name : String, @type : String)
    end
  end

  class CSSFunctionConditionNode
    include JSON::Serializable
    @[JSON::Field(key: "media", emit_null: false)]
    property media : CSSMedia?
    @[JSON::Field(key: "containerQueries", emit_null: false)]
    property container_queries : CSSContainerQuery?
    @[JSON::Field(key: "supports", emit_null: false)]
    property supports : CSSSupports?
    @[JSON::Field(key: "navigation", emit_null: false)]
    property navigation : CSSNavigation?
    @[JSON::Field(key: "children", emit_null: false)]
    property children : Array(CSSFunctionNode)
    @[JSON::Field(key: "conditionText", emit_null: false)]
    property condition_text : String

    def initialize(@children : Array(CSSFunctionNode), @condition_text : String, @media : CSSMedia? = nil, @container_queries : CSSContainerQuery? = nil, @supports : CSSSupports? = nil, @navigation : CSSNavigation? = nil)
    end
  end

  class CSSFunctionNode
    include JSON::Serializable
    @[JSON::Field(key: "condition", emit_null: false)]
    property condition : CSSFunctionConditionNode?
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle?

    def initialize(@condition : CSSFunctionConditionNode? = nil, @style : CSSStyle? = nil)
    end
  end

  struct CSSFunctionRule
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : Value
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "parameters", emit_null: false)]
    property parameters : Array(CSSFunctionParameter)
    @[JSON::Field(key: "children", emit_null: false)]
    property children : Array(CSSFunctionNode)
    @[JSON::Field(key: "originTreeScopeNodeId", emit_null: false)]
    property origin_tree_scope_node_id : Cdp::DOM::BackendNodeId?

    def initialize(@name : Value, @origin : StyleSheetOrigin, @parameters : Array(CSSFunctionParameter), @children : Array(CSSFunctionNode), @style_sheet_id : Cdp::DOM::StyleSheetId? = nil, @origin_tree_scope_node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end

  struct CSSKeyframeRule
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId?
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : StyleSheetOrigin
    @[JSON::Field(key: "keyText", emit_null: false)]
    property key_text : Value
    @[JSON::Field(key: "style", emit_null: false)]
    property style : CSSStyle

    def initialize(@origin : StyleSheetOrigin, @key_text : Value, @style : CSSStyle, @style_sheet_id : Cdp::DOM::StyleSheetId? = nil)
    end
  end

  struct StyleDeclarationEdit
    include JSON::Serializable
    @[JSON::Field(key: "styleSheetId", emit_null: false)]
    property style_sheet_id : Cdp::DOM::StyleSheetId
    @[JSON::Field(key: "range", emit_null: false)]
    property range : SourceRange
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @text : String)
    end
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
  CSSAtRuleTypeCounterStyle      = "counter-style"

  alias CSSAtRuleSubsection = String
  CSSAtRuleSubsectionSwash            = "swash"
  CSSAtRuleSubsectionAnnotation       = "annotation"
  CSSAtRuleSubsectionOrnaments        = "ornaments"
  CSSAtRuleSubsectionStylistic        = "stylistic"
  CSSAtRuleSubsectionStyleset         = "styleset"
  CSSAtRuleSubsectionCharacterVariant = "character-variant"
end
