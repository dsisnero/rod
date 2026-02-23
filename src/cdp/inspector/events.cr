require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Inspector
  struct DetachedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property reason : Cdp::NodeType

    def initialize(@reason : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Inspector.detached"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Inspector.detached"
    end
  end

  struct TargetCrashedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Inspector.targetCrashed"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Inspector.targetCrashed"
    end
  end

  struct TargetReloadedAfterCrashEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Inspector.targetReloadedAfterCrash"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Inspector.targetReloadedAfterCrash"
    end
  end

  @[Experimental]
  struct WorkerScriptLoadedEvent
    include JSON::Serializable
    include Cdp::Event

    def initialize
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Inspector.workerScriptLoaded"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Inspector.workerScriptLoaded"
    end
  end
end
