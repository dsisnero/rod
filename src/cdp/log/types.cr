require "../log/log"
require "json"
require "time"

module Cdp::Log
  struct LogEntry
    include JSON::Serializable

    property source : Source
    property level : Level
    property text : String
    @[JSON::Field(emit_null: false)]
    property category : LogEntryCategory?
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

    property name : Violation
    property threshold : Float64
  end

  alias Source = String

  alias Level = String

  alias LogEntryCategory = String

  alias Violation = String
end
