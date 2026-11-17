require "../cdp"
require "json"
require "base64"
require "time"

require "../runtime/runtime"

module Cdp::HeapProfiler
  alias HeapSnapshotObjectId = String

  class SamplingHeapProfileNode
    include JSON::Serializable
    @[JSON::Field(key: "callFrame", emit_null: false)]
    property call_frame : Cdp::Runtime::CallFrame
    @[JSON::Field(key: "selfSize", emit_null: false)]
    property self_size : Float64
    @[JSON::Field(key: "id", emit_null: false)]
    property id : Int64
    @[JSON::Field(key: "children", emit_null: false)]
    property children : Array(SamplingHeapProfileNode)

    def initialize(@call_frame : Cdp::Runtime::CallFrame, @self_size : Float64, @id : Int64, @children : Array(SamplingHeapProfileNode))
    end
  end

  struct SamplingHeapProfileSample
    include JSON::Serializable
    @[JSON::Field(key: "size", emit_null: false)]
    property size : Float64
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Int64
    @[JSON::Field(key: "ordinal", emit_null: false)]
    property ordinal : Float64

    def initialize(@size : Float64, @node_id : Int64, @ordinal : Float64)
    end
  end

  struct SamplingHeapProfile
    include JSON::Serializable
    @[JSON::Field(key: "head", emit_null: false)]
    property head : SamplingHeapProfileNode
    @[JSON::Field(key: "samples", emit_null: false)]
    property samples : Array(SamplingHeapProfileSample)

    def initialize(@head : SamplingHeapProfileNode, @samples : Array(SamplingHeapProfileSample))
    end
  end
end
