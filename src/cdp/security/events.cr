require "../cdp"
require "json"
require "time"

require "../network/network"

module Cdp::Security
  @[Experimental]
  struct VisibleSecurityStateChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property visible_security_state : VisibleSecurityState

    def initialize(@visible_security_state : VisibleSecurityState)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Security.visibleSecurityStateChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Security.visibleSecurityStateChanged"
    end
  end
end
