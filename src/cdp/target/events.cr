require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Target
  @[Experimental]
  struct AttachedToTargetEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property session_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property target_info : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? waiting_for_debugger : Bool

    def initialize(@session_id : Cdp::NodeType, @target_info : Cdp::NodeType, @waiting_for_debugger : Bool)
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
    @[JSON::Field(emit_null: false)]
    property session_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property target_id : Cdp::NodeType?

    def initialize(@session_id : Cdp::NodeType, @target_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property session_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property message : String
    @[JSON::Field(emit_null: false)]
    property target_id : Cdp::NodeType?

    def initialize(@session_id : Cdp::NodeType, @message : String, @target_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property target_info : Cdp::NodeType

    def initialize(@target_info : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property target_id : Cdp::NodeType

    def initialize(@target_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property target_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property status : String
    @[JSON::Field(emit_null: false)]
    property error_code : Int64

    def initialize(@target_id : Cdp::NodeType, @status : String, @error_code : Int64)
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
    @[JSON::Field(emit_null: false)]
    property target_info : Cdp::NodeType

    def initialize(@target_info : Cdp::NodeType)
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
