require "../cdp"
require "json"
require "base64"
require "time"

require "../io/io"

module Cdp::Tracing
  @[Experimental]
  struct MemoryDumpConfig
    include JSON::Serializable
  end

  struct TraceConfig
    include JSON::Serializable
    @[JSON::Field(key: "recordMode", emit_null: false)]
    property record_mode : RecordMode?
    @[JSON::Field(key: "traceBufferSizeInKb", emit_null: false)]
    property trace_buffer_size_in_kb : Float64?
    @[JSON::Field(key: "enableSampling", emit_null: false)]
    property? enable_sampling : Bool?
    @[JSON::Field(key: "enableSystrace", emit_null: false)]
    property? enable_systrace : Bool?
    @[JSON::Field(key: "enableArgumentFilter", emit_null: false)]
    property? enable_argument_filter : Bool?
    @[JSON::Field(key: "includedCategories", emit_null: false)]
    property included_categories : Array(String)?
    @[JSON::Field(key: "excludedCategories", emit_null: false)]
    property excluded_categories : Array(String)?
    @[JSON::Field(key: "syntheticDelays", emit_null: false)]
    property synthetic_delays : Array(String)?
    @[JSON::Field(key: "memoryDumpConfig", emit_null: false)]
    property memory_dump_config : MemoryDumpConfig?

    def initialize(@record_mode : RecordMode? = nil, @trace_buffer_size_in_kb : Float64? = nil, @enable_sampling : Bool? = nil, @enable_systrace : Bool? = nil, @enable_argument_filter : Bool? = nil, @included_categories : Array(String)? = nil, @excluded_categories : Array(String)? = nil, @synthetic_delays : Array(String)? = nil, @memory_dump_config : MemoryDumpConfig? = nil)
    end
  end

  @[Experimental]
  alias StreamFormat = String
  StreamFormatJson  = "json"
  StreamFormatProto = "proto"

  @[Experimental]
  alias StreamCompression = String
  StreamCompressionNone = "none"
  StreamCompressionGzip = "gzip"

  @[Experimental]
  alias MemoryDumpLevelOfDetail = String
  MemoryDumpLevelOfDetailBackground = "background"
  MemoryDumpLevelOfDetailLight      = "light"
  MemoryDumpLevelOfDetailDetailed   = "detailed"

  @[Experimental]
  alias TracingBackend = String
  TracingBackendAuto   = "auto"
  TracingBackendChrome = "chrome"
  TracingBackendSystem = "system"

  alias RecordMode = String
  RecordModeRecordUntilFull        = "recordUntilFull"
  RecordModeRecordContinuously     = "recordContinuously"
  RecordModeRecordAsMuchAsPossible = "recordAsMuchAsPossible"
  RecordModeEchoToConsole          = "echoToConsole"

  alias TransferMode = String
  TransferModeReportEvents   = "ReportEvents"
  TransferModeReturnAsStream = "ReturnAsStream"
end
