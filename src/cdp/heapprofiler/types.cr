require "../heapprofiler/heapprofiler"
require "json"
require "time"
require "../runtime/runtime"

module Cdp::HeapProfiler
  alias HeapSnapshotObjectId = String

  struct SamplingHeapProfileNode
    include JSON::Serializable

    property call_frame : Cdp::Runtime::CallFrame
    property self_size : Float64
    property id : Int64
    property children : Array(SamplingHeapProfileNode)
  end

  struct SamplingHeapProfileSample
    include JSON::Serializable

    property size : Float64
    property node_id : Int64
    property ordinal : Float64
  end

  struct SamplingHeapProfile
    include JSON::Serializable

    property head : SamplingHeapProfileNode
    property samples : Array(SamplingHeapProfileSample)
  end
end
