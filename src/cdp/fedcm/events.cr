require "../cdp"
require "json"
require "time"

module Cdp::FedCm
  struct DialogShownEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "dialogId", emit_null: false)]
    property dialog_id : String
    @[JSON::Field(key: "dialogType", emit_null: false)]
    property dialog_type : DialogType
    @[JSON::Field(key: "accounts", emit_null: false)]
    property accounts : Array(Account)
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String
    @[JSON::Field(key: "subtitle", emit_null: false)]
    property subtitle : String?

    def initialize(@dialog_id : String, @dialog_type : DialogType, @accounts : Array(Account), @title : String, @subtitle : String?)
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
    @[JSON::Field(key: "dialogId", emit_null: false)]
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
