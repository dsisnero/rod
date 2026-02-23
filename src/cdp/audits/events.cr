require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Audits
  struct IssueAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property issue : Cdp::NodeType

    def initialize(@issue : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Audits.issueAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Audits.issueAdded"
    end
  end
end
