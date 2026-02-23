require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Log
  struct EntryAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property entry : Cdp::NodeType

    def initialize(@entry : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Log.entryAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Log.entryAdded"
    end
  end
end
