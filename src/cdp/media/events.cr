require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Media
  struct PlayerPropertiesChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property player_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property properties : Array(Cdp::NodeType)

    def initialize(@player_id : Cdp::NodeType, @properties : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property player_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property events : Array(Cdp::NodeType)

    def initialize(@player_id : Cdp::NodeType, @events : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property player_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property messages : Array(Cdp::NodeType)

    def initialize(@player_id : Cdp::NodeType, @messages : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property player_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property errors : Array(Cdp::NodeType)

    def initialize(@player_id : Cdp::NodeType, @errors : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property player : Cdp::NodeType

    def initialize(@player : Cdp::NodeType)
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
