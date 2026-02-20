require "../audits/audits"
require "json"
require "time"
require "../network/network"

module Cdp::Audits
  struct IssueAddedEvent
    include JSON::Serializable
    include Cdp::Event

    property issue : InspectorIssue

    def initialize(@issue : InspectorIssue)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Audits.issueAdded"
    end
  end
end
