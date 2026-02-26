require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../network/network"

module Cdp::Log
  struct EntryAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "entry", emit_null: false)]
    property entry : LogEntry

    def initialize(@entry : LogEntry)
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
