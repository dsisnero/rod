require "../cdp"
require "json"
require "time"

require "../dom/dom"
require "../runtime/runtime"

module Cdp::Animation
  struct AnimationCanceledEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : String

    def initialize(@id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationCanceled"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Animation.animationCanceled"
    end
  end

  struct AnimationCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property id : String

    def initialize(@id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Animation.animationCreated"
    end
  end

  struct AnimationStartedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property animation : Animation

    def initialize(@animation : Animation)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationStarted"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Animation.animationStarted"
    end
  end

  struct AnimationUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property animation : Animation

    def initialize(@animation : Animation)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Animation.animationUpdated"
    end
  end
end
