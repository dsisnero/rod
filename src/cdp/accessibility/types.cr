
require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../page/page"
require "../runtime/runtime"

module Cdp::Accessibility
  alias NodeId = String

  alias ValueType = String

  alias ValueSourceType = String

  alias ValueNativeSourceType = String

  struct ValueSource
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : ValueSourceType
    @[JSON::Field(emit_null: false)]
    property value : Value?
    @[JSON::Field(emit_null: false)]
    property attribute : String?
    @[JSON::Field(emit_null: false)]
    property attribute_value : Value?
    @[JSON::Field(emit_null: false)]
    property superseded : Bool?
    @[JSON::Field(emit_null: false)]
    property native_source : ValueNativeSourceType?
    @[JSON::Field(emit_null: false)]
    property native_source_value : Value?
    @[JSON::Field(emit_null: false)]
    property invalid : Bool?
    @[JSON::Field(emit_null: false)]
    property invalid_reason : String?
  end

  struct RelatedNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property backend_dom_node_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(emit_null: false)]
    property idref : String?
    @[JSON::Field(emit_null: false)]
    property text : String?
  end

  struct Property
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : PropertyName
    @[JSON::Field(emit_null: false)]
    property value : Value
  end

  struct Value
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : ValueType
    @[JSON::Field(emit_null: false)]
    property value : JSON::Any?
    @[JSON::Field(emit_null: false)]
    property related_nodes : Array(RelatedNode)?
    @[JSON::Field(emit_null: false)]
    property sources : Array(ValueSource)?
  end

  alias PropertyName = String

  struct Node
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property ignored : Bool
    @[JSON::Field(emit_null: false)]
    property ignored_reasons : Array(Property)?
    @[JSON::Field(emit_null: false)]
    property role : Value?
    @[JSON::Field(emit_null: false)]
    property chrome_role : Value?
    @[JSON::Field(emit_null: false)]
    property name : Value?
    @[JSON::Field(emit_null: false)]
    property description : Value?
    @[JSON::Field(emit_null: false)]
    property value : Value?
    @[JSON::Field(emit_null: false)]
    property properties : Array(Property)?
    @[JSON::Field(emit_null: false)]
    property parent_id : NodeId?
    @[JSON::Field(emit_null: false)]
    property child_ids : Array(NodeId)?
    @[JSON::Field(emit_null: false)]
    property backend_dom_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
  end

   end
