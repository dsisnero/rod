require "../cdp"
require "json"
require "time"

require "../dom/dom"

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
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property service_worker_registration_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property service : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property event_name : String
    @[JSON::Field(emit_null: false)]
    property instance_id : String
    @[JSON::Field(emit_null: false)]
    property event_metadata : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property storage_key : String
  end
end
