require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

#
@[Experimental]
module Cdp::LayerTree
  struct CompositingReasonsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property compositing_reasons : Array(String)
    @[JSON::Field(emit_null: false)]
    property compositing_reason_ids : Array(String)

    def initialize(@compositing_reasons : Array(String), @compositing_reason_ids : Array(String))
    end
  end

  struct LoadSnapshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property snapshot_id : SnapshotId

    def initialize(@snapshot_id : SnapshotId)
    end
  end

  struct MakeSnapshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property snapshot_id : SnapshotId

    def initialize(@snapshot_id : SnapshotId)
    end
  end

  struct ProfileSnapshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property timings : Array(PaintProfile)

    def initialize(@timings : Array(PaintProfile))
    end
  end

  struct ReplaySnapshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data_url : String

    def initialize(@data_url : String)
    end
  end

  struct SnapshotCommandLogResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property command_log : Array(JSON::Any)

    def initialize(@command_log : Array(JSON::Any))
    end
  end

  # Commands
  struct CompositingReasons
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property layer_id : LayerId

    def initialize(@layer_id : LayerId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.compositingReasons"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CompositingReasonsResult
      res = CompositingReasonsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.disable"
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
      "LayerTree.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct LoadSnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property tiles : Array(PictureTile)

    def initialize(@tiles : Array(PictureTile))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.loadSnapshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : LoadSnapshotResult
      res = LoadSnapshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct MakeSnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property layer_id : LayerId

    def initialize(@layer_id : LayerId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.makeSnapshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : MakeSnapshotResult
      res = MakeSnapshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ProfileSnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property snapshot_id : SnapshotId
    @[JSON::Field(emit_null: false)]
    property min_repeat_count : Int64?
    @[JSON::Field(emit_null: false)]
    property min_duration : Float64?
    @[JSON::Field(emit_null: false)]
    property clip_rect : Cdp::DOM::Rect?

    def initialize(@snapshot_id : SnapshotId, @min_repeat_count : Int64?, @min_duration : Float64?, @clip_rect : Cdp::DOM::Rect?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.profileSnapshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ProfileSnapshotResult
      res = ProfileSnapshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct ReleaseSnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property snapshot_id : SnapshotId

    def initialize(@snapshot_id : SnapshotId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.releaseSnapshot"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ReplaySnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property snapshot_id : SnapshotId
    @[JSON::Field(emit_null: false)]
    property from_step : Int64?
    @[JSON::Field(emit_null: false)]
    property to_step : Int64?
    @[JSON::Field(emit_null: false)]
    property scale : Float64?

    def initialize(@snapshot_id : SnapshotId, @from_step : Int64?, @to_step : Int64?, @scale : Float64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.replaySnapshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : ReplaySnapshotResult
      res = ReplaySnapshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SnapshotCommandLog
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property snapshot_id : SnapshotId

    def initialize(@snapshot_id : SnapshotId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "LayerTree.snapshotCommandLog"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SnapshotCommandLogResult
      res = SnapshotCommandLogResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
