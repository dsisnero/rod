require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# This domain exposes CSS read/write operations. All CSS objects (stylesheets, rules, and styles)
# have an associated `id` used in subsequent operations on the related object. Each object type has
# a specific `id` structure, and those are not interchangeable between objects of different kinds.
# CSS objects can be loaded using the `get*ForNode()` calls (which accept a DOM node id). A client
# can also keep track of stylesheets via the `styleSheetAdded`/`styleSheetRemoved` events and
# subsequently load the required stylesheet contents using the `getStyleSheet[Text]()` methods.
@[Experimental]
module Cdp::CSS
  struct AddRuleResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule : Cdp::NodeType

    def initialize(@rule : Cdp::NodeType)
    end
  end

  struct CollectClassNamesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property class_names : Array(String)

    def initialize(@class_names : Array(String))
    end
  end

  struct CreateStyleSheetResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType

    def initialize(@style_sheet_id : Cdp::NodeType)
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

  struct GetComputedStyleForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property computed_style : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property extra_fields : Cdp::NodeType

    def initialize(@computed_style : Array(Cdp::NodeType), @extra_fields : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct ResolveValuesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property results : Array(String)

    def initialize(@results : Array(String))
    end
  end

  @[Experimental]
  struct GetLonghandPropertiesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property longhand_properties : Array(Cdp::NodeType)

    def initialize(@longhand_properties : Array(Cdp::NodeType))
    end
  end

  struct GetInlineStylesForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property inline_style : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property attributes_style : Cdp::NodeType?

    def initialize(@inline_style : Cdp::NodeType?, @attributes_style : Cdp::NodeType?)
    end
  end

  @[Experimental]
  struct GetAnimatedStylesForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property animation_styles : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property transitions_style : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property inherited : Array(Cdp::NodeType)?

    def initialize(@animation_styles : Array(Cdp::NodeType)?, @transitions_style : Cdp::NodeType?, @inherited : Array(Cdp::NodeType)?)
    end
  end

  struct GetMatchedStylesForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property inline_style : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property attributes_style : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property matched_css_rules : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property pseudo_elements : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property inherited : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property inherited_pseudo_elements : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property css_keyframes_rules : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property css_position_try_rules : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property active_position_fallback_index : Int64?
    @[JSON::Field(emit_null: false)]
    property css_property_rules : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property css_property_registrations : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property css_at_rules : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property parent_layout_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property css_function_rules : Array(Cdp::NodeType)?

    def initialize(@inline_style : Cdp::NodeType?, @attributes_style : Cdp::NodeType?, @matched_css_rules : Array(Cdp::NodeType)?, @pseudo_elements : Array(Cdp::NodeType)?, @inherited : Array(Cdp::NodeType)?, @inherited_pseudo_elements : Array(Cdp::NodeType)?, @css_keyframes_rules : Array(Cdp::NodeType)?, @css_position_try_rules : Array(Cdp::NodeType)?, @active_position_fallback_index : Int64?, @css_property_rules : Array(Cdp::NodeType)?, @css_property_registrations : Array(Cdp::NodeType)?, @css_at_rules : Array(Cdp::NodeType)?, @parent_layout_node_id : Cdp::NodeType?, @css_function_rules : Array(Cdp::NodeType)?)
    end
  end

  @[Experimental]
  struct GetEnvironmentVariablesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property environment_variables : JSON::Any

    def initialize(@environment_variables : JSON::Any)
    end
  end

  struct GetMediaQueriesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property medias : Array(Cdp::NodeType)

    def initialize(@medias : Array(Cdp::NodeType))
    end
  end

  struct GetPlatformFontsForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property fonts : Array(Cdp::NodeType)

    def initialize(@fonts : Array(Cdp::NodeType))
    end
  end

  struct GetStyleSheetTextResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property text : String

    def initialize(@text : String)
    end
  end

  @[Experimental]
  struct GetLayersForNodeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property root_layer : Cdp::NodeType

    def initialize(@root_layer : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct GetLocationForSelectorResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property ranges : Array(Cdp::NodeType)

    def initialize(@ranges : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct TakeComputedStyleUpdatesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(Cdp::NodeType)

    def initialize(@node_ids : Array(Cdp::NodeType))
    end
  end

  struct SetPropertyRulePropertyNameResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property property_name : Cdp::NodeType

    def initialize(@property_name : Cdp::NodeType)
    end
  end

  struct SetKeyframeKeyResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key_text : Cdp::NodeType

    def initialize(@key_text : Cdp::NodeType)
    end
  end

  struct SetMediaTextResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property media : Cdp::NodeType

    def initialize(@media : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct SetContainerQueryTextResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property container_query : Cdp::NodeType

    def initialize(@container_query : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct SetSupportsTextResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property supports : Cdp::NodeType

    def initialize(@supports : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct SetScopeTextResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property scope : Cdp::NodeType

    def initialize(@scope : Cdp::NodeType)
    end
  end

  struct SetRuleSelectorResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property selector_list : Cdp::NodeType

    def initialize(@selector_list : Cdp::NodeType)
    end
  end

  struct SetStyleSheetTextResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property source_map_url : String?

    def initialize(@source_map_url : String?)
    end
  end

  struct SetStyleTextsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property styles : Array(Cdp::NodeType)

    def initialize(@styles : Array(Cdp::NodeType))
    end
  end

  struct StopRuleUsageTrackingResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule_usage : Array(Cdp::NodeType)

    def initialize(@rule_usage : Array(Cdp::NodeType))
    end
  end

  struct TakeCoverageDeltaResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property coverage : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property timestamp : Float64

    def initialize(@coverage : Array(Cdp::NodeType), @timestamp : Float64)
    end
  end

  # Commands
  struct AddRule
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property rule_text : String
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_for_property_syntax_validation : Cdp::NodeType?

    def initialize(@style_sheet_id : Cdp::NodeType, @rule_text : String, @location : Cdp::NodeType, @node_for_property_syntax_validation : Cdp::NodeType?)
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

  struct CollectClassNames
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType

    def initialize(@style_sheet_id : Cdp::NodeType)
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

  struct CreateStyleSheet
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? force : Bool?

    def initialize(@frame_id : Cdp::NodeType, @force : Bool?)
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
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property forced_pseudo_classes : Array(String)

    def initialize(@node_id : Cdp::NodeType, @forced_pseudo_classes : Array(String))
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
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? forced : Bool

    def initialize(@node_id : Cdp::NodeType, @forced : Bool)
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
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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

  struct GetComputedStyleForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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

  @[Experimental]
  struct ResolveValues
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property values : Array(String)
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property property_name : String?
    @[JSON::Field(emit_null: false)]
    property pseudo_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property pseudo_identifier : String?

    def initialize(@values : Array(String), @node_id : Cdp::NodeType, @property_name : String?, @pseudo_type : Cdp::NodeType?, @pseudo_identifier : String?)
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
  struct GetLonghandProperties
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property shorthand_name : String
    @[JSON::Field(emit_null: false)]
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

  struct GetInlineStylesForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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

  @[Experimental]
  struct GetAnimatedStylesForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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

  struct GetMatchedStylesForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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

  struct GetPlatformFontsForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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

  struct GetStyleSheetText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType

    def initialize(@style_sheet_id : Cdp::NodeType)
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

  @[Experimental]
  struct GetLayersForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@node_id : Cdp::NodeType)
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
  struct GetLocationForSelector
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property selector_text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @selector_text : String)
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
  struct TrackComputedStyleUpdatesForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?

    def initialize(@node_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property properties_to_track : Array(Cdp::NodeType)

    def initialize(@properties_to_track : Array(Cdp::NodeType))
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

  struct SetEffectivePropertyValueForNode
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property property_name : String
    @[JSON::Field(emit_null: false)]
    property value : String

    def initialize(@node_id : Cdp::NodeType, @property_name : String, @value : String)
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
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property property_name : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @property_name : String)
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

  struct SetKeyframeKey
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key_text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @key_text : String)
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

  struct SetMediaText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @text : String)
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

  @[Experimental]
  struct SetContainerQueryText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @text : String)
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
  struct SetSupportsText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @text : String)
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
  struct SetScopeText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @text : String)
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

  struct SetRuleSelector
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property range : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property selector : String

    def initialize(@style_sheet_id : Cdp::NodeType, @range : Cdp::NodeType, @selector : String)
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

  struct SetStyleSheetText
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property style_sheet_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property text : String

    def initialize(@style_sheet_id : Cdp::NodeType, @text : String)
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

  struct SetStyleTexts
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property edits : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property node_for_property_syntax_validation : Cdp::NodeType?

    def initialize(@edits : Array(Cdp::NodeType), @node_for_property_syntax_validation : Cdp::NodeType?)
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

  @[Experimental]
  struct SetLocalFontsEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

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
