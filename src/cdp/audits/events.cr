require "../cdp"
require "json"
require "time"

require "../network/network"
require "../page/page"
require "../runtime/runtime"
require "../dom/dom"

module Cdp::Audits
  struct IssueAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property issue : InspectorIssue

    def initialize(@issue : InspectorIssue)
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
