require "../cdp"
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
    property? enable_sampling : Bool?
    @[JSON::Field(emit_null: false)]
    property? enable_systrace : Bool?
    @[JSON::Field(emit_null: false)]
    property? enable_argument_filter : Bool?
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
