require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Memory
  alias PressureLevel = String
  PressureLevelModerate = "moderate"
  PressureLevelCritical = "critical"

  struct SamplingProfileNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property size : Float64
    @[JSON::Field(emit_null: false)]
    property total : Float64
    @[JSON::Field(emit_null: false)]
    property stack : Array(String)
  end

  struct SamplingProfile
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property samples : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property modules : Array(Cdp::NodeType)
  end

  struct Module
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property uuid : String
    @[JSON::Field(emit_null: false)]
    property base_address : String
    @[JSON::Field(emit_null: false)]
    property size : Float64
  end

  struct DOMCounter
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property count : Int64
  end
end
