require "../cdp"
require "json"
require "time"

module Cdp::Cast
  struct SinksUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property sinks : Array(Sink)

    def initialize(@sinks : Array(Sink))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Cast.sinksUpdated"
    end
  end

  struct IssueUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property issue_message : String

    def initialize(@issue_message : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Cast.issueUpdated"
    end
  end
end
