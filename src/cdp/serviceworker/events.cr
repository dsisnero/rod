require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::ServiceWorker
  struct WorkerErrorReportedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property error_message : Cdp::NodeType

    def initialize(@error_message : Cdp::NodeType)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "ServiceWorker.workerErrorReported"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "ServiceWorker.workerErrorReported"
    end
  end

  struct WorkerRegistrationUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property registrations : Array(Cdp::NodeType)

    def initialize(@registrations : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "ServiceWorker.workerRegistrationUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "ServiceWorker.workerRegistrationUpdated"
    end
  end

  struct WorkerVersionUpdatedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property versions : Array(Cdp::NodeType)

    def initialize(@versions : Array(Cdp::NodeType))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "ServiceWorker.workerVersionUpdated"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "ServiceWorker.workerVersionUpdated"
    end
  end
end
