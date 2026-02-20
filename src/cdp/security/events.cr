require "../security/security"
require "json"
require "time"

module Cdp::Security
  @[Experimental]
  struct VisibleSecurityStateChangedEvent
    include JSON::Serializable
    include Cdp::Event

    property visible_security_state : VisibleSecurityState

    def initialize(@visible_security_state : VisibleSecurityState)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Security.visibleSecurityStateChanged"
    end
  end
end
