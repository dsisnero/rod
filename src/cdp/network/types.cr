require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Network
  alias ResourceType = String
  ResourceTypeDocument           = "Document"
  ResourceTypeStylesheet         = "Stylesheet"
  ResourceTypeImage              = "Image"
  ResourceTypeMedia              = "Media"
  ResourceTypeFont               = "Font"
  ResourceTypeScript             = "Script"
  ResourceTypeTextTrack          = "TextTrack"
  ResourceTypeXHR                = "XHR"
  ResourceTypeFetch              = "Fetch"
  ResourceTypePrefetch           = "Prefetch"
  ResourceTypeEventSource        = "EventSource"
  ResourceTypeWebSocket          = "WebSocket"
  ResourceTypeManifest           = "Manifest"
  ResourceTypeSignedExchange     = "SignedExchange"
  ResourceTypePing               = "Ping"
  ResourceTypeCSPViolationReport = "CSPViolationReport"
  ResourceTypePreflight          = "Preflight"
  ResourceTypeFedCM              = "FedCM"
  ResourceTypeOther              = "Other"

  alias LoaderId = String

  alias RequestId = String

  alias InterceptionId = String

  alias ErrorReason = String
  ErrorReasonFailed               = "Failed"
  ErrorReasonAborted              = "Aborted"
  ErrorReasonTimedOut             = "TimedOut"
  ErrorReasonAccessDenied         = "AccessDenied"
  ErrorReasonConnectionClosed     = "ConnectionClosed"
  ErrorReasonConnectionReset      = "ConnectionReset"
  ErrorReasonConnectionRefused    = "ConnectionRefused"
  ErrorReasonConnectionAborted    = "ConnectionAborted"
  ErrorReasonConnectionFailed     = "ConnectionFailed"
  ErrorReasonNameNotResolved      = "NameNotResolved"
  ErrorReasonInternetDisconnected = "InternetDisconnected"
  ErrorReasonAddressUnreachable   = "AddressUnreachable"
  ErrorReasonBlockedByClient      = "BlockedByClient"
  ErrorReasonBlockedByResponse    = "BlockedByResponse"

  alias TimeSinceEpoch = Time

  alias MonotonicTime = Time

  alias Headers = JSON::Any

  alias ConnectionType = String
  ConnectionTypeNone       = "none"
  ConnectionTypeCellular2g = "cellular2g"
  ConnectionTypeCellular3g = "cellular3g"
  ConnectionTypeCellular4g = "cellular4g"
  ConnectionTypeBluetooth  = "bluetooth"
  ConnectionTypeEthernet   = "ethernet"
  ConnectionTypeWifi       = "wifi"
  ConnectionTypeWimax      = "wimax"
  ConnectionTypeOther      = "other"

  alias CookieSameSite = String
  CookieSameSiteStrict = "Strict"
  CookieSameSiteLax    = "Lax"
  CookieSameSiteNone   = "None"

  @[Experimental]
  alias CookiePriority = String
  CookiePriorityLow    = "Low"
  CookiePriorityMedium = "Medium"
  CookiePriorityHigh   = "High"

  @[Experimental]
  alias CookieSourceScheme = String
  CookieSourceSchemeUnset     = "Unset"
  CookieSourceSchemeNonSecure = "NonSecure"
  CookieSourceSchemeSecure    = "Secure"

  struct ResourceTiming
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property request_time : Float64
    @[JSON::Field(emit_null: false)]
    property proxy_start : Float64
    @[JSON::Field(emit_null: false)]
    property proxy_end : Float64
    @[JSON::Field(emit_null: false)]
    property dns_start : Float64
    @[JSON::Field(emit_null: false)]
    property dns_end : Float64
    @[JSON::Field(emit_null: false)]
    property connect_start : Float64
    @[JSON::Field(emit_null: false)]
    property connect_end : Float64
    @[JSON::Field(emit_null: false)]
    property ssl_start : Float64
    @[JSON::Field(emit_null: false)]
    property ssl_end : Float64
    @[JSON::Field(emit_null: false)]
    property worker_start : Float64
    @[JSON::Field(emit_null: false)]
    property worker_ready : Float64
    @[JSON::Field(emit_null: false)]
    property worker_fetch_start : Float64
    @[JSON::Field(emit_null: false)]
    property worker_respond_with_settled : Float64
    @[JSON::Field(emit_null: false)]
    property worker_router_evaluation_start : Float64?
    @[JSON::Field(emit_null: false)]
    property worker_cache_lookup_start : Float64?
    @[JSON::Field(emit_null: false)]
    property send_start : Float64
    @[JSON::Field(emit_null: false)]
    property send_end : Float64
    @[JSON::Field(emit_null: false)]
    property push_start : Float64
    @[JSON::Field(emit_null: false)]
    property push_end : Float64
    @[JSON::Field(emit_null: false)]
    property receive_headers_start : Float64
    @[JSON::Field(emit_null: false)]
    property receive_headers_end : Float64
  end

  alias ResourcePriority = String
  ResourcePriorityVeryLow  = "VeryLow"
  ResourcePriorityLow      = "Low"
  ResourcePriorityMedium   = "Medium"
  ResourcePriorityHigh     = "High"
  ResourcePriorityVeryHigh = "VeryHigh"

  @[Experimental]
  alias RenderBlockingBehavior = String
  RenderBlockingBehaviorBlocking             = "Blocking"
  RenderBlockingBehaviorInBodyParserBlocking = "InBodyParserBlocking"
  RenderBlockingBehaviorNonBlocking          = "NonBlocking"
  RenderBlockingBehaviorNonBlockingDynamic   = "NonBlockingDynamic"
  RenderBlockingBehaviorPotentiallyBlocking  = "PotentiallyBlocking"

  struct PostDataEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property bytes : String?
  end

  struct Request
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property url_fragment : String?
    @[JSON::Field(emit_null: false)]
    property method : String
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? has_post_data : Bool?
    @[JSON::Field(emit_null: false)]
    property post_data_entries : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property mixed_content_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property initial_priority : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property referrer_policy : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_link_preload : Bool?
    @[JSON::Field(emit_null: false)]
    property trust_token_params : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? is_same_site : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_ad_related : Bool?
  end

  struct SignedCertificateTimestamp
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property status : String
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property log_description : String
    @[JSON::Field(emit_null: false)]
    property log_id : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Float64
    @[JSON::Field(emit_null: false)]
    property hash_algorithm : String
    @[JSON::Field(emit_null: false)]
    property signature_algorithm : String
    @[JSON::Field(emit_null: false)]
    property signature_data : String
  end

  struct SecurityDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property protocol : String
    @[JSON::Field(emit_null: false)]
    property key_exchange : String
    @[JSON::Field(emit_null: false)]
    property key_exchange_group : String?
    @[JSON::Field(emit_null: false)]
    property cipher : String
    @[JSON::Field(emit_null: false)]
    property mac : String?
    @[JSON::Field(emit_null: false)]
    property certificate_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property subject_name : String
    @[JSON::Field(emit_null: false)]
    property san_list : Array(String)
    @[JSON::Field(emit_null: false)]
    property issuer : String
    @[JSON::Field(emit_null: false)]
    property valid_from : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property valid_to : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property signed_certificate_timestamp_list : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property certificate_transparency_compliance : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property server_signature_algorithm : Int64?
    @[JSON::Field(emit_null: false)]
    property? encrypted_client_hello : Bool
  end

  alias CertificateTransparencyCompliance = String
  CertificateTransparencyComplianceUnknown      = "unknown"
  CertificateTransparencyComplianceNotCompliant = "not-compliant"
  CertificateTransparencyComplianceCompliant    = "compliant"

  alias BlockedReason = String
  BlockedReasonOther                                                   = "other"
  BlockedReasonCsp                                                     = "csp"
  BlockedReasonMixedContent                                            = "mixed-content"
  BlockedReasonOrigin                                                  = "origin"
  BlockedReasonInspector                                               = "inspector"
  BlockedReasonIntegrity                                               = "integrity"
  BlockedReasonSubresourceFilter                                       = "subresource-filter"
  BlockedReasonContentType                                             = "content-type"
  BlockedReasonCoepFrameResourceNeedsCoepHeader                        = "coep-frame-resource-needs-coep-header"
  BlockedReasonCoopSandboxedIframeCannotNavigateToCoopPage             = "coop-sandboxed-iframe-cannot-navigate-to-coop-page"
  BlockedReasonCorpNotSameOrigin                                       = "corp-not-same-origin"
  BlockedReasonCorpNotSameOriginAfterDefaultedToSameOriginByCoep       = "corp-not-same-origin-after-defaulted-to-same-origin-by-coep"
  BlockedReasonCorpNotSameOriginAfterDefaultedToSameOriginByDip        = "corp-not-same-origin-after-defaulted-to-same-origin-by-dip"
  BlockedReasonCorpNotSameOriginAfterDefaultedToSameOriginByCoepAndDip = "corp-not-same-origin-after-defaulted-to-same-origin-by-coep-and-dip"
  BlockedReasonCorpNotSameSite                                         = "corp-not-same-site"
  BlockedReasonSriMessageSignatureMismatch                             = "sri-message-signature-mismatch"

  alias CorsError = String
  CorsErrorDisallowedByMode                     = "DisallowedByMode"
  CorsErrorInvalidResponse                      = "InvalidResponse"
  CorsErrorWildcardOriginNotAllowed             = "WildcardOriginNotAllowed"
  CorsErrorMissingAllowOriginHeader             = "MissingAllowOriginHeader"
  CorsErrorMultipleAllowOriginValues            = "MultipleAllowOriginValues"
  CorsErrorInvalidAllowOriginValue              = "InvalidAllowOriginValue"
  CorsErrorAllowOriginMismatch                  = "AllowOriginMismatch"
  CorsErrorInvalidAllowCredentials              = "InvalidAllowCredentials"
  CorsErrorCorsDisabledScheme                   = "CorsDisabledScheme"
  CorsErrorPreflightInvalidStatus               = "PreflightInvalidStatus"
  CorsErrorPreflightDisallowedRedirect          = "PreflightDisallowedRedirect"
  CorsErrorPreflightWildcardOriginNotAllowed    = "PreflightWildcardOriginNotAllowed"
  CorsErrorPreflightMissingAllowOriginHeader    = "PreflightMissingAllowOriginHeader"
  CorsErrorPreflightMultipleAllowOriginValues   = "PreflightMultipleAllowOriginValues"
  CorsErrorPreflightInvalidAllowOriginValue     = "PreflightInvalidAllowOriginValue"
  CorsErrorPreflightAllowOriginMismatch         = "PreflightAllowOriginMismatch"
  CorsErrorPreflightInvalidAllowCredentials     = "PreflightInvalidAllowCredentials"
  CorsErrorPreflightMissingAllowExternal        = "PreflightMissingAllowExternal"
  CorsErrorPreflightInvalidAllowExternal        = "PreflightInvalidAllowExternal"
  CorsErrorInvalidAllowMethodsPreflightResponse = "InvalidAllowMethodsPreflightResponse"
  CorsErrorInvalidAllowHeadersPreflightResponse = "InvalidAllowHeadersPreflightResponse"
  CorsErrorMethodDisallowedByPreflightResponse  = "MethodDisallowedByPreflightResponse"
  CorsErrorHeaderDisallowedByPreflightResponse  = "HeaderDisallowedByPreflightResponse"
  CorsErrorRedirectContainsCredentials          = "RedirectContainsCredentials"
  CorsErrorInsecureLocalNetwork                 = "InsecureLocalNetwork"
  CorsErrorInvalidLocalNetworkAccess            = "InvalidLocalNetworkAccess"
  CorsErrorNoCorsRedirectModeNotFollow          = "NoCorsRedirectModeNotFollow"
  CorsErrorLocalNetworkAccessPermissionDenied   = "LocalNetworkAccessPermissionDenied"

  struct CorsErrorStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cors_error : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property failed_parameter : String
  end

  alias ServiceWorkerResponseSource = String
  ServiceWorkerResponseSourceCacheStorage = "cache-storage"
  ServiceWorkerResponseSourceHttpCache    = "http-cache"
  ServiceWorkerResponseSourceFallbackCode = "fallback-code"
  ServiceWorkerResponseSourceNetwork      = "network"

  @[Experimental]
  struct TrustTokenParams
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property operation : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property refresh_policy : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property issuers : Array(String)?
  end

  @[Experimental]
  alias TrustTokenOperationType = String
  TrustTokenOperationTypeIssuance   = "Issuance"
  TrustTokenOperationTypeRedemption = "Redemption"
  TrustTokenOperationTypeSigning    = "Signing"

  @[Experimental]
  alias AlternateProtocolUsage = String
  AlternateProtocolUsageAlternativeJobWonWithoutRace = "alternativeJobWonWithoutRace"
  AlternateProtocolUsageAlternativeJobWonRace        = "alternativeJobWonRace"
  AlternateProtocolUsageMainJobWonRace               = "mainJobWonRace"
  AlternateProtocolUsageMappingMissing               = "mappingMissing"
  AlternateProtocolUsageBroken                       = "broken"
  AlternateProtocolUsageDnsAlpnH3JobWonWithoutRace   = "dnsAlpnH3JobWonWithoutRace"
  AlternateProtocolUsageDnsAlpnH3JobWonRace          = "dnsAlpnH3JobWonRace"
  AlternateProtocolUsageUnspecifiedReason            = "unspecifiedReason"

  alias ServiceWorkerRouterSource = String
  ServiceWorkerRouterSourceNetwork                    = "network"
  ServiceWorkerRouterSourceCache                      = "cache"
  ServiceWorkerRouterSourceFetchEvent                 = "fetch-event"
  ServiceWorkerRouterSourceRaceNetworkAndFetchHandler = "race-network-and-fetch-handler"
  ServiceWorkerRouterSourceRaceNetworkAndCache        = "race-network-and-cache"

  @[Experimental]
  struct ServiceWorkerRouterInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule_id_matched : Int64?
    @[JSON::Field(emit_null: false)]
    property matched_source_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property actual_source_type : Cdp::NodeType?
  end

  struct Response
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property status : Int64
    @[JSON::Field(emit_null: false)]
    property status_text : String
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property charset : String
    @[JSON::Field(emit_null: false)]
    property request_headers : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? connection_reused : Bool
    @[JSON::Field(emit_null: false)]
    property connection_id : Float64
    @[JSON::Field(emit_null: false)]
    property remote_ip_address : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?
    @[JSON::Field(emit_null: false)]
    property? from_disk_cache : Bool?
    @[JSON::Field(emit_null: false)]
    property? from_service_worker : Bool?
    @[JSON::Field(emit_null: false)]
    property? from_prefetch_cache : Bool?
    @[JSON::Field(emit_null: false)]
    property? from_early_hints : Bool?
    @[JSON::Field(emit_null: false)]
    property service_worker_router_info : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property encoded_data_length : Float64
    @[JSON::Field(emit_null: false)]
    property timing : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property service_worker_response_source : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property response_time : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cache_storage_cache_name : String?
    @[JSON::Field(emit_null: false)]
    property protocol : String?
    @[JSON::Field(emit_null: false)]
    property alternate_protocol_usage : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property security_state : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property security_details : Cdp::NodeType?
  end

  struct WebSocketRequest
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType
  end

  struct WebSocketResponse
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property status : Int64
    @[JSON::Field(emit_null: false)]
    property status_text : String
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property headers_text : String?
    @[JSON::Field(emit_null: false)]
    property request_headers : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property request_headers_text : String?
  end

  struct WebSocketFrame
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property opcode : Float64
    @[JSON::Field(emit_null: false)]
    property? mask : Bool
    @[JSON::Field(emit_null: false)]
    property payload_data : String
  end

  struct CachedResource
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property body_size : Float64
  end

  struct Initiator
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property stack : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property line_number : Float64?
    @[JSON::Field(emit_null: false)]
    property column_number : Float64?
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType?
  end

  @[Experimental]
  struct CookiePartitionKey
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property top_level_site : String
    @[JSON::Field(emit_null: false)]
    property? has_cross_site_ancestor : Bool
  end

  struct Cookie
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property domain : String
    @[JSON::Field(emit_null: false)]
    property path : String
    @[JSON::Field(emit_null: false)]
    property expires : Float64
    @[JSON::Field(emit_null: false)]
    property size : Int64
    @[JSON::Field(emit_null: false)]
    property? http_only : Bool
    @[JSON::Field(emit_null: false)]
    property? secure : Bool
    @[JSON::Field(emit_null: false)]
    property? session : Bool
    @[JSON::Field(emit_null: false)]
    property same_site : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property priority : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_scheme : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_port : Int64
    @[JSON::Field(emit_null: false)]
    property partition_key : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? partition_key_opaque : Bool?
  end

  @[Experimental]
  alias SetCookieBlockedReason = String
  SetCookieBlockedReasonSecureOnly                               = "SecureOnly"
  SetCookieBlockedReasonSameSiteStrict                           = "SameSiteStrict"
  SetCookieBlockedReasonSameSiteLax                              = "SameSiteLax"
  SetCookieBlockedReasonSameSiteUnspecifiedTreatedAsLax          = "SameSiteUnspecifiedTreatedAsLax"
  SetCookieBlockedReasonSameSiteNoneInsecure                     = "SameSiteNoneInsecure"
  SetCookieBlockedReasonUserPreferences                          = "UserPreferences"
  SetCookieBlockedReasonThirdPartyPhaseout                       = "ThirdPartyPhaseout"
  SetCookieBlockedReasonThirdPartyBlockedInFirstPartySet         = "ThirdPartyBlockedInFirstPartySet"
  SetCookieBlockedReasonSyntaxError                              = "SyntaxError"
  SetCookieBlockedReasonSchemeNotSupported                       = "SchemeNotSupported"
  SetCookieBlockedReasonOverwriteSecure                          = "OverwriteSecure"
  SetCookieBlockedReasonInvalidDomain                            = "InvalidDomain"
  SetCookieBlockedReasonInvalidPrefix                            = "InvalidPrefix"
  SetCookieBlockedReasonUnknownError                             = "UnknownError"
  SetCookieBlockedReasonSchemefulSameSiteStrict                  = "SchemefulSameSiteStrict"
  SetCookieBlockedReasonSchemefulSameSiteLax                     = "SchemefulSameSiteLax"
  SetCookieBlockedReasonSchemefulSameSiteUnspecifiedTreatedAsLax = "SchemefulSameSiteUnspecifiedTreatedAsLax"
  SetCookieBlockedReasonNameValuePairExceedsMaxSize              = "NameValuePairExceedsMaxSize"
  SetCookieBlockedReasonDisallowedCharacter                      = "DisallowedCharacter"
  SetCookieBlockedReasonNoCookieContent                          = "NoCookieContent"

  @[Experimental]
  alias CookieBlockedReason = String
  CookieBlockedReasonSecureOnly                               = "SecureOnly"
  CookieBlockedReasonNotOnPath                                = "NotOnPath"
  CookieBlockedReasonDomainMismatch                           = "DomainMismatch"
  CookieBlockedReasonSameSiteStrict                           = "SameSiteStrict"
  CookieBlockedReasonSameSiteLax                              = "SameSiteLax"
  CookieBlockedReasonSameSiteUnspecifiedTreatedAsLax          = "SameSiteUnspecifiedTreatedAsLax"
  CookieBlockedReasonSameSiteNoneInsecure                     = "SameSiteNoneInsecure"
  CookieBlockedReasonUserPreferences                          = "UserPreferences"
  CookieBlockedReasonThirdPartyPhaseout                       = "ThirdPartyPhaseout"
  CookieBlockedReasonThirdPartyBlockedInFirstPartySet         = "ThirdPartyBlockedInFirstPartySet"
  CookieBlockedReasonUnknownError                             = "UnknownError"
  CookieBlockedReasonSchemefulSameSiteStrict                  = "SchemefulSameSiteStrict"
  CookieBlockedReasonSchemefulSameSiteLax                     = "SchemefulSameSiteLax"
  CookieBlockedReasonSchemefulSameSiteUnspecifiedTreatedAsLax = "SchemefulSameSiteUnspecifiedTreatedAsLax"
  CookieBlockedReasonNameValuePairExceedsMaxSize              = "NameValuePairExceedsMaxSize"
  CookieBlockedReasonPortMismatch                             = "PortMismatch"
  CookieBlockedReasonSchemeMismatch                           = "SchemeMismatch"
  CookieBlockedReasonAnonymousContext                         = "AnonymousContext"

  @[Experimental]
  alias CookieExemptionReason = String
  CookieExemptionReasonNone                         = "None"
  CookieExemptionReasonUserSetting                  = "UserSetting"
  CookieExemptionReasonTPCDMetadata                 = "TPCDMetadata"
  CookieExemptionReasonTPCDDeprecationTrial         = "TPCDDeprecationTrial"
  CookieExemptionReasonTopLevelTPCDDeprecationTrial = "TopLevelTPCDDeprecationTrial"
  CookieExemptionReasonTPCDHeuristics               = "TPCDHeuristics"
  CookieExemptionReasonEnterprisePolicy             = "EnterprisePolicy"
  CookieExemptionReasonStorageAccess                = "StorageAccess"
  CookieExemptionReasonTopLevelStorageAccess        = "TopLevelStorageAccess"
  CookieExemptionReasonScheme                       = "Scheme"
  CookieExemptionReasonSameSiteNoneCookiesInSandbox = "SameSiteNoneCookiesInSandbox"

  @[Experimental]
  struct BlockedSetCookieWithReason
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property blocked_reasons : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property cookie_line : String
    @[JSON::Field(emit_null: false)]
    property cookie : Cdp::NodeType?
  end

  @[Experimental]
  struct ExemptedSetCookieWithReason
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property exemption_reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property cookie_line : String
    @[JSON::Field(emit_null: false)]
    property cookie : Cdp::NodeType
  end

  @[Experimental]
  struct AssociatedCookie
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cookie : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property blocked_reasons : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property exemption_reason : Cdp::NodeType?
  end

  struct CookieParam
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property domain : String?
    @[JSON::Field(emit_null: false)]
    property path : String?
    @[JSON::Field(emit_null: false)]
    property? secure : Bool?
    @[JSON::Field(emit_null: false)]
    property? http_only : Bool?
    @[JSON::Field(emit_null: false)]
    property same_site : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property expires : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property priority : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_scheme : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_port : Int64?
    @[JSON::Field(emit_null: false)]
    property partition_key : Cdp::NodeType?
  end

  @[Experimental]
  struct AuthChallenge
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property source : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property scheme : String
    @[JSON::Field(emit_null: false)]
    property realm : String
  end

  @[Experimental]
  struct AuthChallengeResponse
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property response : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property username : String?
    @[JSON::Field(emit_null: false)]
    property password : String?
  end

  @[Experimental]
  alias InterceptionStage = String
  InterceptionStageRequest         = "Request"
  InterceptionStageHeadersReceived = "HeadersReceived"

  @[Experimental]
  struct RequestPattern
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url_pattern : String?
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property interception_stage : Cdp::NodeType?
  end

  @[Experimental]
  struct SignedExchangeSignature
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property label : String
    @[JSON::Field(emit_null: false)]
    property signature : String
    @[JSON::Field(emit_null: false)]
    property integrity : String
    @[JSON::Field(emit_null: false)]
    property cert_url : String?
    @[JSON::Field(emit_null: false)]
    property cert_sha256 : String?
    @[JSON::Field(emit_null: false)]
    property validity_url : String
    @[JSON::Field(emit_null: false)]
    property date : Int64
    @[JSON::Field(emit_null: false)]
    property expires : Int64
    @[JSON::Field(emit_null: false)]
    property certificates : Array(String)?
  end

  @[Experimental]
  struct SignedExchangeHeader
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property request_url : String
    @[JSON::Field(emit_null: false)]
    property response_code : Int64
    @[JSON::Field(emit_null: false)]
    property response_headers : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property signatures : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property header_integrity : String
  end

  @[Experimental]
  alias SignedExchangeErrorField = String
  SignedExchangeErrorFieldSignatureSig         = "signatureSig"
  SignedExchangeErrorFieldSignatureIntegrity   = "signatureIntegrity"
  SignedExchangeErrorFieldSignatureCertUrl     = "signatureCertUrl"
  SignedExchangeErrorFieldSignatureCertSha256  = "signatureCertSha256"
  SignedExchangeErrorFieldSignatureValidityUrl = "signatureValidityUrl"
  SignedExchangeErrorFieldSignatureTimestamps  = "signatureTimestamps"

  @[Experimental]
  struct SignedExchangeError
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property message : String
    @[JSON::Field(emit_null: false)]
    property signature_index : Int64?
    @[JSON::Field(emit_null: false)]
    property error_field : Cdp::NodeType?
  end

  @[Experimental]
  struct SignedExchangeInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property outer_response : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? has_extra_info : Bool
    @[JSON::Field(emit_null: false)]
    property header : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property security_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property errors : Array(Cdp::NodeType)?
  end

  @[Experimental]
  alias ContentEncoding = String
  ContentEncodingDeflate = "deflate"
  ContentEncodingGzip    = "gzip"
  ContentEncodingBr      = "br"
  ContentEncodingZstd    = "zstd"

  @[Experimental]
  struct NetworkConditions
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url_pattern : String
    @[JSON::Field(emit_null: false)]
    property latency : Float64
    @[JSON::Field(emit_null: false)]
    property download_throughput : Float64
    @[JSON::Field(emit_null: false)]
    property upload_throughput : Float64
    @[JSON::Field(emit_null: false)]
    property connection_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property packet_loss : Float64?
    @[JSON::Field(emit_null: false)]
    property packet_queue_length : Int64?
    @[JSON::Field(emit_null: false)]
    property? packet_reordering : Bool?
  end

  @[Experimental]
  struct BlockPattern
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url_pattern : String
    @[JSON::Field(emit_null: false)]
    property? block : Bool
  end

  @[Experimental]
  alias DirectSocketDnsQueryType = String
  DirectSocketDnsQueryTypeIpv4 = "ipv4"
  DirectSocketDnsQueryTypeIpv6 = "ipv6"

  @[Experimental]
  struct DirectTCPSocketOptions
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? no_delay : Bool
    @[JSON::Field(emit_null: false)]
    property keep_alive_delay : Float64?
    @[JSON::Field(emit_null: false)]
    property send_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property receive_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property dns_query_type : Cdp::NodeType?
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
    property dns_query_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property send_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property receive_buffer_size : Float64?
    @[JSON::Field(emit_null: false)]
    property? multicast_loopback : Bool?
    @[JSON::Field(emit_null: false)]
    property multicast_time_to_live : Int64?
    @[JSON::Field(emit_null: false)]
    property? multicast_allow_address_sharing : Bool?
  end

  @[Experimental]
  struct DirectUDPMessage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property remote_addr : String?
    @[JSON::Field(emit_null: false)]
    property remote_port : Int64?
  end

  @[Experimental]
  alias LocalNetworkAccessRequestPolicy = String
  LocalNetworkAccessRequestPolicyAllow                          = "Allow"
  LocalNetworkAccessRequestPolicyBlockFromInsecureToMorePrivate = "BlockFromInsecureToMorePrivate"
  LocalNetworkAccessRequestPolicyWarnFromInsecureToMorePrivate  = "WarnFromInsecureToMorePrivate"
  LocalNetworkAccessRequestPolicyPermissionBlock                = "PermissionBlock"
  LocalNetworkAccessRequestPolicyPermissionWarn                 = "PermissionWarn"

  @[Experimental]
  alias IPAddressSpace = String
  IPAddressSpaceLoopback = "Loopback"
  IPAddressSpaceLocal    = "Local"
  IPAddressSpacePublic   = "Public"
  IPAddressSpaceUnknown  = "Unknown"

  @[Experimental]
  struct ConnectTiming
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property request_time : Float64
  end

  @[Experimental]
  struct ClientSecurityState
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? initiator_is_secure_context : Bool
    @[JSON::Field(emit_null: false)]
    property initiator_ip_address_space : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property local_network_access_request_policy : Cdp::NodeType
  end

  @[Experimental]
  alias CrossOriginOpenerPolicyValue = String
  CrossOriginOpenerPolicyValueSameOrigin                 = "SameOrigin"
  CrossOriginOpenerPolicyValueSameOriginAllowPopups      = "SameOriginAllowPopups"
  CrossOriginOpenerPolicyValueRestrictProperties         = "RestrictProperties"
  CrossOriginOpenerPolicyValueUnsafeNone                 = "UnsafeNone"
  CrossOriginOpenerPolicyValueSameOriginPlusCoep         = "SameOriginPlusCoep"
  CrossOriginOpenerPolicyValueRestrictPropertiesPlusCoep = "RestrictPropertiesPlusCoep"
  CrossOriginOpenerPolicyValueNoopenerAllowPopups        = "NoopenerAllowPopups"

  @[Experimental]
  struct CrossOriginOpenerPolicyStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property report_only_value : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property reporting_endpoint : String?
    @[JSON::Field(emit_null: false)]
    property report_only_reporting_endpoint : String?
  end

  @[Experimental]
  alias CrossOriginEmbedderPolicyValue = String
  CrossOriginEmbedderPolicyValueNone           = "None"
  CrossOriginEmbedderPolicyValueCredentialless = "Credentialless"
  CrossOriginEmbedderPolicyValueRequireCorp    = "RequireCorp"

  @[Experimental]
  struct CrossOriginEmbedderPolicyStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property value : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property report_only_value : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property reporting_endpoint : String?
    @[JSON::Field(emit_null: false)]
    property report_only_reporting_endpoint : String?
  end

  @[Experimental]
  alias ContentSecurityPolicySource = String
  ContentSecurityPolicySourceHTTP = "HTTP"
  ContentSecurityPolicySourceMeta = "Meta"

  @[Experimental]
  struct ContentSecurityPolicyStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property effective_directives : String
    @[JSON::Field(emit_null: false)]
    property? is_enforced : Bool
    @[JSON::Field(emit_null: false)]
    property source : Cdp::NodeType
  end

  @[Experimental]
  struct SecurityIsolationStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property coop : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property coep : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property csp : Array(Cdp::NodeType)?
  end

  @[Experimental]
  alias ReportStatus = String
  ReportStatusQueued           = "Queued"
  ReportStatusPending          = "Pending"
  ReportStatusMarkedForRemoval = "MarkedForRemoval"
  ReportStatusSuccess          = "Success"

  @[Experimental]
  alias ReportId = String

  @[Experimental]
  struct ReportingApiReport
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property initiator_url : String
    @[JSON::Field(emit_null: false)]
    property destination : String
    @[JSON::Field(emit_null: false)]
    property type : String
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property depth : Int64
    @[JSON::Field(emit_null: false)]
    property completed_attempts : Int64
    @[JSON::Field(emit_null: false)]
    property body : JSON::Any
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
  end

  @[Experimental]
  struct ReportingApiEndpoint
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property group_name : String
  end

  @[Experimental]
  struct DeviceBoundSessionKey
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property site : String
    @[JSON::Field(emit_null: false)]
    property id : String
  end

  @[Experimental]
  struct DeviceBoundSessionWithUsage
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property session_key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property usage : Cdp::NodeType
  end

  @[Experimental]
  struct DeviceBoundSessionCookieCraving
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property domain : String
    @[JSON::Field(emit_null: false)]
    property path : String
    @[JSON::Field(emit_null: false)]
    property? secure : Bool
    @[JSON::Field(emit_null: false)]
    property? http_only : Bool
    @[JSON::Field(emit_null: false)]
    property same_site : Cdp::NodeType?
  end

  @[Experimental]
  struct DeviceBoundSessionUrlRule
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property rule_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property host_pattern : String
    @[JSON::Field(emit_null: false)]
    property path_prefix : String
  end

  @[Experimental]
  struct DeviceBoundSessionInclusionRules
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property? include_site : Bool
    @[JSON::Field(emit_null: false)]
    property url_rules : Array(Cdp::NodeType)
  end

  @[Experimental]
  struct DeviceBoundSession
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property key : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property refresh_url : String
    @[JSON::Field(emit_null: false)]
    property inclusion_rules : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property cookie_cravings : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property expiry_date : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property cached_challenge : String?
    @[JSON::Field(emit_null: false)]
    property allowed_refresh_initiators : Array(String)
  end

  @[Experimental]
  alias DeviceBoundSessionEventId = String

  @[Experimental]
  alias DeviceBoundSessionFetchResult = String
  DeviceBoundSessionFetchResultSuccess                                           = "Success"
  DeviceBoundSessionFetchResultKeyError                                          = "KeyError"
  DeviceBoundSessionFetchResultSigningError                                      = "SigningError"
  DeviceBoundSessionFetchResultServerRequestedTermination                        = "ServerRequestedTermination"
  DeviceBoundSessionFetchResultInvalidSessionId                                  = "InvalidSessionId"
  DeviceBoundSessionFetchResultInvalidChallenge                                  = "InvalidChallenge"
  DeviceBoundSessionFetchResultTooManyChallenges                                 = "TooManyChallenges"
  DeviceBoundSessionFetchResultInvalidFetcherUrl                                 = "InvalidFetcherUrl"
  DeviceBoundSessionFetchResultInvalidRefreshUrl                                 = "InvalidRefreshUrl"
  DeviceBoundSessionFetchResultTransientHttpError                                = "TransientHttpError"
  DeviceBoundSessionFetchResultScopeOriginSameSiteMismatch                       = "ScopeOriginSameSiteMismatch"
  DeviceBoundSessionFetchResultRefreshUrlSameSiteMismatch                        = "RefreshUrlSameSiteMismatch"
  DeviceBoundSessionFetchResultMismatchedSessionId                               = "MismatchedSessionId"
  DeviceBoundSessionFetchResultMissingScope                                      = "MissingScope"
  DeviceBoundSessionFetchResultNoCredentials                                     = "NoCredentials"
  DeviceBoundSessionFetchResultSubdomainRegistrationWellKnownUnavailable         = "SubdomainRegistrationWellKnownUnavailable"
  DeviceBoundSessionFetchResultSubdomainRegistrationUnauthorized                 = "SubdomainRegistrationUnauthorized"
  DeviceBoundSessionFetchResultSubdomainRegistrationWellKnownMalformed           = "SubdomainRegistrationWellKnownMalformed"
  DeviceBoundSessionFetchResultSessionProviderWellKnownUnavailable               = "SessionProviderWellKnownUnavailable"
  DeviceBoundSessionFetchResultRelyingPartyWellKnownUnavailable                  = "RelyingPartyWellKnownUnavailable"
  DeviceBoundSessionFetchResultFederatedKeyThumbprintMismatch                    = "FederatedKeyThumbprintMismatch"
  DeviceBoundSessionFetchResultInvalidFederatedSessionUrl                        = "InvalidFederatedSessionUrl"
  DeviceBoundSessionFetchResultInvalidFederatedKey                               = "InvalidFederatedKey"
  DeviceBoundSessionFetchResultTooManyRelyingOriginLabels                        = "TooManyRelyingOriginLabels"
  DeviceBoundSessionFetchResultBoundCookieSetForbidden                           = "BoundCookieSetForbidden"
  DeviceBoundSessionFetchResultNetError                                          = "NetError"
  DeviceBoundSessionFetchResultProxyError                                        = "ProxyError"
  DeviceBoundSessionFetchResultEmptySessionConfig                                = "EmptySessionConfig"
  DeviceBoundSessionFetchResultInvalidCredentialsConfig                          = "InvalidCredentialsConfig"
  DeviceBoundSessionFetchResultInvalidCredentialsType                            = "InvalidCredentialsType"
  DeviceBoundSessionFetchResultInvalidCredentialsEmptyName                       = "InvalidCredentialsEmptyName"
  DeviceBoundSessionFetchResultInvalidCredentialsCookie                          = "InvalidCredentialsCookie"
  DeviceBoundSessionFetchResultPersistentHttpError                               = "PersistentHttpError"
  DeviceBoundSessionFetchResultRegistrationAttemptedChallenge                    = "RegistrationAttemptedChallenge"
  DeviceBoundSessionFetchResultInvalidScopeOrigin                                = "InvalidScopeOrigin"
  DeviceBoundSessionFetchResultScopeOriginContainsPath                           = "ScopeOriginContainsPath"
  DeviceBoundSessionFetchResultRefreshInitiatorNotString                         = "RefreshInitiatorNotString"
  DeviceBoundSessionFetchResultRefreshInitiatorInvalidHostPattern                = "RefreshInitiatorInvalidHostPattern"
  DeviceBoundSessionFetchResultInvalidScopeSpecification                         = "InvalidScopeSpecification"
  DeviceBoundSessionFetchResultMissingScopeSpecificationType                     = "MissingScopeSpecificationType"
  DeviceBoundSessionFetchResultEmptyScopeSpecificationDomain                     = "EmptyScopeSpecificationDomain"
  DeviceBoundSessionFetchResultEmptyScopeSpecificationPath                       = "EmptyScopeSpecificationPath"
  DeviceBoundSessionFetchResultInvalidScopeSpecificationType                     = "InvalidScopeSpecificationType"
  DeviceBoundSessionFetchResultInvalidScopeIncludeSite                           = "InvalidScopeIncludeSite"
  DeviceBoundSessionFetchResultMissingScopeIncludeSite                           = "MissingScopeIncludeSite"
  DeviceBoundSessionFetchResultFederatedNotAuthorizedByProvider                  = "FederatedNotAuthorizedByProvider"
  DeviceBoundSessionFetchResultFederatedNotAuthorizedByRelyingParty              = "FederatedNotAuthorizedByRelyingParty"
  DeviceBoundSessionFetchResultSessionProviderWellKnownMalformed                 = "SessionProviderWellKnownMalformed"
  DeviceBoundSessionFetchResultSessionProviderWellKnownHasProviderOrigin         = "SessionProviderWellKnownHasProviderOrigin"
  DeviceBoundSessionFetchResultRelyingPartyWellKnownMalformed                    = "RelyingPartyWellKnownMalformed"
  DeviceBoundSessionFetchResultRelyingPartyWellKnownHasRelyingOrigins            = "RelyingPartyWellKnownHasRelyingOrigins"
  DeviceBoundSessionFetchResultInvalidFederatedSessionProviderSessionMissing     = "InvalidFederatedSessionProviderSessionMissing"
  DeviceBoundSessionFetchResultInvalidFederatedSessionWrongProviderOrigin        = "InvalidFederatedSessionWrongProviderOrigin"
  DeviceBoundSessionFetchResultInvalidCredentialsCookieCreationTime              = "InvalidCredentialsCookieCreationTime"
  DeviceBoundSessionFetchResultInvalidCredentialsCookieName                      = "InvalidCredentialsCookieName"
  DeviceBoundSessionFetchResultInvalidCredentialsCookieParsing                   = "InvalidCredentialsCookieParsing"
  DeviceBoundSessionFetchResultInvalidCredentialsCookieUnpermittedAttribute      = "InvalidCredentialsCookieUnpermittedAttribute"
  DeviceBoundSessionFetchResultInvalidCredentialsCookieInvalidDomain             = "InvalidCredentialsCookieInvalidDomain"
  DeviceBoundSessionFetchResultInvalidCredentialsCookiePrefix                    = "InvalidCredentialsCookiePrefix"
  DeviceBoundSessionFetchResultInvalidScopeRulePath                              = "InvalidScopeRulePath"
  DeviceBoundSessionFetchResultInvalidScopeRuleHostPattern                       = "InvalidScopeRuleHostPattern"
  DeviceBoundSessionFetchResultScopeRuleOriginScopedHostPatternMismatch          = "ScopeRuleOriginScopedHostPatternMismatch"
  DeviceBoundSessionFetchResultScopeRuleSiteScopedHostPatternMismatch            = "ScopeRuleSiteScopedHostPatternMismatch"
  DeviceBoundSessionFetchResultSigningQuotaExceeded                              = "SigningQuotaExceeded"
  DeviceBoundSessionFetchResultInvalidConfigJson                                 = "InvalidConfigJson"
  DeviceBoundSessionFetchResultInvalidFederatedSessionProviderFailedToRestoreKey = "InvalidFederatedSessionProviderFailedToRestoreKey"
  DeviceBoundSessionFetchResultFailedToUnwrapKey                                 = "FailedToUnwrapKey"
  DeviceBoundSessionFetchResultSessionDeletedDuringRefresh                       = "SessionDeletedDuringRefresh"

  @[Experimental]
  struct CreationEventDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property fetch_result : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property new_session : Cdp::NodeType?
  end

  @[Experimental]
  struct RefreshEventDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property refresh_result : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property fetch_result : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property new_session : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? was_fully_proactive_refresh : Bool
  end

  @[Experimental]
  struct TerminationEventDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property deletion_reason : Cdp::NodeType
  end

  @[Experimental]
  struct ChallengeEventDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property challenge_result : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property challenge : String
  end

  @[Experimental]
  struct LoadNetworkResourcePageResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? success : Bool
    @[JSON::Field(emit_null: false)]
    property net_error : Float64?
    @[JSON::Field(emit_null: false)]
    property net_error_name : String?
    @[JSON::Field(emit_null: false)]
    property http_status_code : Float64?
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property headers : Cdp::NodeType?
  end

  @[Experimental]
  struct LoadNetworkResourceOptions
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? disable_cache : Bool
    @[JSON::Field(emit_null: false)]
    property? include_credentials : Bool
  end

  alias ReferrerPolicy = String
  ReferrerPolicyUnsafeUrl                   = "unsafe-url"
  ReferrerPolicyNoReferrerWhenDowngrade     = "no-referrer-when-downgrade"
  ReferrerPolicyNoReferrer                  = "no-referrer"
  ReferrerPolicyOrigin                      = "origin"
  ReferrerPolicyOriginWhenCrossOrigin       = "origin-when-cross-origin"
  ReferrerPolicySameOrigin                  = "same-origin"
  ReferrerPolicyStrictOrigin                = "strict-origin"
  ReferrerPolicyStrictOriginWhenCrossOrigin = "strict-origin-when-cross-origin"

  alias TrustTokenParamsRefreshPolicy = String
  TrustTokenParamsRefreshPolicyUseCached = "UseCached"
  TrustTokenParamsRefreshPolicyRefresh   = "Refresh"

  alias InitiatorType = String
  InitiatorTypeParser         = "parser"
  InitiatorTypeScript         = "script"
  InitiatorTypePreload        = "preload"
  InitiatorTypeSignedExchange = "SignedExchange"
  InitiatorTypePreflight      = "preflight"
  InitiatorTypeFedCM          = "FedCM"
  InitiatorTypeOther          = "other"

  alias AuthChallengeSource = String
  AuthChallengeSourceServer = "Server"
  AuthChallengeSourceProxy  = "Proxy"

  alias AuthChallengeResponseResponse = String
  AuthChallengeResponseResponseDefault            = "Default"
  AuthChallengeResponseResponseCancelAuth         = "CancelAuth"
  AuthChallengeResponseResponseProvideCredentials = "ProvideCredentials"

  alias DeviceBoundSessionWithUsageUsage = String
  DeviceBoundSessionWithUsageUsageNotInScope                  = "NotInScope"
  DeviceBoundSessionWithUsageUsageInScopeRefreshNotYetNeeded  = "InScopeRefreshNotYetNeeded"
  DeviceBoundSessionWithUsageUsageInScopeRefreshNotAllowed    = "InScopeRefreshNotAllowed"
  DeviceBoundSessionWithUsageUsageProactiveRefreshNotPossible = "ProactiveRefreshNotPossible"
  DeviceBoundSessionWithUsageUsageProactiveRefreshAttempted   = "ProactiveRefreshAttempted"
  DeviceBoundSessionWithUsageUsageDeferred                    = "Deferred"

  alias DeviceBoundSessionUrlRuleRuleType = String
  DeviceBoundSessionUrlRuleRuleTypeExclude = "Exclude"
  DeviceBoundSessionUrlRuleRuleTypeInclude = "Include"

  alias RefreshEventDetailsRefreshResult = String
  RefreshEventDetailsRefreshResultRefreshed            = "Refreshed"
  RefreshEventDetailsRefreshResultInitializedService   = "InitializedService"
  RefreshEventDetailsRefreshResultUnreachable          = "Unreachable"
  RefreshEventDetailsRefreshResultServerError          = "ServerError"
  RefreshEventDetailsRefreshResultRefreshQuotaExceeded = "RefreshQuotaExceeded"
  RefreshEventDetailsRefreshResultFatalError           = "FatalError"
  RefreshEventDetailsRefreshResultSigningQuotaExceeded = "SigningQuotaExceeded"

  alias TerminationEventDetailsDeletionReason = String
  TerminationEventDetailsDeletionReasonExpired                 = "Expired"
  TerminationEventDetailsDeletionReasonFailedToRestoreKey      = "FailedToRestoreKey"
  TerminationEventDetailsDeletionReasonFailedToUnwrapKey       = "FailedToUnwrapKey"
  TerminationEventDetailsDeletionReasonStoragePartitionCleared = "StoragePartitionCleared"
  TerminationEventDetailsDeletionReasonClearBrowsingData       = "ClearBrowsingData"
  TerminationEventDetailsDeletionReasonServerRequested         = "ServerRequested"
  TerminationEventDetailsDeletionReasonInvalidSessionParams    = "InvalidSessionParams"
  TerminationEventDetailsDeletionReasonRefreshFatalError       = "RefreshFatalError"

  alias ChallengeEventDetailsChallengeResult = String
  ChallengeEventDetailsChallengeResultSuccess            = "Success"
  ChallengeEventDetailsChallengeResultNoSessionId        = "NoSessionId"
  ChallengeEventDetailsChallengeResultNoSessionMatch     = "NoSessionMatch"
  ChallengeEventDetailsChallengeResultCantSetBoundCookie = "CantSetBoundCookie"

  alias TrustTokenOperationDoneStatus = String
  TrustTokenOperationDoneStatusOk                 = "Ok"
  TrustTokenOperationDoneStatusInvalidArgument    = "InvalidArgument"
  TrustTokenOperationDoneStatusMissingIssuerKeys  = "MissingIssuerKeys"
  TrustTokenOperationDoneStatusFailedPrecondition = "FailedPrecondition"
  TrustTokenOperationDoneStatusResourceExhausted  = "ResourceExhausted"
  TrustTokenOperationDoneStatusAlreadyExists      = "AlreadyExists"
  TrustTokenOperationDoneStatusResourceLimited    = "ResourceLimited"
  TrustTokenOperationDoneStatusUnauthorized       = "Unauthorized"
  TrustTokenOperationDoneStatusBadResponse        = "BadResponse"
  TrustTokenOperationDoneStatusInternalError      = "InternalError"
  TrustTokenOperationDoneStatusUnknownError       = "UnknownError"
  TrustTokenOperationDoneStatusFulfilledLocally   = "FulfilledLocally"
  TrustTokenOperationDoneStatusSiteIssuerLimit    = "SiteIssuerLimit"
end
