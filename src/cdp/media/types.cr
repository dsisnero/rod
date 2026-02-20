require "../media/media"
require "json"
require "time"

module Cdp::Media
  alias PlayerId = String

  alias Timestamp = Float64

  struct PlayerMessage
    include JSON::Serializable

    property level : PlayerMessageLevel
    property message : String
  end

  struct PlayerProperty
    include JSON::Serializable

    property name : String
    property value : String
  end

  struct PlayerEvent
    include JSON::Serializable

    property timestamp : Timestamp
    property value : String
  end

  struct PlayerErrorSourceLocation
    include JSON::Serializable

    property file : String
    property line : Int64
  end

  struct PlayerError
    include JSON::Serializable

    property error_type : String
    property code : Int64
    property stack : Array(PlayerErrorSourceLocation)
    property cause : Array(PlayerError)
    property data : JSON::Any
  end

  struct Player
    include JSON::Serializable

    property player_id : PlayerId
    @[JSON::Field(emit_null: false)]
    property dom_node_id : Cdp::DOM::BackendNodeId?
  end

  alias PlayerMessageLevel = String
end
