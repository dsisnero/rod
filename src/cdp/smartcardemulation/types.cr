require "../cdp"
require "json"
require "time"

module Cdp::SmartCardEmulation
  alias ResultCode = String
  ResultCodeSuccess            = "success"
  ResultCodeRemovedCard        = "removed-card"
  ResultCodeResetCard          = "reset-card"
  ResultCodeUnpoweredCard      = "unpowered-card"
  ResultCodeUnresponsiveCard   = "unresponsive-card"
  ResultCodeUnsupportedCard    = "unsupported-card"
  ResultCodeReaderUnavailable  = "reader-unavailable"
  ResultCodeSharingViolation   = "sharing-violation"
  ResultCodeNotTransacted      = "not-transacted"
  ResultCodeNoSmartcard        = "no-smartcard"
  ResultCodeProtoMismatch      = "proto-mismatch"
  ResultCodeSystemCancelled    = "system-cancelled"
  ResultCodeNotReady           = "not-ready"
  ResultCodeCancelled          = "cancelled"
  ResultCodeInsufficientBuffer = "insufficient-buffer"
  ResultCodeInvalidHandle      = "invalid-handle"
  ResultCodeInvalidParameter   = "invalid-parameter"
  ResultCodeInvalidValue       = "invalid-value"
  ResultCodeNoMemory           = "no-memory"
  ResultCodeTimeout            = "timeout"
  ResultCodeUnknownReader      = "unknown-reader"
  ResultCodeUnsupportedFeature = "unsupported-feature"
  ResultCodeNoReadersAvailable = "no-readers-available"
  ResultCodeServiceStopped     = "service-stopped"
  ResultCodeNoService          = "no-service"
  ResultCodeCommError          = "comm-error"
  ResultCodeInternalError      = "internal-error"
  ResultCodeServerTooBusy      = "server-too-busy"
  ResultCodeUnexpected         = "unexpected"
  ResultCodeShutdown           = "shutdown"
  ResultCodeUnknownCard        = "unknown-card"
  ResultCodeUnknown            = "unknown"

  alias ShareMode = String
  ShareModeShared    = "shared"
  ShareModeExclusive = "exclusive"
  ShareModeDirect    = "direct"

  alias Disposition = String
  DispositionLeaveCard   = "leave-card"
  DispositionResetCard   = "reset-card"
  DispositionUnpowerCard = "unpower-card"
  DispositionEjectCard   = "eject-card"

  alias ConnectionState = String
  ConnectionStateAbsent     = "absent"
  ConnectionStatePresent    = "present"
  ConnectionStateSwallowed  = "swallowed"
  ConnectionStatePowered    = "powered"
  ConnectionStateNegotiable = "negotiable"
  ConnectionStateSpecific   = "specific"

  struct ReaderStateFlags
    include JSON::Serializable
    @[JSON::Field(key: "unaware", emit_null: false)]
    property? unaware : Bool?
    @[JSON::Field(key: "ignore", emit_null: false)]
    property? ignore : Bool?
    @[JSON::Field(key: "changed", emit_null: false)]
    property? changed : Bool?
    @[JSON::Field(key: "unknown", emit_null: false)]
    property? unknown : Bool?
    @[JSON::Field(key: "unavailable", emit_null: false)]
    property? unavailable : Bool?
    @[JSON::Field(key: "empty", emit_null: false)]
    property? empty : Bool?
    @[JSON::Field(key: "present", emit_null: false)]
    property? present : Bool?
    @[JSON::Field(key: "exclusive", emit_null: false)]
    property? exclusive : Bool?
    @[JSON::Field(key: "inuse", emit_null: false)]
    property? inuse : Bool?
    @[JSON::Field(key: "mute", emit_null: false)]
    property? mute : Bool?
    @[JSON::Field(key: "unpowered", emit_null: false)]
    property? unpowered : Bool?
  end

  struct ProtocolSet
    include JSON::Serializable
    @[JSON::Field(key: "t0", emit_null: false)]
    property? t0 : Bool?
    @[JSON::Field(key: "t1", emit_null: false)]
    property? t1 : Bool?
    @[JSON::Field(key: "raw", emit_null: false)]
    property? raw : Bool?
  end

  alias Protocol = String
  ProtocolT0  = "t0"
  ProtocolT1  = "t1"
  ProtocolRaw = "raw"

  struct ReaderStateIn
    include JSON::Serializable
    @[JSON::Field(key: "reader", emit_null: false)]
    property reader : String
    @[JSON::Field(key: "currentState", emit_null: false)]
    property current_state : ReaderStateFlags
    @[JSON::Field(key: "currentInsertionCount", emit_null: false)]
    property current_insertion_count : Int64
  end

  struct ReaderStateOut
    include JSON::Serializable
    @[JSON::Field(key: "reader", emit_null: false)]
    property reader : String
    @[JSON::Field(key: "eventState", emit_null: false)]
    property event_state : ReaderStateFlags
    @[JSON::Field(key: "eventCount", emit_null: false)]
    property event_count : Int64
    @[JSON::Field(key: "atr", emit_null: false)]
    property atr : String
  end
end
