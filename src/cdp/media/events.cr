require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Media
  struct PlayerPropertiesChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "playerId", emit_null: false)]
    property player_id : PlayerId
    @[JSON::Field(key: "properties", emit_null: false)]
    property properties : Array(PlayerProperty)

    def initialize(@player_id : PlayerId, @properties : Array(PlayerProperty))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerPropertiesChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Media.playerPropertiesChanged"
    end
  end

  struct PlayerEventsAddedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "playerId", emit_null: false)]
    property player_id : PlayerId
    @[JSON::Field(key: "events", emit_null: false)]
    property events : Array(PlayerEvent)

    def initialize(@player_id : PlayerId, @events : Array(PlayerEvent))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerEventsAdded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Media.playerEventsAdded"
    end
  end

  struct PlayerMessagesLoggedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "playerId", emit_null: false)]
    property player_id : PlayerId
    @[JSON::Field(key: "messages", emit_null: false)]
    property messages : Array(PlayerMessage)

    def initialize(@player_id : PlayerId, @messages : Array(PlayerMessage))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerMessagesLogged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Media.playerMessagesLogged"
    end
  end

  struct PlayerErrorsRaisedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "playerId", emit_null: false)]
    property player_id : PlayerId
    @[JSON::Field(key: "errors", emit_null: false)]
    property errors : Array(PlayerError)

    def initialize(@player_id : PlayerId, @errors : Array(PlayerError))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerErrorsRaised"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Media.playerErrorsRaised"
    end
  end

  struct PlayerCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "player", emit_null: false)]
    property player : Player

    def initialize(@player : Player)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Media.playerCreated"
    end
  end
end
