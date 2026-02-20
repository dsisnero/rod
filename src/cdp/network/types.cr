require "../network/network"
require "json"
require "time"
require "../io/io"
require "../page/page"

module Cdp::Network
  alias ResourceType = String

  alias LoaderId = String

  alias RequestId = String

  alias InterceptionId = String

  alias ErrorReason = String

  alias TimeSinceEpoch = Time

  alias MonotonicTime = Time

  alias Headers = JSON::Any

  alias ConnectionType = String

  alias CookieSameSite = String

  @[Experimental]
  alias CookiePriority = String

  @[Experimental]
  alias CookieSourceScheme = String

  struct ResourceTiming
    include JSON::Serializable

    property request_time : Float64
    property proxy_start : Float64
    property proxy_end : Float64
    property dns_start : Float64
    property dns_end : Float64
    property connect_start : Float64
    property connect_end : Float64
    property ssl_start : Float64
    property ssl_end : Float64
    property worker_start : Float64
    property worker_ready : Float64
    property worker_fetch_start : Float64
    property worker_respond_with_settled : Float64
    @[JSON::Field(emit_null: false)]
    property worker_router_evaluation_start : Float64?
    @[JSON::Field(emit_null: false)]
    property worker_cache_lookup_start : Float64?
    property send_start : Float64
    property send_end : Float64
    property push_start : Float64
    property push_end : Float64
    property receive_headers_start : Float64
    property receive_headers_end : Float64
  end

  alias ResourcePriority = String

  @[Experimental]
  alias RenderBlockingBehavior = String

  struct PostDataEntry
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property bytes : String?
  end

  struct Request
    include JSON::Serializable

    property url : String
    @[JSON::Field(emit_null: false)]
    property url_fragment : String?
    property method : String
    property headers : Headers
    @[JSON::Field(emit_null: false)]
    property has_post_data : Bool?
    @[JSON::Field(emit_null: false)]
    property post_data_entries : Array(PostDataEntry)?
    @[JSON::Field(emit_null: false)]
    property mixed_content_type : Cdp::Security::MixedContentType?
    property initial_priority : ResourcePriority
    property referrer_policy : ReferrerPolicy
    @[JSON::Field(emit_null: false)]
    property is_link_preload : Bool?
    @[JSON::Field(emit_null: false)]
    property trust_token_params : TrustTokenParams?
    @[JSON::Field(emit_null: false)]
    property is_same_site : Bool?
    @[JSON::Field(emit_null: false)]
    property is_ad_related : Bool?
  end

  struct SignedCertificateTimestamp
    include JSON::Serializable

    property status : String
    property origin : String
    property log_description : String
    property log_id : String
    property timestamp : Float64
    property hash_algorithm : String
    property signature_algorithm : String
    property signature_data : String
  end

  struct SecurityDetails
    include JSON::Serializable

    property protocol : String
    property key_exchange : String
    @[JSON::Field(emit_null: false)]
    property key_exchange_group : String?
    property cipher : String
    @[JSON::Field(emit_null: false)]
    property mac : String?
    property certificate_id : Cdp::Security::CertificateId
    property subject_name : String
    property san_list : Array(String)
    property issuer : String
    property valid_from : TimeSinceEpoch
    property valid_to : TimeSinceEpoch
    property signed_certificate_timestamp_list : Array(SignedCertificateTimestamp)
    property certificate_transparency_compliance : CertificateTransparencyCompliance
    @[JSON::Field(emit_null: false)]
    property server_signature_algorithm : Int64?
    property encrypted_client_hello : Bool
  end

  alias CertificateTransparencyCompliance = String

  alias BlockedReason = String

  alias CorsError = String

  struct CorsErrorStatus
    include JSON::Serializable

    property cors_error : CorsError
    property failed_parameter : String
  end

  alias ServiceWorkerResponseSource = String

  @[Experimental]
  struct TrustTokenParams
    include JSON::Serializable

    property operation : TrustTokenOperationType
    property refresh_policy : TrustTokenParamsRefreshPolicy
    @[JSON::Field(emit_null: false)]
    property issuers : Array(String)?
  end

  @[Experimental]
  alias TrustTokenOperationType = String

  @[Experimental]
  alias AlternateProtocolUsage = String

  alias ServiceWorkerRouterSource = String

  @[Experimental]
  struct ServiceWorkerRouterInfo
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property rule_id_matched : Int64?
    @[JSON::Field(emit_null: false)]
    property matched_source_type : ServiceWorkerRouterSource?
    @[JSON::Field(emit_null: false)]
    property actual_source_type : ServiceWorkerRouterSource?
  end

  struct Response
    include JSON::Serializable

    property url : String
    property status : Int64
    property status_text : String
    property headers : Headers
    property mime_type : String
    property charset : String
    @[JSON::Field(emit_null: false)]
    property request_headers : Headers?
    property connection_reused : Bool
    property connection_id : Float64
    @[JSON::Field(emit_null: false)]
    property remote_ip_address : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?
    @[JSON::Field(emit_null: false)]
    property from_disk_cache : Bool?
    @[JSON::Field(emit_null: false)]
    property from_service_worker : Bool?
    @[JSON::Field(emit_null: false)]
    property from_prefetch_cache : Bool?
    @[JSON::Field(emit_null: false)]
    property from_early_hints : Bool?
    @[JSON::Field(emit_null: false)]
    property service_worker_router_info : ServiceWorkerRouterInfo?
    property encoded_data_length : Float64
    @[JSON::Field(emit_null: false)]
    property timing : ResourceTiming?
    @[JSON::Field(emit_null: false)]
    property service_worker_response_source : ServiceWorkerResponseSource?
    @[JSON::Field(emit_null: false)]
    property response_time : TimeSinceEpoch?
    @[JSON::Field(emit_null: false)]
    property cache_storage_cache_name : String?
    @[JSON::Field(emit_null: false)]
    property protocol : String?
    @[JSON::Field(emit_null: false)]
    property alternate_protocol_usage : AlternateProtocolUsage?
    property security_state : Cdp::Security::SecurityState
    @[JSON::Field(emit_null: false)]
    property security_details : SecurityDetails?
  end

  struct WebSocketRequest
    include JSON::Serializable

    property headers : Headers
  end

  struct WebSocketResponse
    include JSON::Serializable

    property status : Int64
    property status_text : String
    property headers : Headers
    @[JSON::Field(emit_null: false)]
    property headers_text : String?
    @[JSON::Field(emit_null: false)]
    property request_headers : Headers?
    @[JSON::Field(emit_null: false)]
    property request_headers_text : String?
  end

  struct WebSocketFrame
    include JSON::Serializable

    property opcode : Float64
    property mask : Bool
    property payload_data : String
  end

  struct CachedResource
    include JSON::Serializable

    property url : String
    property type : ResourceType
    @[JSON::Field(emit_null: false)]
    property response : Response?
    property body_size : Float64
  end

  struct Initiator
    include JSON::Serializable

    property type : InitiatorType
    @[JSON::Field(emit_null: false)]
    property stack : Cdp::Runtime::StackTrace?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property line_number : Float64?
    @[JSON::Field(emit_null: false)]
    property column_number : Float64?
    @[JSON::Field(emit_null: false)]
    property request_id : RequestId?
  end

  @[Experimental]
  struct CookiePartitionKey
    include JSON::Serializable

    property top_level_site : String
    property has_cross_site_ancestor : Bool
  end

  struct Cookie
    include JSON::Serializable

    property name : String
    property value : String
    property domain : String
    property path : String
    property expires : Float64
    property size : Int64
    property http_only : Bool
    property secure : Bool
    property session : Bool
    @[JSON::Field(emit_null: false)]
    property same_site : CookieSameSite?
    property priority : CookiePriority
    property source_scheme : CookieSourceScheme
    property source_port : Int64
    @[JSON::Field(emit_null: false)]
    property partition_key : CookiePartitionKey?
    @[JSON::Field(emit_null: false)]
    property partition_key_opaque : Bool?
  end

  @[Experimental]
  alias SetCookieBlockedReason = String

  @[Experimental]
  alias CookieBlockedReason = String

  @[Experimental]
  alias CookieExemptionReason = String

  @[Experimental]
  struct BlockedSetCookieWithReason
    include JSON::Serializable

    property blocked_reasons : Array(SetCookieBlockedReason)
    property cookie_line : String
    @[JSON::Field(emit_null: false)]
    property cookie : Cookie?
  end

  @[Experimental]
  struct ExemptedSetCookieWithReason
    include JSON::Serializable

    property exemption_reason : CookieExemptionReason
    property cookie_line : String
    property cookie : Cookie
  end

  @[Experimental]
  struct AssociatedCookie
    include JSON::Serializable

    property cookie : Cookie
    property blocked_reasons : Array(CookieBlockedReason)
    @[JSON::Field(emit_null: false)]
    property exemption_reason : CookieExemptionReason?
  end

  struct CookieParam
    include JSON::Serializable

    property name : String
    property value : String
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property domain : String?
    @[JSON::Field(emit_null: false)]
    property path : String?
    @[JSON::Field(emit_null: false)]
    property secure : Bool?
    @[JSON::Field(emit_null: false)]
    property http_only : Bool?
    @[JSON::Field(emit_null: false)]
    property same_site : CookieSameSite?
    @[JSON::Field(emit_null: false)]
    property expires : TimeSinceEpoch?
    @[JSON::Field(emit_null: false)]
    property priority : CookiePriority?
    @[JSON::Field(emit_null: false)]
    property source_scheme : CookieSourceScheme?
    @[JSON::Field(emit_null: false)]
    property source_port : Int64?
    @[JSON::Field(emit_null: false)]
    property partition_key : CookiePartitionKey?
  end

  @[Experimental]
  struct AuthChallenge
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property source : AuthChallengeSource?
    property origin : String
    property scheme : String
    property realm : String
  end

  @[Experimental]
  struct AuthChallengeResponse
    include JSON::Serializable

    property response : AuthChallengeResponseResponse
    @[JSON::Field(emit_null: false)]
    property username : String?
    @[JSON::Field(emit_null: false)]
    property password : String?
  end

  @[Experimental]
  alias InterceptionStage = String

  @[Experimental]
  struct RequestPattern
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property url_pattern : String?
    @[JSON::Field(emit_null: false)]
    property resource_type : ResourceType?
    @[JSON::Field(emit_null: false)]
    property interception_stage : InterceptionStage?
  end

  @[Experimental]
  struct SignedExchangeSignature
    include JSON::Serializable

    property label : String
    property signature : String
    property integrity : String
    @[JSON::Field(emit_null: false)]
    property cert_url : String?
    @[JSON::Field(emit_null: false)]
    property cert_sha256 : String?
    property validity_url : String
    property date : Int64
    property expires : Int64
    @[JSON::Field(emit_null: false)]
    property certificates : Array(String)?
  end

  @[Experimental]
  struct SignedExchangeHeader
    include JSON::Serializable

    property request_url : String
    property response_code : Int64
    property response_headers : Headers
    property signatures : Array(SignedExchangeSignature)
    property header_integrity : String
  end

  @[Experimental]
  alias SignedExchangeErrorField = String

  @[Experimental]
  struct SignedExchangeError
    include JSON::Serializable

    property message : String
    @[JSON::Field(emit_null: false)]
    property signature_index : Int64?
    @[JSON::Field(emit_null: false)]
    property error_field : SignedExchangeErrorField?
  end

  @[Experimental]
  struct SignedExchangeInfo
    include JSON::Serializable

    property outer_response : Response
    property has_extra_info : Bool
    @[JSON::Field(emit_null: false)]
    property header : SignedExchangeHeader?
    @[JSON::Field(emit_null: false)]
    property security_details : SecurityDetails?
    @[JSON::Field(emit_null: false)]
    property errors : Array(SignedExchangeError)?
  end

  @[Experimental]
  alias ContentEncoding = String

  @[Experimental]
  struct NetworkConditions
    include JSON::Serializable

    property url_pattern : String
    property latency : Float64
    property download_throughput : Float64
    property upload_throughput : Float64
    @[JSON::Field(emit_null: false)]
    property connection_type : ConnectionType?
    @[JSON::Field(emit_null: false)]
    property packet_loss : Float64?
    @[JSON::Field(emit_null: false)]
    property packet_queue_length : Int64?
    @[JSON::Field(emit_null: false)]
    property packet_reordering : Bool?
  end

  @[Experimental]
  struct BlockPattern
    include JSON::Serializable

    property url_pattern : String
    property block : Bool
  end

  @[Experimental]
  alias DirectSocketDnsQueryType = String

  @[Experimental]
  struct DirectTCPSocketOptions
    include JSON::Serializable

    property no_delay : Bool
    @[JSON::Field(emit_null: false)]
    property keep_alive_delay : Float64?
    @[JSON::Field(emit_null: false)]
    property send_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property receive_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property dns_query_type : DirectSocketDnsQueryType?
  end

  @[Experimental]
  struct DirectUDPSocketOptions
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property remote_addr : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?
    @[JSON::Field(emit_null: false)]
    property local_addr : String?
    @[JSON::Field(emit_null: false)]
    property local_port : Int64?
    @[JSON::Field(emit_null: false)]
    property dns_query_type : DirectSocketDnsQueryType?
    @[JSON::Field(emit_null: false)]
    property send_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property receive_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property multicast_loopback : Bool?
    @[JSON::Field(emit_null: false)]
    property multicast_time_to_live : Int64?
    @[JSON::Field(emit_null: false)]
    property multicast_allow_address_sharing : Bool?
  end

  @[Experimental]
  struct DirectUDPMessage
    include JSON::Serializable

    property data : String
    @[JSON::Field(emit_null: false)]
    property remote_addr : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?
  end

  @[Experimental]
  alias LocalNetworkAccessRequestPolicy = String

  @[Experimental]
  alias IPAddressSpace = String

  @[Experimental]
  struct ConnectTiming
    include JSON::Serializable

    property request_time : Float64
  end

  @[Experimental]
  struct ClientSecurityState
    include JSON::Serializable

    property initiator_is_secure_context : Bool
    property initiator_ip_address_space : IPAddressSpace
    property local_network_access_request_policy : LocalNetworkAccessRequestPolicy
  end

  @[Experimental]
  alias CrossOriginOpenerPolicyValue = String

  @[Experimental]
  struct CrossOriginOpenerPolicyStatus
    include JSON::Serializable

    property value : CrossOriginOpenerPolicyValue
    property report_only_value : CrossOriginOpenerPolicyValue
    @[JSON::Field(emit_null: false)]
    property reporting_endpoint : String?
    @[JSON::Field(emit_null: false)]
    property report_only_reporting_endpoint : String?
  end

  @[Experimental]
  alias CrossOriginEmbedderPolicyValue = String

  @[Experimental]
  struct CrossOriginEmbedderPolicyStatus
    include JSON::Serializable

    property value : CrossOriginEmbedderPolicyValue
    property report_only_value : CrossOriginEmbedderPolicyValue
    @[JSON::Field(emit_null: false)]
    property reporting_endpoint : String?
    @[JSON::Field(emit_null: false)]
    property report_only_reporting_endpoint : String?
  end

  @[Experimental]
  alias ContentSecurityPolicySource = String

  @[Experimental]
  struct ContentSecurityPolicyStatus
    include JSON::Serializable

    property effective_directives : String
    property is_enforced : Bool
    property source : ContentSecurityPolicySource
  end

  @[Experimental]
  struct SecurityIsolationStatus
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property coop : CrossOriginOpenerPolicyStatus?
    @[JSON::Field(emit_null: false)]
    property coep : CrossOriginEmbedderPolicyStatus?
    @[JSON::Field(emit_null: false)]
    property csp : Array(ContentSecurityPolicyStatus)?
  end

  @[Experimental]
  alias ReportStatus = String

  @[Experimental]
  alias ReportId = String

  @[Experimental]
  struct ReportingApiReport
    include JSON::Serializable

    property id : ReportId
    property initiator_url : String
    property destination : String
    property type : String
    property timestamp : TimeSinceEpoch
    property depth : Int64
    property completed_attempts : Int64
    property body : JSON::Any
    property status : ReportStatus
  end

  @[Experimental]
  struct ReportingApiEndpoint
    include JSON::Serializable

    property url : String
    property group_name : String
  end

  @[Experimental]
  struct DeviceBoundSessionKey
    include JSON::Serializable

    property site : String
    property id : String
  end

  @[Experimental]
  struct DeviceBoundSessionWithUsage
    include JSON::Serializable

    property session_key : DeviceBoundSessionKey
    property usage : DeviceBoundSessionWithUsageUsage
  end

  @[Experimental]
  struct DeviceBoundSessionCookieCraving
    include JSON::Serializable

    property name : String
    property domain : String
    property path : String
    property secure : Bool
    property http_only : Bool
    @[JSON::Field(emit_null: false)]
    property same_site : CookieSameSite?
  end

  @[Experimental]
  struct DeviceBoundSessionUrlRule
    include JSON::Serializable

    property rule_type : DeviceBoundSessionUrlRuleRuleType
    property host_pattern : String
    property path_prefix : String
  end

  @[Experimental]
  struct DeviceBoundSessionInclusionRules
    include JSON::Serializable

    property origin : String
    property include_site : Bool
    property url_rules : Array(DeviceBoundSessionUrlRule)
  end

  @[Experimental]
  struct DeviceBoundSession
    include JSON::Serializable

    property key : DeviceBoundSessionKey
    property refresh_url : String
    property inclusion_rules : DeviceBoundSessionInclusionRules
    property cookie_cravings : Array(DeviceBoundSessionCookieCraving)
    property expiry_date : TimeSinceEpoch
    @[JSON::Field(emit_null: false)]
    property cached_challenge : String?
    property allowed_refresh_initiators : Array(String)
  end

  @[Experimental]
  alias DeviceBoundSessionEventId = String

  @[Experimental]
  alias DeviceBoundSessionFetchResult = String

  @[Experimental]
  struct CreationEventDetails
    include JSON::Serializable

    property fetch_result : DeviceBoundSessionFetchResult
    @[JSON::Field(emit_null: false)]
    property new_session : DeviceBoundSession?
  end

  @[Experimental]
  struct RefreshEventDetails
    include JSON::Serializable

    property refresh_result : RefreshEventDetailsRefreshResult
    @[JSON::Field(emit_null: false)]
    property fetch_result : DeviceBoundSessionFetchResult?
    @[JSON::Field(emit_null: false)]
    property new_session : DeviceBoundSession?
    property was_fully_proactive_refresh : Bool
  end

  @[Experimental]
  struct TerminationEventDetails
    include JSON::Serializable

    property deletion_reason : TerminationEventDetailsDeletionReason
  end

  @[Experimental]
  struct ChallengeEventDetails
    include JSON::Serializable

    property challenge_result : ChallengeEventDetailsChallengeResult
    property challenge : String
  end

  @[Experimental]
  struct LoadNetworkResourcePageResult
    include JSON::Serializable

    property success : Bool
    @[JSON::Field(emit_null: false)]
    property net_error : Float64?
    @[JSON::Field(emit_null: false)]
    property net_error_name : String?
    @[JSON::Field(emit_null: false)]
    property http_status_code : Float64?
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::IO::StreamHandle?
    @[JSON::Field(emit_null: false)]
    property headers : Headers?
  end

  @[Experimental]
  struct LoadNetworkResourceOptions
    include JSON::Serializable

    property disable_cache : Bool
    property include_credentials : Bool
  end

  alias ReferrerPolicy = String

  alias TrustTokenParamsRefreshPolicy = String

  alias InitiatorType = String

  alias AuthChallengeSource = String

  alias AuthChallengeResponseResponse = String

  alias DeviceBoundSessionWithUsageUsage = String

  alias DeviceBoundSessionUrlRuleRuleType = String

  alias RefreshEventDetailsRefreshResult = String

  alias TerminationEventDetailsDeletionReason = String

  alias ChallengeEventDetailsChallengeResult = String

  alias TrustTokenOperationDoneStatus = String
end
