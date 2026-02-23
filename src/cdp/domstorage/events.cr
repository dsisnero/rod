require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::DOMStorage
  struct DomStorageItemAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property new_value : String

    def initialize(@storage_id : Cdp::NodeType, @key : String, @new_value : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOMStorage.domStorageItemAdded"
    end
  end

  struct DomStorageItemRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key : String

    def initialize(@storage_id : Cdp::NodeType, @key : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemRemoved"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOMStorage.domStorageItemRemoved"
    end
  end

  struct DomStorageItemUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property old_value : String
    @[JSON::Field(emit_null: false)]
    property new_value : String

    def initialize(@storage_id : Cdp::NodeType, @key : String, @old_value : String, @new_value : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOMStorage.domStorageItemUpdated"
    end
  end

  struct DomStorageItemsClearedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : Cdp::NodeType

    def initialize(@storage_id : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemsCleared"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "DOMStorage.domStorageItemsCleared"
    end
  end
end
