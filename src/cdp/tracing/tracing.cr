require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

#
module Cdp::Tracing
  @[Experimental]
  struct GetCategoriesResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property categories : Array(String)

    def initialize(@categories : Array(String))
    end
  end

  @[Experimental]
  struct GetTrackEventDescriptorResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property descriptor : String

    def initialize(@descriptor : String)
    end
  end

  @[Experimental]
  struct RequestMemoryDumpResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property dump_guid : String
    @[JSON::Field(emit_null: false)]
    property? success : Bool

    def initialize(@dump_guid : String, @success : Bool)
    end
  end

  # Commands
  struct End
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tracing.end"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetCategories
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tracing.getCategories"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetCategoriesResult
      res = GetCategoriesResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetTrackEventDescriptor
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tracing.getTrackEventDescriptor"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetTrackEventDescriptorResult
      res = GetTrackEventDescriptorResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct RecordClockSyncMarker
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property sync_id : String

    def initialize(@sync_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tracing.recordClockSyncMarker"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct RequestMemoryDump
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? deterministic : Bool?
    @[JSON::Field(emit_null: false)]
    property level_of_detail : Cdp::NodeType?

    def initialize(@deterministic : Bool?, @level_of_detail : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tracing.requestMemoryDump"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : RequestMemoryDumpResult
      res = RequestMemoryDumpResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct Start
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property buffer_usage_reporting_interval : Float64?
    @[JSON::Field(emit_null: false)]
    property transfer_mode : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property stream_format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property stream_compression : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property trace_config : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property perfetto_config : String?
    @[JSON::Field(emit_null: false)]
    property tracing_backend : Cdp::NodeType?

    def initialize(@buffer_usage_reporting_interval : Float64?, @transfer_mode : Cdp::NodeType?, @stream_format : Cdp::NodeType?, @stream_compression : Cdp::NodeType?, @trace_config : Cdp::NodeType?, @perfetto_config : String?, @tracing_backend : Cdp::NodeType?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Tracing.start"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
