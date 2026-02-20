require "../log/log"
require "json"
require "time"

module Cdp::Log
  struct EntryAddedEvent
    include JSON::Serializable
    include Cdp::Event

    property entry : LogEntry

    def initialize(@entry : LogEntry)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Log.entryAdded"
    end
  end
end
