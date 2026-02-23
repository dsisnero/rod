require "../cdp"
require "json"
require "time"

module Cdp::DOM
  struct AttributeModifiedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String

    def initialize(@node_id : Cdp::NodeType, @name : String, @value : String)
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
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property adopted_style_sheets : Array(Cdp::NodeType)

    def initialize(@node_id : Cdp::NodeType, @adopted_style_sheets : Array(Cdp::NodeType))
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
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String

    def initialize(@node_id : Cdp::NodeType, @name : String)
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
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property character_data : String

    def initialize(@node_id : Cdp::NodeType, @character_data : String)
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
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property child_node_count : Int64

    def initialize(@node_id : Cdp::NodeType, @child_node_count : Int64)
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
    property parent_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property previous_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node : Cdp::NodeType

    def initialize(@parent_node_id : Cdp::NodeType, @previous_node_id : Cdp::NodeType, @node : Cdp::NodeType)
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
    property parent_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType

    def initialize(@parent_node_id : Cdp::NodeType, @node_id : Cdp::NodeType)
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
    property insertion_point_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property distributed_nodes : Array(Cdp::NodeType)

    def initialize(@insertion_point_id : Cdp::NodeType, @distributed_nodes : Array(Cdp::NodeType))
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
    property node_ids : Array(Cdp::NodeType)

    def initialize(@node_ids : Array(Cdp::NodeType))
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
    property parent_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property pseudo_element : Cdp::NodeType

    def initialize(@parent_id : Cdp::NodeType, @pseudo_element : Cdp::NodeType)
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
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_scrollable : Bool

    def initialize(@node_id : Cdp::NodeType, @is_scrollable : Bool)
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
  struct AffectedByStartingStylesFlagUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? affected_by_starting_styles : Bool

    def initialize(@node_id : Cdp::NodeType, @affected_by_starting_styles : Bool)
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
    property parent_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property pseudo_element_id : Cdp::NodeType

    def initialize(@parent_id : Cdp::NodeType, @pseudo_element_id : Cdp::NodeType)
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
    property parent_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property nodes : Array(Cdp::NodeType)

    def initialize(@parent_id : Cdp::NodeType, @nodes : Array(Cdp::NodeType))
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
    property host_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property root_id : Cdp::NodeType

    def initialize(@host_id : Cdp::NodeType, @root_id : Cdp::NodeType)
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
    property host_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property root : Cdp::NodeType

    def initialize(@host_id : Cdp::NodeType, @root : Cdp::NodeType)
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
