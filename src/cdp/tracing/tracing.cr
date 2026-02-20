require "json"
require "../cdp"
require "../io/io"
require "./types"

module Cdp::Tracing
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
  struct GetCategoriesResult
    include JSON::Serializable

    property categories : Array(String)

    def initialize(@categories : Array(String))
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
  struct GetTrackEventDescriptorResult
    include JSON::Serializable

    property descriptor : String

    def initialize(@descriptor : String)
    end
  end

  @[Experimental]
  struct RecordClockSyncMarker
    include JSON::Serializable
    include Cdp::Request

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
    property deterministic : Bool?
    @[JSON::Field(emit_null: false)]
    property level_of_detail : MemoryDumpLevelOfDetail?

    def initialize(@deterministic : Bool?, @level_of_detail : MemoryDumpLevelOfDetail?)
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

  @[Experimental]
  struct RequestMemoryDumpResult
    include JSON::Serializable

    property dump_guid : String
    property success : Bool

    def initialize(@dump_guid : String, @success : Bool)
    end
  end

  struct Start
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property buffer_usage_reporting_interval : Float64?
    @[JSON::Field(emit_null: false)]
    property transfer_mode : TransferMode?
    @[JSON::Field(emit_null: false)]
    property stream_format : StreamFormat?
    @[JSON::Field(emit_null: false)]
    property stream_compression : StreamCompression?
    @[JSON::Field(emit_null: false)]
    property trace_config : TraceConfig?
    @[JSON::Field(emit_null: false)]
    property perfetto_config : String?
    @[JSON::Field(emit_null: false)]
    property tracing_backend : TracingBackend?

    def initialize(@buffer_usage_reporting_interval : Float64?, @transfer_mode : TransferMode?, @stream_format : StreamFormat?, @stream_compression : StreamCompression?, @trace_config : TraceConfig?, @perfetto_config : String?, @tracing_backend : TracingBackend?)
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
