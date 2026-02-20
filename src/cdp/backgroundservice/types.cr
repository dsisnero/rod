require "../backgroundservice/backgroundservice"
require "json"
require "time"

module Cdp::BackgroundService
  alias ServiceName = String

  struct EventMetadata
    include JSON::Serializable

    property key : String
    property value : String
  end

  struct BackgroundServiceEvent
    include JSON::Serializable

    property timestamp : Cdp::Network::TimeSinceEpoch
    property origin : String
    property service_worker_registration_id : Cdp::ServiceWorker::RegistrationID
    property service : ServiceName
    property event_name : String
    property instance_id : String
    property event_metadata : Array(EventMetadata)
    property storage_key : String
  end
end
