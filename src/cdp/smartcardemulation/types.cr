require "../smartcardemulation/smartcardemulation"
require "json"
require "time"

module Cdp::SmartCardEmulation
  alias ResultCode = String

  alias ShareMode = String

  alias Disposition = String

  alias ConnectionState = String

  struct ReaderStateFlags
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property unaware : Bool?
    @[JSON::Field(emit_null: false)]
    property ignore : Bool?
    @[JSON::Field(emit_null: false)]
    property changed : Bool?
    @[JSON::Field(emit_null: false)]
    property unknown : Bool?
    @[JSON::Field(emit_null: false)]
    property unavailable : Bool?
    @[JSON::Field(emit_null: false)]
    property empty : Bool?
    @[JSON::Field(emit_null: false)]
    property present : Bool?
    @[JSON::Field(emit_null: false)]
    property exclusive : Bool?
    @[JSON::Field(emit_null: false)]
    property inuse : Bool?
    @[JSON::Field(emit_null: false)]
    property mute : Bool?
    @[JSON::Field(emit_null: false)]
    property unpowered : Bool?
  end

  struct ProtocolSet
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property t0 : Bool?
    @[JSON::Field(emit_null: false)]
    property t1 : Bool?
    @[JSON::Field(emit_null: false)]
    property raw : Bool?
  end

  alias Protocol = String

  struct ReaderStateIn
    include JSON::Serializable

    property reader : String
    property current_state : ReaderStateFlags
    property current_insertion_count : Int64
  end

  struct ReaderStateOut
    include JSON::Serializable

    property reader : String
    property event_state : ReaderStateFlags
    property event_count : Int64
    property atr : String
  end
end
