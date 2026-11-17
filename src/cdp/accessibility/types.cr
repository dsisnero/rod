require "../cdp"
require "json"
require "base64"
require "time"

require "../dom/dom"
require "../page/page"
require "../runtime/runtime"

module Cdp::Accessibility
  alias NodeId = String

  alias ValueType = String
  ValueTypeBooleanType        = "boolean"
  ValueTypeTristate           = "tristate"
  ValueTypeBooleanOrUndefined = "booleanOrUndefined"
  ValueTypeIdref              = "idref"
  ValueTypeIdrefList          = "idrefList"
  ValueTypeInteger            = "integer"
  ValueTypeNode               = "node"
  ValueTypeNodeList           = "nodeList"
  ValueTypeNumberType         = "number"
  ValueTypeStringType         = "string"
  ValueTypeComputedString     = "computedString"
  ValueTypeToken              = "token"
  ValueTypeTokenList          = "tokenList"
  ValueTypeDomRelation        = "domRelation"
  ValueTypeRole               = "role"
  ValueTypeInternalRole       = "internalRole"
  ValueTypeValueUndefined     = "valueUndefined"

  alias ValueSourceType = String
  ValueSourceTypeAttribute      = "attribute"
  ValueSourceTypeImplicit       = "implicit"
  ValueSourceTypeStyle          = "style"
  ValueSourceTypeContents       = "contents"
  ValueSourceTypePlaceholder    = "placeholder"
  ValueSourceTypeRelatedElement = "relatedElement"

  alias ValueNativeSourceType = String
  ValueNativeSourceTypeDescription    = "description"
  ValueNativeSourceTypeFigcaption     = "figcaption"
  ValueNativeSourceTypeLabel          = "label"
  ValueNativeSourceTypeLabelfor       = "labelfor"
  ValueNativeSourceTypeLabelwrapped   = "labelwrapped"
  ValueNativeSourceTypeLegend         = "legend"
  ValueNativeSourceTypeRubyannotation = "rubyannotation"
  ValueNativeSourceTypeTablecaption   = "tablecaption"
  ValueNativeSourceTypeTitle          = "title"
  ValueNativeSourceTypeOther          = "other"

  class ValueSource
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : ValueSourceType
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Value?
    @[JSON::Field(key: "attribute", emit_null: false)]
    property attribute : String?
    @[JSON::Field(key: "attributeValue", emit_null: false)]
    property attribute_value : Value?
    @[JSON::Field(key: "superseded", emit_null: false)]
    property? superseded : Bool?
    @[JSON::Field(key: "nativeSource", emit_null: false)]
    property native_source : ValueNativeSourceType?
    @[JSON::Field(key: "nativeSourceValue", emit_null: false)]
    property native_source_value : Value?
    @[JSON::Field(key: "invalid", emit_null: false)]
    property? invalid : Bool?
    @[JSON::Field(key: "invalidReason", emit_null: false)]
    property invalid_reason : String?

    def initialize(@type : ValueSourceType, @value : Value? = nil, @attribute : String? = nil, @attribute_value : Value? = nil, @superseded : Bool? = nil, @native_source : ValueNativeSourceType? = nil, @native_source_value : Value? = nil, @invalid : Bool? = nil, @invalid_reason : String? = nil)
    end
  end

  struct RelatedNode
    include JSON::Serializable
    @[JSON::Field(key: "backendDOMNodeId", emit_null: false)]
    property backend_dom_node_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(key: "idref", emit_null: false)]
    property idref : String?
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String?

    def initialize(@backend_dom_node_id : Cdp::DOM::BackendNodeId, @idref : String? = nil, @text : String? = nil)
    end
  end

  struct Property
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : PropertyName
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Value

    def initialize(@name : PropertyName, @value : Value)
    end
  end

  class Value
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : ValueType
    @[JSON::Field(key: "value", emit_null: false)]
    property value : JSON::Any?
    @[JSON::Field(key: "relatedNodes", emit_null: false)]
    property related_nodes : Array(RelatedNode)?
    @[JSON::Field(key: "sources", emit_null: false)]
    property sources : Array(ValueSource)?

    def initialize(@type : ValueType, @value : JSON::Any? = nil, @related_nodes : Array(RelatedNode)? = nil, @sources : Array(ValueSource)? = nil)
    end
  end

  alias PropertyName = String
  PropertyNameActions                    = "actions"
  PropertyNameBusy                       = "busy"
  PropertyNameDisabled                   = "disabled"
  PropertyNameEditable                   = "editable"
  PropertyNameFocusable                  = "focusable"
  PropertyNameFocused                    = "focused"
  PropertyNameHidden                     = "hidden"
  PropertyNameHiddenRoot                 = "hiddenRoot"
  PropertyNameInvalid                    = "invalid"
  PropertyNameKeyshortcuts               = "keyshortcuts"
  PropertyNameSettable                   = "settable"
  PropertyNameRoledescription            = "roledescription"
  PropertyNameLive                       = "live"
  PropertyNameAtomic                     = "atomic"
  PropertyNameRelevant                   = "relevant"
  PropertyNameRoot                       = "root"
  PropertyNameAutocomplete               = "autocomplete"
  PropertyNameHasPopup                   = "hasPopup"
  PropertyNameLevel                      = "level"
  PropertyNameMultiselectable            = "multiselectable"
  PropertyNameOrientation                = "orientation"
  PropertyNameMultiline                  = "multiline"
  PropertyNameReadonly                   = "readonly"
  PropertyNameRequired                   = "required"
  PropertyNameValuemin                   = "valuemin"
  PropertyNameValuemax                   = "valuemax"
  PropertyNameValuetext                  = "valuetext"
  PropertyNameChecked                    = "checked"
  PropertyNameExpanded                   = "expanded"
  PropertyNameModal                      = "modal"
  PropertyNamePressed                    = "pressed"
  PropertyNameSelected                   = "selected"
  PropertyNameActivedescendant           = "activedescendant"
  PropertyNameControls                   = "controls"
  PropertyNameDescribedby                = "describedby"
  PropertyNameDetails                    = "details"
  PropertyNameErrormessage               = "errormessage"
  PropertyNameFlowto                     = "flowto"
  PropertyNameLabelledby                 = "labelledby"
  PropertyNameOwns                       = "owns"
  PropertyNameUrl                        = "url"
  PropertyNameActiveFullscreenElement    = "activeFullscreenElement"
  PropertyNameActiveModalDialog          = "activeModalDialog"
  PropertyNameActiveAriaModalDialog      = "activeAriaModalDialog"
  PropertyNameAriaHiddenElement          = "ariaHiddenElement"
  PropertyNameAriaHiddenSubtree          = "ariaHiddenSubtree"
  PropertyNameEmptyAlt                   = "emptyAlt"
  PropertyNameEmptyText                  = "emptyText"
  PropertyNameInertElement               = "inertElement"
  PropertyNameInertSubtree               = "inertSubtree"
  PropertyNameLabelContainer             = "labelContainer"
  PropertyNameLabelFor                   = "labelFor"
  PropertyNameNotRendered                = "notRendered"
  PropertyNameNotVisible                 = "notVisible"
  PropertyNamePresentationalRole         = "presentationalRole"
  PropertyNameProbablyPresentational     = "probablyPresentational"
  PropertyNameInactiveCarouselTabContent = "inactiveCarouselTabContent"
  PropertyNameUninteresting              = "uninteresting"

  struct Node
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(key: "ignored", emit_null: false)]
    property? ignored : Bool
    @[JSON::Field(key: "ignoredReasons", emit_null: false)]
    property ignored_reasons : Array(Property)?
    @[JSON::Field(key: "role", emit_null: false)]
    property role : Value?
    @[JSON::Field(key: "chromeRole", emit_null: false)]
    property chrome_role : Value?
    @[JSON::Field(key: "name", emit_null: false)]
    property name : Value?
    @[JSON::Field(key: "description", emit_null: false)]
    property description : Value?
    @[JSON::Field(key: "value", emit_null: false)]
    property value : Value?
    @[JSON::Field(key: "properties", emit_null: false)]
    property properties : Array(Property)?
    @[JSON::Field(key: "parentId", emit_null: false)]
    property parent_id : NodeId?
    @[JSON::Field(key: "childIds", emit_null: false)]
    property child_ids : Array(NodeId)?
    @[JSON::Field(key: "backendDOMNodeId", emit_null: false)]
    property backend_dom_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId?

    def initialize(@node_id : NodeId, @ignored : Bool, @ignored_reasons : Array(Property)? = nil, @role : Value? = nil, @chrome_role : Value? = nil, @name : Value? = nil, @description : Value? = nil, @value : Value? = nil, @properties : Array(Property)? = nil, @parent_id : NodeId? = nil, @child_ids : Array(NodeId)? = nil, @backend_dom_node_id : Cdp::DOM::BackendNodeId? = nil, @frame_id : Cdp::Page::FrameId? = nil)
    end
  end
end
