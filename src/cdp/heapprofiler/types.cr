require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::HeapProfiler
  alias HeapSnapshotObjectId = String

  struct SamplingHeapProfileNode
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property call_frame : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property self_size : Float64
    @[JSON::Field(emit_null: false)]
    property id : Int64
    @[JSON::Field(emit_null: false)]
    property children : Array(Cdp::NodeType)
  end

  struct SamplingHeapProfileSample
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property size : Float64
    @[JSON::Field(emit_null: false)]
    property node_id : Int64
    @[JSON::Field(emit_null: false)]
    property ordinal : Float64
  end

  struct SamplingHeapProfile
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property head : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property samples : Array(Cdp::NodeType)
  end
end
