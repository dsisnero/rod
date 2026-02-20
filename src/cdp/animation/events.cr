require "../animation/animation"
require "json"
require "time"
require "../runtime/runtime"

module Cdp::Animation
  struct AnimationCanceledEvent
    include JSON::Serializable
    include Cdp::Event

    property id : String

    def initialize(@id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationCanceled"
    end
  end

  struct AnimationCreatedEvent
    include JSON::Serializable
    include Cdp::Event

    property id : String

    def initialize(@id : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationCreated"
    end
  end

  struct AnimationStartedEvent
    include JSON::Serializable
    include Cdp::Event

    property animation : Animation

    def initialize(@animation : Animation)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationStarted"
    end
  end

  struct AnimationUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    property animation : Animation

    def initialize(@animation : Animation)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Animation.animationUpdated"
    end
  end
end
