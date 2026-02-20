require "../memory/memory"
require "json"
require "time"

module Cdp::Memory
  alias PressureLevel = String

  struct SamplingProfileNode
    include JSON::Serializable

    property size : Float64
    property total : Float64
    property stack : Array(String)
  end

  struct SamplingProfile
    include JSON::Serializable

    property samples : Array(SamplingProfileNode)
    property modules : Array(Module)
  end

  struct Module
    include JSON::Serializable

    property name : String
    property uuid : String
    property base_address : String
    property size : Float64
  end

  struct DOMCounter
    include JSON::Serializable

    property name : String
    property count : Int64
  end
end
