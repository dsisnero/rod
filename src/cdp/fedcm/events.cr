require "../fedcm/fedcm"
require "json"
require "time"

module Cdp::FedCm
  struct DialogShownEvent
    include JSON::Serializable
    include Cdp::Event

    property dialog_id : String
    property dialog_type : DialogType
    property accounts : Array(Account)
    property title : String
    @[JSON::Field(emit_null: false)]
    property subtitle : String?

    def initialize(@dialog_id : String, @dialog_type : DialogType, @accounts : Array(Account), @title : String, @subtitle : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "FedCm.dialogShown"
    end
  end

  struct DialogClosedEvent
    include JSON::Serializable
    include Cdp::Event

    property dialog_id : String

    def initialize(@dialog_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "FedCm.dialogClosed"
    end
  end
end
