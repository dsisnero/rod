require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::FedCm
  struct DialogShownEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property dialog_id : String
    @[JSON::Field(emit_null: false)]
    property dialog_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property accounts : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property subtitle : String?

    def initialize(@dialog_id : String, @dialog_type : Cdp::NodeType, @accounts : Array(Cdp::NodeType), @title : String, @subtitle : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "FedCm.dialogShown"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "FedCm.dialogShown"
    end
  end

  struct DialogClosedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property dialog_id : String

    def initialize(@dialog_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "FedCm.dialogClosed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "FedCm.dialogClosed"
    end
  end
end
