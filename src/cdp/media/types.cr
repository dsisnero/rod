require "../cdp"
require "json"
require "base64"
require "time"

require "../dom/dom"

module Cdp::Media
  alias PlayerId = String

  alias Timestamp = Float64

  struct PlayerMessage
    include JSON::Serializable
    @[JSON::Field(key: "level", emit_null: false)]
    property level : PlayerMessageLevel
    @[JSON::Field(key: "message", emit_null: false)]
    property message : String

    def initialize(@level : PlayerMessageLevel, @message : String)
    end
  end

  struct PlayerProperty
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String

    def initialize(@name : String, @value : String)
    end
  end

  struct PlayerEvent
    include JSON::Serializable
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : Timestamp
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String

    def initialize(@timestamp : Timestamp, @value : String)
    end
  end

  struct PlayerErrorSourceLocation
    include JSON::Serializable
    @[JSON::Field(key: "file", emit_null: false)]
    property file : String
    @[JSON::Field(key: "line", emit_null: false)]
    property line : Int64

    def initialize(@file : String, @line : Int64)
    end
  end

  class PlayerError
    include JSON::Serializable
    @[JSON::Field(key: "errorType", emit_null: false)]
    property error_type : String
    @[JSON::Field(key: "code", emit_null: false)]
    property code : Int64
    @[JSON::Field(key: "stack", emit_null: false)]
    property stack : Array(PlayerErrorSourceLocation)
    @[JSON::Field(key: "cause", emit_null: false)]
    property cause : Array(PlayerError)
    @[JSON::Field(key: "data", emit_null: false)]
    property data : JSON::Any

    def initialize(@error_type : String, @code : Int64, @stack : Array(PlayerErrorSourceLocation), @cause : Array(PlayerError), @data : JSON::Any)
    end
  end

  struct Player
    include JSON::Serializable
    @[JSON::Field(key: "playerId", emit_null: false)]
    property player_id : PlayerId
    @[JSON::Field(key: "domNodeId", emit_null: false)]
    property dom_node_id : Cdp::DOM::BackendNodeId?

    def initialize(@player_id : PlayerId, @dom_node_id : Cdp::DOM::BackendNodeId? = nil)
    end
  end

  alias PlayerMessageLevel = String
  PlayerMessageLevelError   = "error"
  PlayerMessageLevelWarning = "warning"
  PlayerMessageLevelInfo    = "info"
  PlayerMessageLevelDebug   = "debug"
end
