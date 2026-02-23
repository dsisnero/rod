
require "../cdp"
require "json"
require "time"

require "../runtime/runtime"
require "../network/network"

module Cdp::Log
  struct LogEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property source : Source
    @[JSON::Field(emit_null: false)]
    property level : Level
    @[JSON::Field(emit_null: false)]
    property text : String
    @[JSON::Field(emit_null: false)]
    property category : LogEntryCategory?
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::Runtime::Timestamp
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property line_number : Int64?
    @[JSON::Field(emit_null: false)]
    property stack_trace : Cdp::Runtime::StackTrace?
    @[JSON::Field(emit_null: false)]
    property network_request_id : Cdp::Network::RequestId?
    @[JSON::Field(emit_null: false)]
    property worker_id : String?
    @[JSON::Field(emit_null: false)]
    property args : Array(Cdp::Runtime::RemoteObject)?
  end

  struct ViolationSetting
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : Violation
    @[JSON::Field(emit_null: false)]
    property threshold : Float64
  end

  alias Source = String

  alias Level = String

  alias LogEntryCategory = String

  alias Violation = String

   end
