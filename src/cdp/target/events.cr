require "../target/target"
require "json"
require "time"
require "../browser/browser"

module Cdp::Target
  @[Experimental]
  struct AttachedToTargetEvent
    include JSON::Serializable
    include Cdp::Event

    property session_id : SessionID
    property target_info : TargetInfo
    property waiting_for_debugger : Bool

    def initialize(@session_id : SessionID, @target_info : TargetInfo, @waiting_for_debugger : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.attachedToTarget"
    end
  end

  @[Experimental]
  struct DetachedFromTargetEvent
    include JSON::Serializable
    include Cdp::Event

    property session_id : SessionID

    def initialize(@session_id : SessionID)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.detachedFromTarget"
    end
  end

  struct ReceivedMessageFromTargetEvent
    include JSON::Serializable
    include Cdp::Event

    property session_id : SessionID
    property message : String

    def initialize(@session_id : SessionID, @message : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.receivedMessageFromTarget"
    end
  end

  struct TargetCreatedEvent
    include JSON::Serializable
    include Cdp::Event

    property target_info : TargetInfo

    def initialize(@target_info : TargetInfo)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetCreated"
    end
  end

  struct TargetDestroyedEvent
    include JSON::Serializable
    include Cdp::Event

    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetDestroyed"
    end
  end

  struct TargetCrashedEvent
    include JSON::Serializable
    include Cdp::Event

    property target_id : TargetID
    property status : String
    property error_code : Int64

    def initialize(@target_id : TargetID, @status : String, @error_code : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetCrashed"
    end
  end

  struct TargetInfoChangedEvent
    include JSON::Serializable
    include Cdp::Event

    property target_info : TargetInfo

    def initialize(@target_info : TargetInfo)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetInfoChanged"
    end
  end
end
