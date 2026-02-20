require "../serviceworker/serviceworker"
require "json"
require "time"

module Cdp::ServiceWorker
  alias RegistrationID = String

  struct ServiceWorkerRegistration
    include JSON::Serializable

    property registration_id : RegistrationID
    property scope_url : String
    property is_deleted : Bool
  end

  alias ServiceWorkerVersionRunningStatus = String

  alias ServiceWorkerVersionStatus = String

  struct ServiceWorkerVersion
    include JSON::Serializable

    property version_id : String
    property registration_id : RegistrationID
    property script_url : String
    property running_status : ServiceWorkerVersionRunningStatus
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

    property error_message : String
    property registration_id : RegistrationID
    property version_id : String
    property source_url : String
    property line_number : Int64
    property column_number : Int64
  end
end
