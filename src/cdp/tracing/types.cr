require "../tracing/tracing"
require "json"
require "time"
require "../io/io"

module Cdp::Tracing
  @[Experimental]
  struct MemoryDumpConfig
    include JSON::Serializable
  end

  struct TraceConfig
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property record_mode : RecordMode?
    @[JSON::Field(emit_null: false)]
    property trace_buffer_size_in_kb : Float64?
    @[JSON::Field(emit_null: false)]
    property enable_sampling : Bool?
    @[JSON::Field(emit_null: false)]
    property enable_systrace : Bool?
    @[JSON::Field(emit_null: false)]
    property enable_argument_filter : Bool?
    @[JSON::Field(emit_null: false)]
    property included_categories : Array(String)?
    @[JSON::Field(emit_null: false)]
    property excluded_categories : Array(String)?
    @[JSON::Field(emit_null: false)]
    property synthetic_delays : Array(String)?
    @[JSON::Field(emit_null: false)]
    property memory_dump_config : MemoryDumpConfig?
  end

  @[Experimental]
  alias StreamFormat = String

  @[Experimental]
  alias StreamCompression = String

  @[Experimental]
  alias MemoryDumpLevelOfDetail = String

  @[Experimental]
  alias TracingBackend = String

  alias RecordMode = String

  alias TransferMode = String
end
