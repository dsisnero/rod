require "../cdp"
require "json"
require "time"

require "../page/page"
require "../browser/browser"

module Cdp::Target
  @[Experimental]
  struct AttachedToTargetEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : SessionID
    @[JSON::Field(key: "targetInfo", emit_null: false)]
    property target_info : TargetInfo
    @[JSON::Field(key: "waitingForDebugger", emit_null: false)]
    property? waiting_for_debugger : Bool

    def initialize(@session_id : SessionID, @target_info : TargetInfo, @waiting_for_debugger : Bool)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.attachedToTarget"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.attachedToTarget"
    end
  end

  @[Experimental]
  struct DetachedFromTargetEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : SessionID
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID?

    def initialize(@session_id : SessionID, @target_id : TargetID?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.detachedFromTarget"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.detachedFromTarget"
    end
  end

  struct ReceivedMessageFromTargetEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : SessionID
    @[JSON::Field(key: "message", emit_null: false)]
    property message : String
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID?

    def initialize(@session_id : SessionID, @message : String, @target_id : TargetID?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.receivedMessageFromTarget"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.receivedMessageFromTarget"
    end
  end

  struct TargetCreatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "targetInfo", emit_null: false)]
    property target_info : TargetInfo

    def initialize(@target_info : TargetInfo)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetCreated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.targetCreated"
    end
  end

  struct TargetDestroyedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetDestroyed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.targetDestroyed"
    end
  end

  struct TargetCrashedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(key: "status", emit_null: false)]
    property status : String
    @[JSON::Field(key: "errorCode", emit_null: false)]
    property error_code : Int64

    def initialize(@target_id : TargetID, @status : String, @error_code : Int64)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetCrashed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.targetCrashed"
    end
  end

  struct TargetInfoChangedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "targetInfo", emit_null: false)]
    property target_info : TargetInfo

    def initialize(@target_info : TargetInfo)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Target.targetInfoChanged"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Target.targetInfoChanged"
    end
  end
end
