require "../cdp"
require "json"
require "time"

require "../dom/dom"

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

  struct ValueSource
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property attribute : String?
    @[JSON::Field(emit_null: false)]
    property attribute_value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? superseded : Bool?
    @[JSON::Field(emit_null: false)]
    property native_source : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property native_source_value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? invalid : Bool?
    @[JSON::Field(emit_null: false)]
    property invalid_reason : String?
  end

  struct RelatedNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property backend_dom_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property idref : String?
    @[JSON::Field(emit_null: false)]
    property text : String?
  end

  struct Property
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType
  end

  struct Value
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property value : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property related_nodes : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property sources : Array(Cdp::NodeType)?
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
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? ignored : Bool
    @[JSON::Field(emit_null: false)]
    property ignored_reasons : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property role : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property chrome_role : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property name : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property description : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property properties : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property parent_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property child_ids : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property backend_dom_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
  end
end
