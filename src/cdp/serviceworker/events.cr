require "../cdp"
require "json"
require "time"

require "../target/target"

module Cdp::ServiceWorker
  struct WorkerErrorReportedEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property error_message : ServiceWorkerErrorMessage

    def initialize(@error_message : ServiceWorkerErrorMessage)
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
    property registrations : Array(ServiceWorkerRegistration)

    def initialize(@registrations : Array(ServiceWorkerRegistration))
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
    property versions : Array(ServiceWorkerVersion)

    def initialize(@versions : Array(ServiceWorkerVersion))
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
