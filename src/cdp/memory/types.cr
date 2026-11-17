require "../cdp"
require "json"
require "base64"
require "time"

module Cdp::Memory
  alias PressureLevel = String
  PressureLevelModerate = "moderate"
  PressureLevelCritical = "critical"

  struct SamplingProfileNode
    include JSON::Serializable
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Float64
    @[JSON::Field(key: "total", emit_null: false)]
    property total : Float64
    @[JSON::Field(key: "stack", emit_null: false)]
    property stack : Array(String)

    def initialize(@size : Float64, @total : Float64, @stack : Array(String))
    end
  end

  struct SamplingProfile
    include JSON::Serializable
    @[JSON::Field(key: "samples", emit_null: false)]
    property samples : Array(SamplingProfileNode)
    @[JSON::Field(key: "modules", emit_null: false)]
    property modules : Array(Module)

    def initialize(@samples : Array(SamplingProfileNode), @modules : Array(Module))
    end
  end

  struct Module
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "uuid", emit_null: false)]
    property uuid : String
    @[JSON::Field(key: "baseAddress", emit_null: false)]
    property base_address : String
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Float64

    def initialize(@name : String, @uuid : String, @base_address : String, @size : Float64)
    end
  end

  struct DOMCounter
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "count", emit_null: false)]
    property count : Int64

    def initialize(@name : String, @count : Int64)
    end
  end
end
