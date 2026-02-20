require "../performance/performance"
require "json"
require "time"

module Cdp::Performance
  struct Metric
    include JSON::Serializable

    property name : String
    property value : Float64
  end

  alias EnableTimeDomain = String
end
