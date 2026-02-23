
require "../cdp"
require "json"
require "time"


module Cdp::DOMStorage
  struct DomStorageItemAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : StorageId
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property new_value : String

    def initialize(@storage_id : StorageId, @key : String, @new_value : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemAdded"
    end
  end

  struct DomStorageItemRemovedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : StorageId
    @[JSON::Field(emit_null: false)]
    property key : String

    def initialize(@storage_id : StorageId, @key : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemRemoved"
    end
  end

  struct DomStorageItemUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : StorageId
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property old_value : String
    @[JSON::Field(emit_null: false)]
    property new_value : String

    def initialize(@storage_id : StorageId, @key : String, @old_value : String, @new_value : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemUpdated"
    end
  end

  struct DomStorageItemsClearedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property storage_id : StorageId

    def initialize(@storage_id : StorageId)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "DOMStorage.domStorageItemsCleared"
    end
  end

end
