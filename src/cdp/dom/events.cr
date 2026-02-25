require "../cdp"
require "json"
require "time"

require "../page/page"
require "../runtime/runtime"

module Cdp::DOM
  struct AttributeModifiedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String

    def initialize(@node_id : NodeId, @name : String, @value : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.attributeModified"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.attributeModified"
    end
  end

  @[Experimental]
  struct AdoptedStyleSheetsModifiedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property adopted_style_sheets : Array(StyleSheetId)

    def initialize(@node_id : NodeId, @adopted_style_sheets : Array(StyleSheetId))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.adoptedStyleSheetsModified"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.adoptedStyleSheetsModified"
    end
  end

  struct AttributeRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property name : String

    def initialize(@node_id : NodeId, @name : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.attributeRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.attributeRemoved"
    end
  end

  struct CharacterDataModifiedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property character_data : String

    def initialize(@node_id : NodeId, @character_data : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.characterDataModified"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.characterDataModified"
    end
  end

  struct ChildNodeCountUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property child_node_count : Int64

    def initialize(@node_id : NodeId, @child_node_count : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.childNodeCountUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.childNodeCountUpdated"
    end
  end

  struct ChildNodeInsertedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property parent_node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property previous_node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property node : Node

    def initialize(@parent_node_id : NodeId, @previous_node_id : NodeId, @node : Node)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.childNodeInserted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.childNodeInserted"
    end
  end

  struct ChildNodeRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property parent_node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId

    def initialize(@parent_node_id : NodeId, @node_id : NodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.childNodeRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.childNodeRemoved"
    end
  end

  @[Experimental]
  struct DistributedNodesUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property insertion_point_id : NodeId
    @[JSON::Field(emit_null: false)]
    property distributed_nodes : Array(BackendNode)

    def initialize(@insertion_point_id : NodeId, @distributed_nodes : Array(BackendNode))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.distributedNodesUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.distributedNodesUpdated"
    end
  end

  struct DocumentUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.documentUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.documentUpdated"
    end
  end

  @[Experimental]
  struct InlineStyleInvalidatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_ids : Array(NodeId)

    def initialize(@node_ids : Array(NodeId))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.inlineStyleInvalidated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.inlineStyleInvalidated"
    end
  end

  @[Experimental]
  struct PseudoElementAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property parent_id : NodeId
    @[JSON::Field(emit_null: false)]
    property pseudo_element : Node

    def initialize(@parent_id : NodeId, @pseudo_element : Node)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.pseudoElementAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.pseudoElementAdded"
    end
  end

  @[Experimental]
  struct TopLayerElementsUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.topLayerElementsUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.topLayerElementsUpdated"
    end
  end

  @[Experimental]
  struct ScrollableFlagUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property? is_scrollable : Bool

    def initialize(@node_id : NodeId, @is_scrollable : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.scrollableFlagUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.scrollableFlagUpdated"
    end
  end

  @[Experimental]
  struct AdRelatedStateUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property? is_ad_related : Bool

    def initialize(@node_id : NodeId, @is_ad_related : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.adRelatedStateUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.adRelatedStateUpdated"
    end
  end

  @[Experimental]
  struct AffectedByStartingStylesFlagUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : NodeId
    @[JSON::Field(emit_null: false)]
    property? affected_by_starting_styles : Bool

    def initialize(@node_id : NodeId, @affected_by_starting_styles : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.affectedByStartingStylesFlagUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.affectedByStartingStylesFlagUpdated"
    end
  end

  @[Experimental]
  struct PseudoElementRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property parent_id : NodeId
    @[JSON::Field(emit_null: false)]
    property pseudo_element_id : NodeId

    def initialize(@parent_id : NodeId, @pseudo_element_id : NodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.pseudoElementRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.pseudoElementRemoved"
    end
  end

  struct SetChildNodesEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property parent_id : NodeId
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Node)

    def initialize(@parent_id : NodeId, @nodes : Array(Node))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.setChildNodes"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.setChildNodes"
    end
  end

  @[Experimental]
  struct ShadowRootPoppedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property host_id : NodeId
    @[JSON::Field(emit_null: false)]
    property root_id : NodeId

    def initialize(@host_id : NodeId, @root_id : NodeId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.shadowRootPopped"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.shadowRootPopped"
    end
  end

  @[Experimental]
  struct ShadowRootPushedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property host_id : NodeId
    @[JSON::Field(emit_null: false)]
    property root : Node

    def initialize(@host_id : NodeId, @root : Node)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOM.shadowRootPushed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOM.shadowRootPushed"
    end
  end
end
