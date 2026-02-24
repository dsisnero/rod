require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Media
  alias PlayerId = String

  alias Timestamp = Float64

  struct PlayerMessage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property level : PlayerMessageLevel
    @[JSON::Field(emit_null: false)]
    property message : String
  end

  struct PlayerProperty
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  struct PlayerEvent
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property timestamp : Timestamp
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  struct PlayerErrorSourceLocation
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property file : String
    @[JSON::Field(emit_null: false)]
    property line : Int64
  end

  struct PlayerError
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property error_type : String
    @[JSON::Field(emit_null: false)]
    property code : Int64
    @[JSON::Field(emit_null: false)]
    property stack : Array(PlayerErrorSourceLocation)
    @[JSON::Field(emit_null: false)]
    property cause : Array(PlayerError)
    @[JSON::Field(emit_null: false)]
    property data : JSON::Any
  end

  struct Player
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property player_id : PlayerId
    @[JSON::Field(emit_null: false)]
    property dom_node_id : Cdp::DOM::BackendNodeId?
  end

  alias PlayerMessageLevel = String
  PlayerMessageLevelError   = "error"
  PlayerMessageLevelWarning = "warning"
  PlayerMessageLevelInfo    = "info"
  PlayerMessageLevelDebug   = "debug"
end
