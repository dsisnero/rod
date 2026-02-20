require "../serviceworker/serviceworker"
require "json"
require "time"

module Cdp::ServiceWorker
  struct WorkerErrorReportedEvent
    include JSON::Serializable
    include Cdp::Event

    property error_message : ServiceWorkerErrorMessage

    def initialize(@error_message : ServiceWorkerErrorMessage)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "ServiceWorker.workerErrorReported"
    end
  end

  struct WorkerRegistrationUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    property registrations : Array(ServiceWorkerRegistration)

    def initialize(@registrations : Array(ServiceWorkerRegistration))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "ServiceWorker.workerRegistrationUpdated"
    end
  end

  struct WorkerVersionUpdatedEvent
    include JSON::Serializable
    include Cdp::Event

    property versions : Array(ServiceWorkerVersion)

    def initialize(@versions : Array(ServiceWorkerVersion))
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "ServiceWorker.workerVersionUpdated"
    end
  end
end
