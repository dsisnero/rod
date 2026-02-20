require "../media/media"
require "json"
require "time"

module Cdp::Media
  struct PlayerPropertiesChangedEvent
    include JSON::Serializable
    include Cdp::Event

    property player_id : PlayerId
    property properties : Array(PlayerProperty)

    def initialize(@player_id : PlayerId, @properties : Array(PlayerProperty))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerPropertiesChanged"
    end
  end

  struct PlayerEventsAddedEvent
    include JSON::Serializable
    include Cdp::Event

    property player_id : PlayerId
    property events : Array(PlayerEvent)

    def initialize(@player_id : PlayerId, @events : Array(PlayerEvent))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerEventsAdded"
    end
  end

  struct PlayerMessagesLoggedEvent
    include JSON::Serializable
    include Cdp::Event

    property player_id : PlayerId
    property messages : Array(PlayerMessage)

    def initialize(@player_id : PlayerId, @messages : Array(PlayerMessage))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerMessagesLogged"
    end
  end

  struct PlayerErrorsRaisedEvent
    include JSON::Serializable
    include Cdp::Event

    property player_id : PlayerId
    property errors : Array(PlayerError)

    def initialize(@player_id : PlayerId, @errors : Array(PlayerError))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerErrorsRaised"
    end
  end

  struct PlayerCreatedEvent
    include JSON::Serializable
    include Cdp::Event

    property player : Player

    def initialize(@player : Player)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Media.playerCreated"
    end
  end
end
