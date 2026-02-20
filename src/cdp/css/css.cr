require "json"
require "../cdp"
require "../dom/dom"
require "../page/page"
require "./types"

# This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
# have an associated `id` used in subsequent operations on the related object. Each object type has
# a specific `id` structure, and those are not interchangeable between objects of different kinds.
# CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
# can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
# subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
@[Experimental]
module Cdp::CSS
  # Commands
  struct AddRule
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property rule_text : String
    property location : SourceRange
    @[JSON::Field(emit_null: false)]
    property node_for_property_syntax_validation : Cdp::DOM::NodeId?

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @rule_text : String, @location : SourceRange, @node_for_property_syntax_validation : Cdp::DOM::NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.addRule"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddRuleResult
      res = AddRuleResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct AddRuleResult
    include JSON::Serializable

    property rule : CSSRule

    def initialize(@rule : CSSRule)
    end
  end

  struct CollectClassNames
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.collectClassNames"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CollectClassNamesResult
      res = CollectClassNamesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CollectClassNamesResult
    include JSON::Serializable

    property class_names : Array(String)

    def initialize(@class_names : Array(String))
    end
  end

  struct CreateStyleSheet
    include JSON::Serializable
    include Cdp::Request

    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property force : Bool?

    def initialize(@frame_id : Cdp::Page::FrameId, @force : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.createStyleSheet"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CreateStyleSheetResult
      res = CreateStyleSheetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CreateStyleSheetResult
    include JSON::Serializable

    property style_sheet_id : Cdp::DOM::StyleSheetId

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ForcePseudoState
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId
    property forced_pseudo_classes : Array(String)

    def initialize(@node_id : Cdp::DOM::NodeId, @forced_pseudo_classes : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.forcePseudoState"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ForceStartingStyle
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId
    property forced : Bool

    def initialize(@node_id : Cdp::DOM::NodeId, @forced : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.forceStartingStyle"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetBackgroundColors
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getBackgroundColors"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBackgroundColorsResult
      res = GetBackgroundColorsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetBackgroundColorsResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property background_colors : Array(String)?
    @[JSON::Field(emit_null: false)]
    property computed_font_size : String?
    @[JSON::Field(emit_null: false)]
    property computed_font_weight : String?

    def initialize(@background_colors : Array(String)?, @computed_font_size : String?, @computed_font_weight : String?)
    end
  end

  struct GetComputedStyleForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getComputedStyleForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetComputedStyleForNodeResult
      res = GetComputedStyleForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetComputedStyleForNodeResult
    include JSON::Serializable

    property computed_style : Array(CSSComputedStyleProperty)
    property extra_fields : ComputedStyleExtraFields

    def initialize(@computed_style : Array(CSSComputedStyleProperty), @extra_fields : ComputedStyleExtraFields)
    end
  end

  @[Experimental]
  struct ResolveValues
    include JSON::Serializable
    include Cdp::Request

    property values : Array(String)
    property node_id : Cdp::DOM::NodeId
    @[JSON::Field(emit_null: false)]
    property property_name : String?
    @[JSON::Field(emit_null: false)]
    property pseudo_type : Cdp::DOM::PseudoType?
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : String?

    def initialize(@values : Array(String), @node_id : Cdp::DOM::NodeId, @property_name : String?, @pseudo_type : Cdp::DOM::PseudoType?, @pseudo_identifier : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.resolveValues"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ResolveValuesResult
      res = ResolveValuesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct ResolveValuesResult
    include JSON::Serializable

    property results : Array(String)

    def initialize(@results : Array(String))
    end
  end

  @[Experimental]
  struct GetLonghandProperties
    include JSON::Serializable
    include Cdp::Request

    property shorthand_name : String
    property value : String

    def initialize(@shorthand_name : String, @value : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getLonghandProperties"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetLonghandPropertiesResult
      res = GetLonghandPropertiesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetLonghandPropertiesResult
    include JSON::Serializable

    property longhand_properties : Array(CSSProperty)

    def initialize(@longhand_properties : Array(CSSProperty))
    end
  end

  struct GetInlineStylesForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getInlineStylesForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetInlineStylesForNodeResult
      res = GetInlineStylesForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetInlineStylesForNodeResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property inline_style : CSSStyle?
    @[JSON::Field(emit_null: false)]
    property attributes_style : CSSStyle?

    def initialize(@inline_style : CSSStyle?, @attributes_style : CSSStyle?)
    end
  end

  @[Experimental]
  struct GetAnimatedStylesForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getAnimatedStylesForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAnimatedStylesForNodeResult
      res = GetAnimatedStylesForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAnimatedStylesForNodeResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property animation_styles : Array(CSSAnimationStyle)?
    @[JSON::Field(emit_null: false)]
    property transitions_style : CSSStyle?
    @[JSON::Field(emit_null: false)]
    property inherited : Array(InheritedAnimatedStyleEntry)?

    def initialize(@animation_styles : Array(CSSAnimationStyle)?, @transitions_style : CSSStyle?, @inherited : Array(InheritedAnimatedStyleEntry)?)
    end
  end

  struct GetMatchedStylesForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getMatchedStylesForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetMatchedStylesForNodeResult
      res = GetMatchedStylesForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetMatchedStylesForNodeResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property inline_style : CSSStyle?
    @[JSON::Field(emit_null: false)]
    property attributes_style : CSSStyle?
    @[JSON::Field(emit_null: false)]
    property matched_css_rules : Array(RuleMatch)?
    @[JSON::Field(emit_null: false)]
    property pseudo_elements : Array(PseudoElementMatches)?
    @[JSON::Field(emit_null: false)]
    property inherited : Array(InheritedStyleEntry)?
    @[JSON::Field(emit_null: false)]
    property inherited_pseudo_elements : Array(InheritedPseudoElementMatches)?
    @[JSON::Field(emit_null: false)]
    property css_keyframes_rules : Array(CSSKeyframesRule)?
    @[JSON::Field(emit_null: false)]
    property css_position_try_rules : Array(CSSPositionTryRule)?
    @[JSON::Field(emit_null: false)]
    property active_position_fallback_index : Int64?
    @[JSON::Field(emit_null: false)]
    property css_property_rules : Array(CSSPropertyRule)?
    @[JSON::Field(emit_null: false)]
    property css_property_registrations : Array(CSSPropertyRegistration)?
    @[JSON::Field(emit_null: false)]
    property css_at_rules : Array(CSSAtRule)?
    @[JSON::Field(emit_null: false)]
    property parent_layout_node_id : Cdp::DOM::NodeId?
    @[JSON::Field(emit_null: false)]
    property css_function_rules : Array(CSSFunctionRule)?

    def initialize(@inline_style : CSSStyle?, @attributes_style : CSSStyle?, @matched_css_rules : Array(RuleMatch)?, @pseudo_elements : Array(PseudoElementMatches)?, @inherited : Array(InheritedStyleEntry)?, @inherited_pseudo_elements : Array(InheritedPseudoElementMatches)?, @css_keyframes_rules : Array(CSSKeyframesRule)?, @css_position_try_rules : Array(CSSPositionTryRule)?, @active_position_fallback_index : Int64?, @css_property_rules : Array(CSSPropertyRule)?, @css_property_registrations : Array(CSSPropertyRegistration)?, @css_at_rules : Array(CSSAtRule)?, @parent_layout_node_id : Cdp::DOM::NodeId?, @css_function_rules : Array(CSSFunctionRule)?)
    end
  end

  @[Experimental]
  struct GetEnvironmentVariables
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getEnvironmentVariables"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetEnvironmentVariablesResult
      res = GetEnvironmentVariablesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetEnvironmentVariablesResult
    include JSON::Serializable

    property environment_variables : JSON::Any

    def initialize(@environment_variables : JSON::Any)
    end
  end

  struct GetMediaQueries
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getMediaQueries"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetMediaQueriesResult
      res = GetMediaQueriesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetMediaQueriesResult
    include JSON::Serializable

    property medias : Array(CSSMedia)

    def initialize(@medias : Array(CSSMedia))
    end
  end

  struct GetPlatformFontsForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getPlatformFontsForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPlatformFontsForNodeResult
      res = GetPlatformFontsForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetPlatformFontsForNodeResult
    include JSON::Serializable

    property fonts : Array(PlatformFontUsage)

    def initialize(@fonts : Array(PlatformFontUsage))
    end
  end

  struct GetStyleSheetText
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getStyleSheetText"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetStyleSheetTextResult
      res = GetStyleSheetTextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetStyleSheetTextResult
    include JSON::Serializable

    property text : String

    def initialize(@text : String)
    end
  end

  @[Experimental]
  struct GetLayersForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId

    def initialize(@node_id : Cdp::DOM::NodeId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getLayersForNode"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetLayersForNodeResult
      res = GetLayersForNodeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetLayersForNodeResult
    include JSON::Serializable

    property root_layer : CSSLayerData

    def initialize(@root_layer : CSSLayerData)
    end
  end

  @[Experimental]
  struct GetLocationForSelector
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property selector_text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @selector_text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.getLocationForSelector"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetLocationForSelectorResult
      res = GetLocationForSelectorResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetLocationForSelectorResult
    include JSON::Serializable

    property ranges : Array(SourceRange)

    def initialize(@ranges : Array(SourceRange))
    end
  end

  @[Experimental]
  struct TrackComputedStyleUpdatesForNode
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::DOM::NodeId?

    def initialize(@node_id : Cdp::DOM::NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.trackComputedStyleUpdatesForNode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct TrackComputedStyleUpdates
    include JSON::Serializable
    include Cdp::Request

    property properties_to_track : Array(CSSComputedStyleProperty)

    def initialize(@properties_to_track : Array(CSSComputedStyleProperty))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.trackComputedStyleUpdates"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct TakeComputedStyleUpdates
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.takeComputedStyleUpdates"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : TakeComputedStyleUpdatesResult
      res = TakeComputedStyleUpdatesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct TakeComputedStyleUpdatesResult
    include JSON::Serializable

    property node_ids : Array(Cdp::DOM::NodeId)

    def initialize(@node_ids : Array(Cdp::DOM::NodeId))
    end
  end

  struct SetEffectivePropertyValueForNode
    include JSON::Serializable
    include Cdp::Request

    property node_id : Cdp::DOM::NodeId
    property property_name : String
    property value : String

    def initialize(@node_id : Cdp::DOM::NodeId, @property_name : String, @value : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setEffectivePropertyValueForNode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetPropertyRulePropertyName
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property property_name : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @property_name : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setPropertyRulePropertyName"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetPropertyRulePropertyNameResult
      res = SetPropertyRulePropertyNameResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetPropertyRulePropertyNameResult
    include JSON::Serializable

    property property_name : Value

    def initialize(@property_name : Value)
    end
  end

  struct SetKeyframeKey
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property key_text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @key_text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setKeyframeKey"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetKeyframeKeyResult
      res = SetKeyframeKeyResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetKeyframeKeyResult
    include JSON::Serializable

    property key_text : Value

    def initialize(@key_text : Value)
    end
  end

  struct SetMediaText
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setMediaText"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetMediaTextResult
      res = SetMediaTextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetMediaTextResult
    include JSON::Serializable

    property media : CSSMedia

    def initialize(@media : CSSMedia)
    end
  end

  @[Experimental]
  struct SetContainerQueryText
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setContainerQueryText"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetContainerQueryTextResult
      res = SetContainerQueryTextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetContainerQueryTextResult
    include JSON::Serializable

    property container_query : CSSContainerQuery

    def initialize(@container_query : CSSContainerQuery)
    end
  end

  @[Experimental]
  struct SetSupportsText
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setSupportsText"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetSupportsTextResult
      res = SetSupportsTextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetSupportsTextResult
    include JSON::Serializable

    property supports : CSSSupports

    def initialize(@supports : CSSSupports)
    end
  end

  @[Experimental]
  struct SetScopeText
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setScopeText"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetScopeTextResult
      res = SetScopeTextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetScopeTextResult
    include JSON::Serializable

    property scope : CSSScope

    def initialize(@scope : CSSScope)
    end
  end

  struct SetRuleSelector
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property range : SourceRange
    property selector : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @range : SourceRange, @selector : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setRuleSelector"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetRuleSelectorResult
      res = SetRuleSelectorResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetRuleSelectorResult
    include JSON::Serializable

    property selector_list : SelectorList

    def initialize(@selector_list : SelectorList)
    end
  end

  struct SetStyleSheetText
    include JSON::Serializable
    include Cdp::Request

    property style_sheet_id : Cdp::DOM::StyleSheetId
    property text : String

    def initialize(@style_sheet_id : Cdp::DOM::StyleSheetId, @text : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setStyleSheetText"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetStyleSheetTextResult
      res = SetStyleSheetTextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetStyleSheetTextResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property source_map_url : String?

    def initialize(@source_map_url : String?)
    end
  end

  struct SetStyleTexts
    include JSON::Serializable
    include Cdp::Request

    property edits : Array(StyleDeclarationEdit)
    @[JSON::Field(emit_null: false)]
    property node_for_property_syntax_validation : Cdp::DOM::NodeId?

    def initialize(@edits : Array(StyleDeclarationEdit), @node_for_property_syntax_validation : Cdp::DOM::NodeId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setStyleTexts"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SetStyleTextsResult
      res = SetStyleTextsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetStyleTextsResult
    include JSON::Serializable

    property styles : Array(CSSStyle)

    def initialize(@styles : Array(CSSStyle))
    end
  end

  struct StartRuleUsageTracking
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.startRuleUsageTracking"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopRuleUsageTracking
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.stopRuleUsageTracking"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : StopRuleUsageTrackingResult
      res = StopRuleUsageTrackingResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct StopRuleUsageTrackingResult
    include JSON::Serializable

    property rule_usage : Array(RuleUsage)

    def initialize(@rule_usage : Array(RuleUsage))
    end
  end

  struct TakeCoverageDelta
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.takeCoverageDelta"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : TakeCoverageDeltaResult
      res = TakeCoverageDeltaResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct TakeCoverageDeltaResult
    include JSON::Serializable

    property coverage : Array(RuleUsage)
    property timestamp : Float64

    def initialize(@coverage : Array(RuleUsage), @timestamp : Float64)
    end
  end

  @[Experimental]
  struct SetLocalFontsEnabled
    include JSON::Serializable
    include Cdp::Request

    property enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "CSS.setLocalFontsEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
