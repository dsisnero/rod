require "json"
require "../cdp"
require "../runtime/runtime"
require "./types"

@[Experimental]
module Cdp::HeapProfiler
  # Commands
  struct AddInspectedHeapObject
    include JSON::Serializable
    include Cdp::Request

    property heap_object_id : HeapSnapshotObjectId

    def initialize(@heap_object_id : HeapSnapshotObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.addInspectedHeapObject"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CollectGarbage
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.collectGarbage"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetHeapObjectId
    include JSON::Serializable
    include Cdp::Request

    property object_id : Cdp::Runtime::RemoteObjectId

    def initialize(@object_id : Cdp::Runtime::RemoteObjectId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.getHeapObjectId"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetHeapObjectIdResult
      res = GetHeapObjectIdResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetHeapObjectIdResult
    include JSON::Serializable

    property heap_snapshot_object_id : HeapSnapshotObjectId

    def initialize(@heap_snapshot_object_id : HeapSnapshotObjectId)
    end
  end

  struct GetObjectByHeapObjectId
    include JSON::Serializable
    include Cdp::Request

    property object_id : HeapSnapshotObjectId
    @[JSON::Field(emit_null: false)]
    property object_group : String?

    def initialize(@object_id : HeapSnapshotObjectId, @object_group : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.getObjectByHeapObjectId"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetObjectByHeapObjectIdResult
      res = GetObjectByHeapObjectIdResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetObjectByHeapObjectIdResult
    include JSON::Serializable

    property result : Cdp::Runtime::RemoteObject

    def initialize(@result : Cdp::Runtime::RemoteObject)
    end
  end

  struct GetSamplingProfile
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.getSamplingProfile"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetSamplingProfileResult
      res = GetSamplingProfileResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetSamplingProfileResult
    include JSON::Serializable

    property profile : SamplingHeapProfile

    def initialize(@profile : SamplingHeapProfile)
    end
  end

  struct StartSampling
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property sampling_interval : Float64?
    @[JSON::Field(emit_null: false)]
    property stack_depth : Float64?
    @[JSON::Field(emit_null: false)]
    property include_objects_collected_by_major_gc : Bool?
    @[JSON::Field(emit_null: false)]
    property include_objects_collected_by_minor_gc : Bool?

    def initialize(@sampling_interval : Float64?, @stack_depth : Float64?, @include_objects_collected_by_major_gc : Bool?, @include_objects_collected_by_minor_gc : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.startSampling"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StartTrackingHeapObjects
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property track_allocations : Bool?

    def initialize(@track_allocations : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.startTrackingHeapObjects"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopSampling
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.stopSampling"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : StopSamplingResult
      res = StopSamplingResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct StopSamplingResult
    include JSON::Serializable

    property profile : SamplingHeapProfile

    def initialize(@profile : SamplingHeapProfile)
    end
  end

  struct StopTrackingHeapObjects
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property report_progress : Bool?
    @[JSON::Field(emit_null: false)]
    property capture_numeric_value : Bool?
    @[JSON::Field(emit_null: false)]
    property expose_internals : Bool?

    def initialize(@report_progress : Bool?, @capture_numeric_value : Bool?, @expose_internals : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.stopTrackingHeapObjects"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct TakeHeapSnapshot
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property report_progress : Bool?
    @[JSON::Field(emit_null: false)]
    property capture_numeric_value : Bool?
    @[JSON::Field(emit_null: false)]
    property expose_internals : Bool?

    def initialize(@report_progress : Bool?, @capture_numeric_value : Bool?, @expose_internals : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "HeapProfiler.takeHeapSnapshot"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
