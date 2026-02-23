require "../cdp"
require "json"
require "time"

require "../network/network"
require "../serviceworker/serviceworker"

module Cdp::BackgroundService
  alias ServiceName = String
  ServiceNameBackgroundFetch        = "backgroundFetch"
  ServiceNameBackgroundSync         = "backgroundSync"
  ServiceNamePushMessaging          = "pushMessaging"
  ServiceNameNotifications          = "notifications"
  ServiceNamePaymentHandler         = "paymentHandler"
  ServiceNamePeriodicBackgroundSync = "periodicBackgroundSync"

  struct EventMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  struct BackgroundServiceEvent
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property service_worker_registration_id : Cdp::ServiceWorker::RegistrationID
    @[JSON::Field(emit_null: false)]
    property service : ServiceName
    @[JSON::Field(emit_null: false)]
    property event_name : String
    @[JSON::Field(emit_null: false)]
    property instance_id : String
    @[JSON::Field(emit_null: false)]
    property event_metadata : Array(EventMetadata)
    @[JSON::Field(emit_null: false)]
    property storage_key : String
  end
end
