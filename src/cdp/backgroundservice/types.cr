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
    @[JSON::Field(key: "key", emit_null: false)]
    property key : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
  end

  struct BackgroundServiceEvent
    include JSON::Serializable
    @[JSON::Field(key: "timestamp", emit_null: false)]
    property timestamp : Cdp::Network::TimeSinceEpoch
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String
    @[JSON::Field(key: "serviceWorkerRegistrationId", emit_null: false)]
    property service_worker_registration_id : Cdp::ServiceWorker::RegistrationID
    @[JSON::Field(key: "service", emit_null: false)]
    property service : ServiceName
    @[JSON::Field(key: "eventName", emit_null: false)]
    property event_name : String
    @[JSON::Field(key: "instanceId", emit_null: false)]
    property instance_id : String
    @[JSON::Field(key: "eventMetadata", emit_null: false)]
    property event_metadata : Array(EventMetadata)
    @[JSON::Field(key: "storageKey", emit_null: false)]
    property storage_key : String
  end
end
