require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Reporting of performance timeline events, as specified in
# https://w3c.github.io/performance-timeline/#dom-performanceobserver.
@[Experimental]
module Cdp::PerformanceTimeline
  # Commands
  struct Enable
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property event_types : Array(String)

    def initialize(@event_types : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PerformanceTimeline.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
