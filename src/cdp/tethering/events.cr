require "../tethering/tethering"
require "json"
require "time"

module Cdp::Tethering
  struct AcceptedEvent
    include JSON::Serializable
    include Cdp::Event

    property port : Int64
    property connection_id : String

    def initialize(@port : Int64, @connection_id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Tethering.accepted"
    end
  end
end
