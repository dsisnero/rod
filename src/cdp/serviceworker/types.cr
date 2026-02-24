require "../cdp"
require "json"
require "time"

require "../target/target"

module Cdp::ServiceWorker
  alias RegistrationID = String

  struct ServiceWorkerRegistration
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(emit_null: false)]
    property scope_url : String
    @[JSON::Field(emit_null: false)]
    property? is_deleted : Bool
  end

  alias ServiceWorkerVersionRunningStatus = String
  ServiceWorkerVersionRunningStatusStopped  = "stopped"
  ServiceWorkerVersionRunningStatusStarting = "starting"
  ServiceWorkerVersionRunningStatusRunning  = "running"
  ServiceWorkerVersionRunningStatusStopping = "stopping"

  alias ServiceWorkerVersionStatus = String
  ServiceWorkerVersionStatusNew        = "new"
  ServiceWorkerVersionStatusInstalling = "installing"
  ServiceWorkerVersionStatusInstalled  = "installed"
  ServiceWorkerVersionStatusActivating = "activating"
  ServiceWorkerVersionStatusActivated  = "activated"
  ServiceWorkerVersionStatusRedundant  = "redundant"

  struct ServiceWorkerVersion
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property version_id : String
    @[JSON::Field(emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(emit_null: false)]
    property script_url : String
    @[JSON::Field(emit_null: false)]
    property running_status : ServiceWorkerVersionRunningStatus
    @[JSON::Field(emit_null: false)]
    property status : ServiceWorkerVersionStatus
    @[JSON::Field(emit_null: false)]
    property script_last_modified : Float64?
    @[JSON::Field(emit_null: false)]
    property script_response_time : Float64?
    @[JSON::Field(emit_null: false)]
    property controlled_clients : Array(Cdp::Target::TargetID)?
    @[JSON::Field(emit_null: false)]
    property target_id : Cdp::Target::TargetID?
    @[JSON::Field(emit_null: false)]
    property router_rules : String?
  end

  struct ServiceWorkerErrorMessage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property error_message : String
    @[JSON::Field(emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(emit_null: false)]
    property version_id : String
    @[JSON::Field(emit_null: false)]
    property source_url : String
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64
  end
end
