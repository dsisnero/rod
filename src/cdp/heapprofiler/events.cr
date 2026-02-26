require "../cdp"
require "json"
require "time"

require "../runtime/runtime"

module Cdp::HeapProfiler
  struct AddHeapSnapshotChunkEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "chunk", emit_null: false)]
    property chunk : String

    def initialize(@chunk : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "HeapProfiler.addHeapSnapshotChunk"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "HeapProfiler.addHeapSnapshotChunk"
    end
  end

  struct HeapStatsUpdateEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "statsUpdate", emit_null: false)]
    property stats_update : Array(Int64)

    def initialize(@stats_update : Array(Int64))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "HeapProfiler.heapStatsUpdate"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "HeapProfiler.heapStatsUpdate"
    end
  end

  struct LastSeenObjectIdEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "lastSeenObjectId", emit_null: false)]
    property last_seen_object_id : Int64
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : Float64

    def initialize(@last_seen_object_id : Int64, @timestamp : Float64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "HeapProfiler.lastSeenObjectId"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "HeapProfiler.lastSeenObjectId"
    end
  end

  struct ReportHeapSnapshotProgressEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "done", emit_null: false)]
    property done : Int64
    @[JSON::Field(key: "total", emit_null: false)]
    property total : Int64
    @[JSON::Field(key: "finished", emit_null: false)]
    property? finished : Bool?

    def initialize(@done : Int64, @total : Int64, @finished : Bool?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "HeapProfiler.reportHeapSnapshotProgress"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "HeapProfiler.reportHeapSnapshotProgress"
    end
  end

  struct ResetProfilesEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "HeapProfiler.resetProfiles"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "HeapProfiler.resetProfiles"
    end
  end
end
