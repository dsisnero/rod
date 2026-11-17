require "../cdp"
require "json"
require "base64"
require "time"

require "../target/target"

module Cdp::ServiceWorker
  alias RegistrationID = String

  struct ServiceWorkerRegistration
    include JSON::Serializable
    @[JSON::Field(key: "registrationId", emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(key: "scopeURL", emit_null: false)]
    property scope_url : String
    @[JSON::Field(key: "isDeleted", emit_null: false)]
    property? is_deleted : Bool

    def initialize(@registration_id : RegistrationID, @scope_url : String, @is_deleted : Bool)
    end
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

  class ServiceWorkerRouterCondition
    include JSON::Serializable
    @[JSON::Field(key: "urlPattern", emit_null: false)]
    property url_pattern : String?
    @[JSON::Field(key: "requestMethod", emit_null: false)]
    property request_method : String?
    @[JSON::Field(key: "requestMode", emit_null: false)]
    property request_mode : String?
    @[JSON::Field(key: "requestDestination", emit_null: false)]
    property request_destination : String?
    @[JSON::Field(key: "runningStatus", emit_null: false)]
    property running_status : ServiceWorkerVersionRunningStatus?
    @[JSON::Field(key: "or", emit_null: false)]
    property or : Array(ServiceWorkerRouterCondition)?
    @[JSON::Field(key: "not", emit_null: false)]
    property not : ServiceWorkerRouterCondition?

    def initialize(@url_pattern : String? = nil, @request_method : String? = nil, @request_mode : String? = nil, @request_destination : String? = nil, @running_status : ServiceWorkerVersionRunningStatus? = nil, @or : Array(ServiceWorkerRouterCondition)? = nil, @not : ServiceWorkerRouterCondition? = nil)
    end
  end

  alias ServiceWorkerRouterSourceType = String
  ServiceWorkerRouterSourceTypeCache                      = "cache"
  ServiceWorkerRouterSourceTypeFetchEvent                 = "fetchEvent"
  ServiceWorkerRouterSourceTypeNetwork                    = "network"
  ServiceWorkerRouterSourceTypeRaceNetworkAndFetchHandler = "raceNetworkAndFetchHandler"
  ServiceWorkerRouterSourceTypeRaceNetworkAndCache        = "raceNetworkAndCache"
  ServiceWorkerRouterSourceTypeSourceDict                 = "sourceDict"

  struct ServiceWorkerRouterSourceDict
    include JSON::Serializable
    @[JSON::Field(key: "cacheName", emit_null: false)]
    property cache_name : String

    def initialize(@cache_name : String)
    end
  end

  struct ServiceWorkerRouterSource
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : ServiceWorkerRouterSourceType
    @[JSON::Field(key: "sourceDict", emit_null: false)]
    property source_dict : ServiceWorkerRouterSourceDict?

    def initialize(@type : ServiceWorkerRouterSourceType, @source_dict : ServiceWorkerRouterSourceDict? = nil)
    end
  end

  struct ServiceWorkerRouterRule
    include JSON::Serializable
    @[JSON::Field(key: "condition", emit_null: false)]
    property condition : ServiceWorkerRouterCondition
    @[JSON::Field(key: "source", emit_null: false)]
    property source : ServiceWorkerRouterSource
    @[JSON::Field(key: "id", emit_null: false)]
    property id : Int64

    def initialize(@condition : ServiceWorkerRouterCondition, @source : ServiceWorkerRouterSource, @id : Int64)
    end
  end

  struct ServiceWorkerVersion
    include JSON::Serializable
    @[JSON::Field(key: "versionId", emit_null: false)]
    property version_id : String
    @[JSON::Field(key: "registrationId", emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(key: "scriptURL", emit_null: false)]
    property script_url : String
    @[JSON::Field(key: "runningStatus", emit_null: false)]
    property running_status : ServiceWorkerVersionRunningStatus
    @[JSON::Field(key: "status", emit_null: false)]
    property status : ServiceWorkerVersionStatus
    @[JSON::Field(key: "scriptLastModified", emit_null: false)]
    property script_last_modified : Float64?
    @[JSON::Field(key: "scriptResponseTime", emit_null: false)]
    property script_response_time : Float64?
    @[JSON::Field(key: "controlledClients", emit_null: false)]
    property controlled_clients : Array(Cdp::Target::TargetID)?
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : Cdp::Target::TargetID?
    @[JSON::Field(key: "routerRules", emit_null: false)]
    property router_rules : String?
    @[JSON::Field(key: "typedRouterRules", emit_null: false)]
    property typed_router_rules : Array(ServiceWorkerRouterRule)?

    def initialize(@version_id : String, @registration_id : RegistrationID, @script_url : String, @running_status : ServiceWorkerVersionRunningStatus, @status : ServiceWorkerVersionStatus, @script_last_modified : Float64? = nil, @script_response_time : Float64? = nil, @controlled_clients : Array(Cdp::Target::TargetID)? = nil, @target_id : Cdp::Target::TargetID? = nil, @router_rules : String? = nil, @typed_router_rules : Array(ServiceWorkerRouterRule)? = nil)
    end
  end

  struct ServiceWorkerErrorMessage
    include JSON::Serializable
    @[JSON::Field(key: "errorMessage", emit_null: false)]
    property error_message : String
    @[JSON::Field(key: "registrationId", emit_null: false)]
    property registration_id : RegistrationID
    @[JSON::Field(key: "versionId", emit_null: false)]
    property version_id : String
    @[JSON::Field(key: "sourceURL", emit_null: false)]
    property source_url : String
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Int64
    @[JSON::Field(key: "columnNumber", emit_null: false)]
    property column_number : Int64

    def initialize(@error_message : String, @registration_id : RegistrationID, @version_id : String, @source_url : String, @line_number : Int64, @column_number : Int64)
    end
  end
end
