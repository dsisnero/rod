require "../cdp"
require "json"
require "time"

module Cdp::Performance
  struct Metric
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : Float64
  end

  alias EnableTimeDomain = String
  EnableTimeDomainTimeTicks   = "timeTicks"
  EnableTimeDomainThreadTicks = "threadTicks"

  alias SetTimeDomainTimeDomain = String
  SetTimeDomainTimeDomainTimeTicks   = "timeTicks"
  SetTimeDomainTimeDomainThreadTicks = "threadTicks"
end
