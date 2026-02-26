require "../cdp"
require "json"
require "time"

require "../network/network"
require "../page/page"
require "../runtime/runtime"
require "../dom/dom"

module Cdp::Audits
  struct AffectedCookie
    include JSON::Serializable
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "path", emit_null: false)]
    property path : String
    @[JSON::Field(key: "domain", emit_null: false)]
    property domain : String
  end

  struct AffectedRequest
    include JSON::Serializable
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : Cdp::Network::RequestId?
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
  end

  struct AffectedFrame
    include JSON::Serializable
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
  end

  alias CookieExclusionReason = String
  CookieExclusionReasonExcludeSameSiteUnspecifiedTreatedAsLax        = "ExcludeSameSiteUnspecifiedTreatedAsLax"
  CookieExclusionReasonExcludeSameSiteNoneInsecure                   = "ExcludeSameSiteNoneInsecure"
  CookieExclusionReasonExcludeSameSiteLax                            = "ExcludeSameSiteLax"
  CookieExclusionReasonExcludeSameSiteStrict                         = "ExcludeSameSiteStrict"
  CookieExclusionReasonExcludeDomainNonASCII                         = "ExcludeDomainNonASCII"
  CookieExclusionReasonExcludeThirdPartyCookieBlockedInFirstPartySet = "ExcludeThirdPartyCookieBlockedInFirstPartySet"
  CookieExclusionReasonExcludeThirdPartyPhaseout                     = "ExcludeThirdPartyPhaseout"
  CookieExclusionReasonExcludePortMismatch                           = "ExcludePortMismatch"
  CookieExclusionReasonExcludeSchemeMismatch                         = "ExcludeSchemeMismatch"

  alias CookieWarningReason = String
  CookieWarningReasonWarnSameSiteUnspecifiedCrossSiteContext        = "WarnSameSiteUnspecifiedCrossSiteContext"
  CookieWarningReasonWarnSameSiteNoneInsecure                       = "WarnSameSiteNoneInsecure"
  CookieWarningReasonWarnSameSiteUnspecifiedLaxAllowUnsafe          = "WarnSameSiteUnspecifiedLaxAllowUnsafe"
  CookieWarningReasonWarnSameSiteStrictLaxDowngradeStrict           = "WarnSameSiteStrictLaxDowngradeStrict"
  CookieWarningReasonWarnSameSiteStrictCrossDowngradeStrict         = "WarnSameSiteStrictCrossDowngradeStrict"
  CookieWarningReasonWarnSameSiteStrictCrossDowngradeLax            = "WarnSameSiteStrictCrossDowngradeLax"
  CookieWarningReasonWarnSameSiteLaxCrossDowngradeStrict            = "WarnSameSiteLaxCrossDowngradeStrict"
  CookieWarningReasonWarnSameSiteLaxCrossDowngradeLax               = "WarnSameSiteLaxCrossDowngradeLax"
  CookieWarningReasonWarnAttributeValueExceedsMaxSize               = "WarnAttributeValueExceedsMaxSize"
  CookieWarningReasonWarnDomainNonASCII                             = "WarnDomainNonASCII"
  CookieWarningReasonWarnThirdPartyPhaseout                         = "WarnThirdPartyPhaseout"
  CookieWarningReasonWarnCrossSiteRedirectDowngradeChangesInclusion = "WarnCrossSiteRedirectDowngradeChangesInclusion"
  CookieWarningReasonWarnDeprecationTrialMetadata                   = "WarnDeprecationTrialMetadata"
  CookieWarningReasonWarnThirdPartyCookieHeuristic                  = "WarnThirdPartyCookieHeuristic"

  alias CookieOperation = String
  CookieOperationSetCookie  = "SetCookie"
  CookieOperationReadCookie = "ReadCookie"

  alias InsightType = String
  InsightTypeGitHubResource = "GitHubResource"
  InsightTypeGracePeriod    = "GracePeriod"
  InsightTypeHeuristics     = "Heuristics"

  struct CookieIssueInsight
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : InsightType
    @[JSON::Field(key: "tableEntryUrl", emit_null: false)]
    property table_entry_url : String?
  end

  struct CookieIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "cookie", emit_null: false)]
    property cookie : AffectedCookie?
    @[JSON::Field(key: "rawCookieLine", emit_null: false)]
    property raw_cookie_line : String?
    @[JSON::Field(key: "cookieWarningReasons", emit_null: false)]
    property cookie_warning_reasons : Array(CookieWarningReason)
    @[JSON::Field(key: "cookieExclusionReasons", emit_null: false)]
    property cookie_exclusion_reasons : Array(CookieExclusionReason)
    @[JSON::Field(key: "operation", emit_null: false)]
    property operation : CookieOperation
    @[JSON::Field(key: "siteForCookies", emit_null: false)]
    property site_for_cookies : String?
    @[JSON::Field(key: "cookieUrl", emit_null: false)]
    property cookie_url : String?
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(key: "insight", emit_null: false)]
    property insight : CookieIssueInsight?
  end

  alias PerformanceIssueType = String
  PerformanceIssueTypeDocumentCookie = "DocumentCookie"

  struct PerformanceIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "performanceIssueType", emit_null: false)]
    property performance_issue_type : PerformanceIssueType
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation?
  end

  alias MixedContentResolutionStatus = String
  MixedContentResolutionStatusMixedContentBlocked               = "MixedContentBlocked"
  MixedContentResolutionStatusMixedContentAutomaticallyUpgraded = "MixedContentAutomaticallyUpgraded"
  MixedContentResolutionStatusMixedContentWarning               = "MixedContentWarning"

  alias MixedContentResourceType = String
  MixedContentResourceTypeAttributionSrc   = "AttributionSrc"
  MixedContentResourceTypeAudio            = "Audio"
  MixedContentResourceTypeBeacon           = "Beacon"
  MixedContentResourceTypeCSPReport        = "CSPReport"
  MixedContentResourceTypeDownload         = "Download"
  MixedContentResourceTypeEventSource      = "EventSource"
  MixedContentResourceTypeFavicon          = "Favicon"
  MixedContentResourceTypeFont             = "Font"
  MixedContentResourceTypeForm             = "Form"
  MixedContentResourceTypeFrame            = "Frame"
  MixedContentResourceTypeImage            = "Image"
  MixedContentResourceTypeImport           = "Import"
  MixedContentResourceTypeJSON             = "JSON"
  MixedContentResourceTypeManifest         = "Manifest"
  MixedContentResourceTypePing             = "Ping"
  MixedContentResourceTypePluginData       = "PluginData"
  MixedContentResourceTypePluginResource   = "PluginResource"
  MixedContentResourceTypePrefetch         = "Prefetch"
  MixedContentResourceTypeResource         = "Resource"
  MixedContentResourceTypeScript           = "Script"
  MixedContentResourceTypeServiceWorker    = "ServiceWorker"
  MixedContentResourceTypeSharedWorker     = "SharedWorker"
  MixedContentResourceTypeSpeculationRules = "SpeculationRules"
  MixedContentResourceTypeStylesheet       = "Stylesheet"
  MixedContentResourceTypeTrack            = "Track"
  MixedContentResourceTypeVideo            = "Video"
  MixedContentResourceTypeWorker           = "Worker"
  MixedContentResourceTypeXMLHttpRequest   = "XMLHttpRequest"
  MixedContentResourceTypeXSLT             = "XSLT"

  struct MixedContentIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "resourceType", emit_null: false)]
    property resource_type : MixedContentResourceType?
    @[JSON::Field(key: "resolutionStatus", emit_null: false)]
    property resolution_status : MixedContentResolutionStatus
    @[JSON::Field(key: "insecureUrl", emit_null: false)]
    property insecure_url : String
    @[JSON::Field(key: "mainResourceUrl", emit_null: false)]
    property main_resource_url : String
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(key: "frame", emit_null: false)]
    property frame : AffectedFrame?
  end

  alias BlockedByResponseReason = String
  BlockedByResponseReasonCoepFrameResourceNeedsCoepHeader                        = "CoepFrameResourceNeedsCoepHeader"
  BlockedByResponseReasonCoopSandboxedIFrameCannotNavigateToCoopPage             = "CoopSandboxedIFrameCannotNavigateToCoopPage"
  BlockedByResponseReasonCorpNotSameOrigin                                       = "CorpNotSameOrigin"
  BlockedByResponseReasonCorpNotSameOriginAfterDefaultedToSameOriginByCoep       = "CorpNotSameOriginAfterDefaultedToSameOriginByCoep"
  BlockedByResponseReasonCorpNotSameOriginAfterDefaultedToSameOriginByDip        = "CorpNotSameOriginAfterDefaultedToSameOriginByDip"
  BlockedByResponseReasonCorpNotSameOriginAfterDefaultedToSameOriginByCoepAndDip = "CorpNotSameOriginAfterDefaultedToSameOriginByCoepAndDip"
  BlockedByResponseReasonCorpNotSameSite                                         = "CorpNotSameSite"
  BlockedByResponseReasonSRIMessageSignatureMismatch                             = "SRIMessageSignatureMismatch"

  struct BlockedByResponseIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest
    @[JSON::Field(key: "parentFrame", emit_null: false)]
    property parent_frame : AffectedFrame?
    @[JSON::Field(key: "blockedFrame", emit_null: false)]
    property blocked_frame : AffectedFrame?
    @[JSON::Field(key: "reason", emit_null: false)]
    property reason : BlockedByResponseReason
  end

  alias HeavyAdResolutionStatus = String
  HeavyAdResolutionStatusHeavyAdBlocked = "HeavyAdBlocked"
  HeavyAdResolutionStatusHeavyAdWarning = "HeavyAdWarning"

  alias HeavyAdReason = String
  HeavyAdReasonNetworkTotalLimit = "NetworkTotalLimit"
  HeavyAdReasonCpuTotalLimit     = "CpuTotalLimit"
  HeavyAdReasonCpuPeakLimit      = "CpuPeakLimit"

  struct HeavyAdIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "resolution", emit_null: false)]
    property resolution : HeavyAdResolutionStatus
    @[JSON::Field(key: "reason", emit_null: false)]
    property reason : HeavyAdReason
    @[JSON::Field(key: "frame", emit_null: false)]
    property frame : AffectedFrame
  end

  alias ContentSecurityPolicyViolationType = String
  ContentSecurityPolicyViolationTypeKInlineViolation             = "kInlineViolation"
  ContentSecurityPolicyViolationTypeKEvalViolation               = "kEvalViolation"
  ContentSecurityPolicyViolationTypeKURLViolation                = "kURLViolation"
  ContentSecurityPolicyViolationTypeKSRIViolation                = "kSRIViolation"
  ContentSecurityPolicyViolationTypeKTrustedTypesSinkViolation   = "kTrustedTypesSinkViolation"
  ContentSecurityPolicyViolationTypeKTrustedTypesPolicyViolation = "kTrustedTypesPolicyViolation"
  ContentSecurityPolicyViolationTypeKWasmEvalViolation           = "kWasmEvalViolation"

  struct SourceCodeLocation
    include JSON::Serializable
    @[JSON::Field(key: "scriptId", emit_null: false)]
    property script_id : Cdp::Runtime::ScriptId?
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "lineNumber", emit_null: false)]
    property line_number : Int64
    @[JSON::Field(key: "columnNumber", emit_null: false)]
    property column_number : Int64
  end

  struct ContentSecurityPolicyIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "blockedUrl", emit_null: false)]
    property blocked_url : String?
    @[JSON::Field(key: "violatedDirective", emit_null: false)]
    property violated_directive : String
    @[JSON::Field(key: "isReportOnly", emit_null: false)]
    property? is_report_only : Bool
    @[JSON::Field(key: "contentSecurityPolicyViolationType", emit_null: false)]
    property content_security_policy_violation_type : ContentSecurityPolicyViolationType
    @[JSON::Field(key: "frameAncestor", emit_null: false)]
    property frame_ancestor : AffectedFrame?
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation?
    @[JSON::Field(key: "violatingNodeId", emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId?
  end

  alias SharedArrayBufferIssueType = String
  SharedArrayBufferIssueTypeTransferIssue = "TransferIssue"
  SharedArrayBufferIssueTypeCreationIssue = "CreationIssue"

  struct SharedArrayBufferIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation
    @[JSON::Field(key: "isWarning", emit_null: false)]
    property? is_warning : Bool
    @[JSON::Field(key: "type", emit_null: false)]
    property type : SharedArrayBufferIssueType
  end

  struct LowTextContrastIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "violatingNodeId", emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(key: "violatingNodeSelector", emit_null: false)]
    property violating_node_selector : String
    @[JSON::Field(key: "contrastRatio", emit_null: false)]
    property contrast_ratio : Float64
    @[JSON::Field(key: "thresholdAa", emit_null: false)]
    property threshold_aa : Float64
    @[JSON::Field(key: "thresholdAaa", emit_null: false)]
    property threshold_aaa : Float64
    @[JSON::Field(key: "fontSize", emit_null: false)]
    property font_size : String
    @[JSON::Field(key: "fontWeight", emit_null: false)]
    property font_weight : String
  end

  struct CorsIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "corsErrorStatus", emit_null: false)]
    property cors_error_status : Cdp::Network::CorsErrorStatus
    @[JSON::Field(key: "isWarning", emit_null: false)]
    property? is_warning : Bool
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest
    @[JSON::Field(key: "location", emit_null: false)]
    property location : SourceCodeLocation?
    @[JSON::Field(key: "initiatorOrigin", emit_null: false)]
    property initiator_origin : String?
    @[JSON::Field(key: "resourceIpAddressSpace", emit_null: false)]
    property resource_ip_address_space : Cdp::Network::IPAddressSpace?
    @[JSON::Field(key: "clientSecurityState", emit_null: false)]
    property client_security_state : Cdp::Network::ClientSecurityState?
  end

  alias AttributionReportingIssueType = String
  AttributionReportingIssueTypePermissionPolicyDisabled                             = "PermissionPolicyDisabled"
  AttributionReportingIssueTypeUntrustworthyReportingOrigin                         = "UntrustworthyReportingOrigin"
  AttributionReportingIssueTypeInsecureContext                                      = "InsecureContext"
  AttributionReportingIssueTypeInvalidHeader                                        = "InvalidHeader"
  AttributionReportingIssueTypeInvalidRegisterTriggerHeader                         = "InvalidRegisterTriggerHeader"
  AttributionReportingIssueTypeSourceAndTriggerHeaders                              = "SourceAndTriggerHeaders"
  AttributionReportingIssueTypeSourceIgnored                                        = "SourceIgnored"
  AttributionReportingIssueTypeTriggerIgnored                                       = "TriggerIgnored"
  AttributionReportingIssueTypeOsSourceIgnored                                      = "OsSourceIgnored"
  AttributionReportingIssueTypeOsTriggerIgnored                                     = "OsTriggerIgnored"
  AttributionReportingIssueTypeInvalidRegisterOsSourceHeader                        = "InvalidRegisterOsSourceHeader"
  AttributionReportingIssueTypeInvalidRegisterOsTriggerHeader                       = "InvalidRegisterOsTriggerHeader"
  AttributionReportingIssueTypeWebAndOsHeaders                                      = "WebAndOsHeaders"
  AttributionReportingIssueTypeNoWebOrOsSupport                                     = "NoWebOrOsSupport"
  AttributionReportingIssueTypeNavigationRegistrationWithoutTransientUserActivation = "NavigationRegistrationWithoutTransientUserActivation"
  AttributionReportingIssueTypeInvalidInfoHeader                                    = "InvalidInfoHeader"
  AttributionReportingIssueTypeNoRegisterSourceHeader                               = "NoRegisterSourceHeader"
  AttributionReportingIssueTypeNoRegisterTriggerHeader                              = "NoRegisterTriggerHeader"
  AttributionReportingIssueTypeNoRegisterOsSourceHeader                             = "NoRegisterOsSourceHeader"
  AttributionReportingIssueTypeNoRegisterOsTriggerHeader                            = "NoRegisterOsTriggerHeader"
  AttributionReportingIssueTypeNavigationRegistrationUniqueScopeAlreadySet          = "NavigationRegistrationUniqueScopeAlreadySet"

  alias SharedDictionaryError = String
  SharedDictionaryErrorUseErrorCrossOriginNoCorsRequest          = "UseErrorCrossOriginNoCorsRequest"
  SharedDictionaryErrorUseErrorDictionaryLoadFailure             = "UseErrorDictionaryLoadFailure"
  SharedDictionaryErrorUseErrorMatchingDictionaryNotUsed         = "UseErrorMatchingDictionaryNotUsed"
  SharedDictionaryErrorUseErrorUnexpectedContentDictionaryHeader = "UseErrorUnexpectedContentDictionaryHeader"
  SharedDictionaryErrorWriteErrorCossOriginNoCorsRequest         = "WriteErrorCossOriginNoCorsRequest"
  SharedDictionaryErrorWriteErrorDisallowedBySettings            = "WriteErrorDisallowedBySettings"
  SharedDictionaryErrorWriteErrorExpiredResponse                 = "WriteErrorExpiredResponse"
  SharedDictionaryErrorWriteErrorFeatureDisabled                 = "WriteErrorFeatureDisabled"
  SharedDictionaryErrorWriteErrorInsufficientResources           = "WriteErrorInsufficientResources"
  SharedDictionaryErrorWriteErrorInvalidMatchField               = "WriteErrorInvalidMatchField"
  SharedDictionaryErrorWriteErrorInvalidStructuredHeader         = "WriteErrorInvalidStructuredHeader"
  SharedDictionaryErrorWriteErrorInvalidTTLField                 = "WriteErrorInvalidTTLField"
  SharedDictionaryErrorWriteErrorNavigationRequest               = "WriteErrorNavigationRequest"
  SharedDictionaryErrorWriteErrorNoMatchField                    = "WriteErrorNoMatchField"
  SharedDictionaryErrorWriteErrorNonIntegerTTLField              = "WriteErrorNonIntegerTTLField"
  SharedDictionaryErrorWriteErrorNonListMatchDestField           = "WriteErrorNonListMatchDestField"
  SharedDictionaryErrorWriteErrorNonSecureContext                = "WriteErrorNonSecureContext"
  SharedDictionaryErrorWriteErrorNonStringIdField                = "WriteErrorNonStringIdField"
  SharedDictionaryErrorWriteErrorNonStringInMatchDestList        = "WriteErrorNonStringInMatchDestList"
  SharedDictionaryErrorWriteErrorNonStringMatchField             = "WriteErrorNonStringMatchField"
  SharedDictionaryErrorWriteErrorNonTokenTypeField               = "WriteErrorNonTokenTypeField"
  SharedDictionaryErrorWriteErrorRequestAborted                  = "WriteErrorRequestAborted"
  SharedDictionaryErrorWriteErrorShuttingDown                    = "WriteErrorShuttingDown"
  SharedDictionaryErrorWriteErrorTooLongIdField                  = "WriteErrorTooLongIdField"
  SharedDictionaryErrorWriteErrorUnsupportedType                 = "WriteErrorUnsupportedType"

  alias SRIMessageSignatureError = String
  SRIMessageSignatureErrorMissingSignatureHeader                               = "MissingSignatureHeader"
  SRIMessageSignatureErrorMissingSignatureInputHeader                          = "MissingSignatureInputHeader"
  SRIMessageSignatureErrorInvalidSignatureHeader                               = "InvalidSignatureHeader"
  SRIMessageSignatureErrorInvalidSignatureInputHeader                          = "InvalidSignatureInputHeader"
  SRIMessageSignatureErrorSignatureHeaderValueIsNotByteSequence                = "SignatureHeaderValueIsNotByteSequence"
  SRIMessageSignatureErrorSignatureHeaderValueIsParameterized                  = "SignatureHeaderValueIsParameterized"
  SRIMessageSignatureErrorSignatureHeaderValueIsIncorrectLength                = "SignatureHeaderValueIsIncorrectLength"
  SRIMessageSignatureErrorSignatureInputHeaderMissingLabel                     = "SignatureInputHeaderMissingLabel"
  SRIMessageSignatureErrorSignatureInputHeaderValueNotInnerList                = "SignatureInputHeaderValueNotInnerList"
  SRIMessageSignatureErrorSignatureInputHeaderValueMissingComponents           = "SignatureInputHeaderValueMissingComponents"
  SRIMessageSignatureErrorSignatureInputHeaderInvalidComponentType             = "SignatureInputHeaderInvalidComponentType"
  SRIMessageSignatureErrorSignatureInputHeaderInvalidComponentName             = "SignatureInputHeaderInvalidComponentName"
  SRIMessageSignatureErrorSignatureInputHeaderInvalidHeaderComponentParameter  = "SignatureInputHeaderInvalidHeaderComponentParameter"
  SRIMessageSignatureErrorSignatureInputHeaderInvalidDerivedComponentParameter = "SignatureInputHeaderInvalidDerivedComponentParameter"
  SRIMessageSignatureErrorSignatureInputHeaderKeyIdLength                      = "SignatureInputHeaderKeyIdLength"
  SRIMessageSignatureErrorSignatureInputHeaderInvalidParameter                 = "SignatureInputHeaderInvalidParameter"
  SRIMessageSignatureErrorSignatureInputHeaderMissingRequiredParameters        = "SignatureInputHeaderMissingRequiredParameters"
  SRIMessageSignatureErrorValidationFailedSignatureExpired                     = "ValidationFailedSignatureExpired"
  SRIMessageSignatureErrorValidationFailedInvalidLength                        = "ValidationFailedInvalidLength"
  SRIMessageSignatureErrorValidationFailedSignatureMismatch                    = "ValidationFailedSignatureMismatch"
  SRIMessageSignatureErrorValidationFailedIntegrityMismatch                    = "ValidationFailedIntegrityMismatch"

  alias UnencodedDigestError = String
  UnencodedDigestErrorMalformedDictionary   = "MalformedDictionary"
  UnencodedDigestErrorUnknownAlgorithm      = "UnknownAlgorithm"
  UnencodedDigestErrorIncorrectDigestType   = "IncorrectDigestType"
  UnencodedDigestErrorIncorrectDigestLength = "IncorrectDigestLength"

  alias ConnectionAllowlistError = String
  ConnectionAllowlistErrorInvalidHeader             = "InvalidHeader"
  ConnectionAllowlistErrorMoreThanOneList           = "MoreThanOneList"
  ConnectionAllowlistErrorItemNotInnerList          = "ItemNotInnerList"
  ConnectionAllowlistErrorInvalidAllowlistItemType  = "InvalidAllowlistItemType"
  ConnectionAllowlistErrorReportingEndpointNotToken = "ReportingEndpointNotToken"
  ConnectionAllowlistErrorInvalidUrlPattern         = "InvalidUrlPattern"

  struct AttributionReportingIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "violationType", emit_null: false)]
    property violation_type : AttributionReportingIssueType
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(key: "violatingNodeId", emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "invalidParameter", emit_null: false)]
    property invalid_parameter : String?
  end

  struct QuirksModeIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "isLimitedQuirksMode", emit_null: false)]
    property? is_limited_quirks_mode : Bool
    @[JSON::Field(key: "documentNodeId", emit_null: false)]
    property document_node_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "loaderId", emit_null: false)]
    property loader_id : Cdp::Network::LoaderId
  end

  struct SharedDictionaryIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "sharedDictionaryError", emit_null: false)]
    property shared_dictionary_error : SharedDictionaryError
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest
  end

  struct SRIMessageSignatureIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "error", emit_null: false)]
    property error : SRIMessageSignatureError
    @[JSON::Field(key: "signatureBase", emit_null: false)]
    property signature_base : String
    @[JSON::Field(key: "integrityAssertions", emit_null: false)]
    property integrity_assertions : Array(String)
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest
  end

  struct UnencodedDigestIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "error", emit_null: false)]
    property error : UnencodedDigestError
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest
  end

  struct ConnectionAllowlistIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "error", emit_null: false)]
    property error : ConnectionAllowlistError
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest
  end

  alias GenericIssueErrorType = String
  GenericIssueErrorTypeFormLabelForNameError                                      = "FormLabelForNameError"
  GenericIssueErrorTypeFormDuplicateIdForInputError                               = "FormDuplicateIdForInputError"
  GenericIssueErrorTypeFormInputWithNoLabelError                                  = "FormInputWithNoLabelError"
  GenericIssueErrorTypeFormAutocompleteAttributeEmptyError                        = "FormAutocompleteAttributeEmptyError"
  GenericIssueErrorTypeFormEmptyIdAndNameAttributesForInputError                  = "FormEmptyIdAndNameAttributesForInputError"
  GenericIssueErrorTypeFormAriaLabelledByToNonExistingIdError                     = "FormAriaLabelledByToNonExistingIdError"
  GenericIssueErrorTypeFormInputAssignedAutocompleteValueToIdOrNameAttributeError = "FormInputAssignedAutocompleteValueToIdOrNameAttributeError"
  GenericIssueErrorTypeFormLabelHasNeitherForNorNestedInputError                  = "FormLabelHasNeitherForNorNestedInputError"
  GenericIssueErrorTypeFormLabelForMatchesNonExistingIdError                      = "FormLabelForMatchesNonExistingIdError"
  GenericIssueErrorTypeFormInputHasWrongButWellIntendedAutocompleteValueError     = "FormInputHasWrongButWellIntendedAutocompleteValueError"
  GenericIssueErrorTypeResponseWasBlockedByORB                                    = "ResponseWasBlockedByORB"
  GenericIssueErrorTypeNavigationEntryMarkedSkippable                             = "NavigationEntryMarkedSkippable"
  GenericIssueErrorTypeAutofillAndManualTextPolicyControlledFeaturesInfo          = "AutofillAndManualTextPolicyControlledFeaturesInfo"
  GenericIssueErrorTypeAutofillPolicyControlledFeatureInfo                        = "AutofillPolicyControlledFeatureInfo"
  GenericIssueErrorTypeManualTextPolicyControlledFeatureInfo                      = "ManualTextPolicyControlledFeatureInfo"

  struct GenericIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "errorType", emit_null: false)]
    property error_type : GenericIssueErrorType
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId?
    @[JSON::Field(key: "violatingNodeId", emit_null: false)]
    property violating_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "violatingNodeAttribute", emit_null: false)]
    property violating_node_attribute : String?
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest?
  end

  struct DeprecationIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "affectedFrame", emit_null: false)]
    property affected_frame : AffectedFrame?
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String
  end

  struct BounceTrackingIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "trackingSites", emit_null: false)]
    property tracking_sites : Array(String)
  end

  struct CookieDeprecationMetadataIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "allowedSites", emit_null: false)]
    property allowed_sites : Array(String)
    @[JSON::Field(key: "optOutPercentage", emit_null: false)]
    property opt_out_percentage : Float64
    @[JSON::Field(key: "isOptOutTopLevel", emit_null: false)]
    property? is_opt_out_top_level : Bool
    @[JSON::Field(key: "operation", emit_null: false)]
    property operation : CookieOperation
  end

  alias ClientHintIssueReason = String
  ClientHintIssueReasonMetaTagAllowListInvalidOrigin = "MetaTagAllowListInvalidOrigin"
  ClientHintIssueReasonMetaTagModifiedHTML           = "MetaTagModifiedHTML"

  struct FederatedAuthRequestIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "federatedAuthRequestIssueReason", emit_null: false)]
    property federated_auth_request_issue_reason : FederatedAuthRequestIssueReason
  end

  alias FederatedAuthRequestIssueReason = String
  FederatedAuthRequestIssueReasonShouldEmbargo                    = "ShouldEmbargo"
  FederatedAuthRequestIssueReasonTooManyRequests                  = "TooManyRequests"
  FederatedAuthRequestIssueReasonWellKnownHttpNotFound            = "WellKnownHttpNotFound"
  FederatedAuthRequestIssueReasonWellKnownNoResponse              = "WellKnownNoResponse"
  FederatedAuthRequestIssueReasonWellKnownInvalidResponse         = "WellKnownInvalidResponse"
  FederatedAuthRequestIssueReasonWellKnownListEmpty               = "WellKnownListEmpty"
  FederatedAuthRequestIssueReasonWellKnownInvalidContentType      = "WellKnownInvalidContentType"
  FederatedAuthRequestIssueReasonConfigNotInWellKnown             = "ConfigNotInWellKnown"
  FederatedAuthRequestIssueReasonWellKnownTooBig                  = "WellKnownTooBig"
  FederatedAuthRequestIssueReasonConfigHttpNotFound               = "ConfigHttpNotFound"
  FederatedAuthRequestIssueReasonConfigNoResponse                 = "ConfigNoResponse"
  FederatedAuthRequestIssueReasonConfigInvalidResponse            = "ConfigInvalidResponse"
  FederatedAuthRequestIssueReasonConfigInvalidContentType         = "ConfigInvalidContentType"
  FederatedAuthRequestIssueReasonIdpNotPotentiallyTrustworthy     = "IdpNotPotentiallyTrustworthy"
  FederatedAuthRequestIssueReasonDisabledInSettings               = "DisabledInSettings"
  FederatedAuthRequestIssueReasonDisabledInFlags                  = "DisabledInFlags"
  FederatedAuthRequestIssueReasonErrorFetchingSignin              = "ErrorFetchingSignin"
  FederatedAuthRequestIssueReasonInvalidSigninResponse            = "InvalidSigninResponse"
  FederatedAuthRequestIssueReasonAccountsHttpNotFound             = "AccountsHttpNotFound"
  FederatedAuthRequestIssueReasonAccountsNoResponse               = "AccountsNoResponse"
  FederatedAuthRequestIssueReasonAccountsInvalidResponse          = "AccountsInvalidResponse"
  FederatedAuthRequestIssueReasonAccountsListEmpty                = "AccountsListEmpty"
  FederatedAuthRequestIssueReasonAccountsInvalidContentType       = "AccountsInvalidContentType"
  FederatedAuthRequestIssueReasonIdTokenHttpNotFound              = "IdTokenHttpNotFound"
  FederatedAuthRequestIssueReasonIdTokenNoResponse                = "IdTokenNoResponse"
  FederatedAuthRequestIssueReasonIdTokenInvalidResponse           = "IdTokenInvalidResponse"
  FederatedAuthRequestIssueReasonIdTokenIdpErrorResponse          = "IdTokenIdpErrorResponse"
  FederatedAuthRequestIssueReasonIdTokenCrossSiteIdpErrorResponse = "IdTokenCrossSiteIdpErrorResponse"
  FederatedAuthRequestIssueReasonIdTokenInvalidRequest            = "IdTokenInvalidRequest"
  FederatedAuthRequestIssueReasonIdTokenInvalidContentType        = "IdTokenInvalidContentType"
  FederatedAuthRequestIssueReasonErrorIdToken                     = "ErrorIdToken"
  FederatedAuthRequestIssueReasonCanceled                         = "Canceled"
  FederatedAuthRequestIssueReasonRpPageNotVisible                 = "RpPageNotVisible"
  FederatedAuthRequestIssueReasonSilentMediationFailure           = "SilentMediationFailure"
  FederatedAuthRequestIssueReasonNotSignedInWithIdp               = "NotSignedInWithIdp"
  FederatedAuthRequestIssueReasonMissingTransientUserActivation   = "MissingTransientUserActivation"
  FederatedAuthRequestIssueReasonReplacedByActiveMode             = "ReplacedByActiveMode"
  FederatedAuthRequestIssueReasonRelyingPartyOriginIsOpaque       = "RelyingPartyOriginIsOpaque"
  FederatedAuthRequestIssueReasonTypeNotMatching                  = "TypeNotMatching"
  FederatedAuthRequestIssueReasonUiDismissedNoEmbargo             = "UiDismissedNoEmbargo"
  FederatedAuthRequestIssueReasonCorsError                        = "CorsError"
  FederatedAuthRequestIssueReasonSuppressedBySegmentationPlatform = "SuppressedBySegmentationPlatform"

  struct FederatedAuthUserInfoRequestIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "federatedAuthUserInfoRequestIssueReason", emit_null: false)]
    property federated_auth_user_info_request_issue_reason : FederatedAuthUserInfoRequestIssueReason
  end

  alias FederatedAuthUserInfoRequestIssueReason = String
  FederatedAuthUserInfoRequestIssueReasonNotSameOrigin                      = "NotSameOrigin"
  FederatedAuthUserInfoRequestIssueReasonNotIframe                          = "NotIframe"
  FederatedAuthUserInfoRequestIssueReasonNotPotentiallyTrustworthy          = "NotPotentiallyTrustworthy"
  FederatedAuthUserInfoRequestIssueReasonNoApiPermission                    = "NoApiPermission"
  FederatedAuthUserInfoRequestIssueReasonNotSignedInWithIdp                 = "NotSignedInWithIdp"
  FederatedAuthUserInfoRequestIssueReasonNoAccountSharingPermission         = "NoAccountSharingPermission"
  FederatedAuthUserInfoRequestIssueReasonInvalidConfigOrWellKnown           = "InvalidConfigOrWellKnown"
  FederatedAuthUserInfoRequestIssueReasonInvalidAccountsResponse            = "InvalidAccountsResponse"
  FederatedAuthUserInfoRequestIssueReasonNoReturningUserFromFetchedAccounts = "NoReturningUserFromFetchedAccounts"

  struct ClientHintIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation
    @[JSON::Field(key: "clientHintIssueReason", emit_null: false)]
    property client_hint_issue_reason : ClientHintIssueReason
  end

  struct FailedRequestInfo
    include JSON::Serializable
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "failureMessage", emit_null: false)]
    property failure_message : String
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : Cdp::Network::RequestId?
  end

  alias PartitioningBlobURLInfo = String
  PartitioningBlobURLInfoBlockedCrossPartitionFetching = "BlockedCrossPartitionFetching"
  PartitioningBlobURLInfoEnforceNoopenerForNavigation  = "EnforceNoopenerForNavigation"

  struct PartitioningBlobURLIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "partitioningBlobUrlInfo", emit_null: false)]
    property partitioning_blob_url_info : PartitioningBlobURLInfo
  end

  alias ElementAccessibilityIssueReason = String
  ElementAccessibilityIssueReasonDisallowedSelectChild               = "DisallowedSelectChild"
  ElementAccessibilityIssueReasonDisallowedOptGroupChild             = "DisallowedOptGroupChild"
  ElementAccessibilityIssueReasonNonPhrasingContentOptionChild       = "NonPhrasingContentOptionChild"
  ElementAccessibilityIssueReasonInteractiveContentOptionChild       = "InteractiveContentOptionChild"
  ElementAccessibilityIssueReasonInteractiveContentLegendChild       = "InteractiveContentLegendChild"
  ElementAccessibilityIssueReasonInteractiveContentSummaryDescendant = "InteractiveContentSummaryDescendant"

  struct ElementAccessibilityIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId
    @[JSON::Field(key: "elementAccessibilityIssueReason", emit_null: false)]
    property element_accessibility_issue_reason : ElementAccessibilityIssueReason
    @[JSON::Field(key: "hasDisallowedAttributes", emit_null: false)]
    property? has_disallowed_attributes : Bool
  end

  alias StyleSheetLoadingIssueReason = String
  StyleSheetLoadingIssueReasonLateImportRule = "LateImportRule"
  StyleSheetLoadingIssueReasonRequestFailed  = "RequestFailed"

  struct StylesheetLoadingIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation
    @[JSON::Field(key: "styleSheetLoadingIssueReason", emit_null: false)]
    property style_sheet_loading_issue_reason : StyleSheetLoadingIssueReason
    @[JSON::Field(key: "failedRequestInfo", emit_null: false)]
    property failed_request_info : FailedRequestInfo?
  end

  alias PropertyRuleIssueReason = String
  PropertyRuleIssueReasonInvalidSyntax       = "InvalidSyntax"
  PropertyRuleIssueReasonInvalidInitialValue = "InvalidInitialValue"
  PropertyRuleIssueReasonInvalidInherits     = "InvalidInherits"
  PropertyRuleIssueReasonInvalidName         = "InvalidName"

  struct PropertyRuleIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation
    @[JSON::Field(key: "propertyRuleIssueReason", emit_null: false)]
    property property_rule_issue_reason : PropertyRuleIssueReason
    @[JSON::Field(key: "propertyValue", emit_null: false)]
    property property_value : String?
  end

  alias UserReidentificationIssueType = String
  UserReidentificationIssueTypeBlockedFrameNavigation = "BlockedFrameNavigation"
  UserReidentificationIssueTypeBlockedSubresource     = "BlockedSubresource"
  UserReidentificationIssueTypeNoisedCanvasReadback   = "NoisedCanvasReadback"

  struct UserReidentificationIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "type", emit_null: false)]
    property type : UserReidentificationIssueType
    @[JSON::Field(key: "request", emit_null: false)]
    property request : AffectedRequest?
    @[JSON::Field(key: "sourceCodeLocation", emit_null: false)]
    property source_code_location : SourceCodeLocation?
  end

  alias PermissionElementIssueType = String
  PermissionElementIssueTypeInvalidType               = "InvalidType"
  PermissionElementIssueTypeFencedFrameDisallowed     = "FencedFrameDisallowed"
  PermissionElementIssueTypeCspFrameAncestorsMissing  = "CspFrameAncestorsMissing"
  PermissionElementIssueTypePermissionsPolicyBlocked  = "PermissionsPolicyBlocked"
  PermissionElementIssueTypePaddingRightUnsupported   = "PaddingRightUnsupported"
  PermissionElementIssueTypePaddingBottomUnsupported  = "PaddingBottomUnsupported"
  PermissionElementIssueTypeInsetBoxShadowUnsupported = "InsetBoxShadowUnsupported"
  PermissionElementIssueTypeRequestInProgress         = "RequestInProgress"
  PermissionElementIssueTypeUntrustedEvent            = "UntrustedEvent"
  PermissionElementIssueTypeRegistrationFailed        = "RegistrationFailed"
  PermissionElementIssueTypeTypeNotSupported          = "TypeNotSupported"
  PermissionElementIssueTypeInvalidTypeActivation     = "InvalidTypeActivation"
  PermissionElementIssueTypeSecurityChecksFailed      = "SecurityChecksFailed"
  PermissionElementIssueTypeActivationDisabled        = "ActivationDisabled"
  PermissionElementIssueTypeGeolocationDeprecated     = "GeolocationDeprecated"
  PermissionElementIssueTypeInvalidDisplayStyle       = "InvalidDisplayStyle"
  PermissionElementIssueTypeNonOpaqueColor            = "NonOpaqueColor"
  PermissionElementIssueTypeLowContrast               = "LowContrast"
  PermissionElementIssueTypeFontSizeTooSmall          = "FontSizeTooSmall"
  PermissionElementIssueTypeFontSizeTooLarge          = "FontSizeTooLarge"
  PermissionElementIssueTypeInvalidSizeValue          = "InvalidSizeValue"

  struct PermissionElementIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "issueType", emit_null: false)]
    property issue_type : PermissionElementIssueType
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String?
    @[JSON::Field(key: "nodeId", emit_null: false)]
    property node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "isWarning", emit_null: false)]
    property? is_warning : Bool?
    @[JSON::Field(key: "permissionName", emit_null: false)]
    property permission_name : String?
    @[JSON::Field(key: "occluderNodeInfo", emit_null: false)]
    property occluder_node_info : String?
    @[JSON::Field(key: "occluderParentNodeInfo", emit_null: false)]
    property occluder_parent_node_info : String?
    @[JSON::Field(key: "disableReason", emit_null: false)]
    property disable_reason : String?
  end

  alias InspectorIssueCode = String
  InspectorIssueCodeCookieIssue                       = "CookieIssue"
  InspectorIssueCodeMixedContentIssue                 = "MixedContentIssue"
  InspectorIssueCodeBlockedByResponseIssue            = "BlockedByResponseIssue"
  InspectorIssueCodeHeavyAdIssue                      = "HeavyAdIssue"
  InspectorIssueCodeContentSecurityPolicyIssue        = "ContentSecurityPolicyIssue"
  InspectorIssueCodeSharedArrayBufferIssue            = "SharedArrayBufferIssue"
  InspectorIssueCodeLowTextContrastIssue              = "LowTextContrastIssue"
  InspectorIssueCodeCorsIssue                         = "CorsIssue"
  InspectorIssueCodeAttributionReportingIssue         = "AttributionReportingIssue"
  InspectorIssueCodeQuirksModeIssue                   = "QuirksModeIssue"
  InspectorIssueCodePartitioningBlobURLIssue          = "PartitioningBlobURLIssue"
  InspectorIssueCodeNavigatorUserAgentIssue           = "NavigatorUserAgentIssue"
  InspectorIssueCodeGenericIssue                      = "GenericIssue"
  InspectorIssueCodeDeprecationIssue                  = "DeprecationIssue"
  InspectorIssueCodeClientHintIssue                   = "ClientHintIssue"
  InspectorIssueCodeFederatedAuthRequestIssue         = "FederatedAuthRequestIssue"
  InspectorIssueCodeBounceTrackingIssue               = "BounceTrackingIssue"
  InspectorIssueCodeCookieDeprecationMetadataIssue    = "CookieDeprecationMetadataIssue"
  InspectorIssueCodeStylesheetLoadingIssue            = "StylesheetLoadingIssue"
  InspectorIssueCodeFederatedAuthUserInfoRequestIssue = "FederatedAuthUserInfoRequestIssue"
  InspectorIssueCodePropertyRuleIssue                 = "PropertyRuleIssue"
  InspectorIssueCodeSharedDictionaryIssue             = "SharedDictionaryIssue"
  InspectorIssueCodeElementAccessibilityIssue         = "ElementAccessibilityIssue"
  InspectorIssueCodeSRIMessageSignatureIssue          = "SRIMessageSignatureIssue"
  InspectorIssueCodeUnencodedDigestIssue              = "UnencodedDigestIssue"
  InspectorIssueCodeConnectionAllowlistIssue          = "ConnectionAllowlistIssue"
  InspectorIssueCodeUserReidentificationIssue         = "UserReidentificationIssue"
  InspectorIssueCodePermissionElementIssue            = "PermissionElementIssue"
  InspectorIssueCodePerformanceIssue                  = "PerformanceIssue"

  struct InspectorIssueDetails
    include JSON::Serializable
    @[JSON::Field(key: "cookieIssueDetails", emit_null: false)]
    property cookie_issue_details : CookieIssueDetails?
    @[JSON::Field(key: "mixedContentIssueDetails", emit_null: false)]
    property mixed_content_issue_details : MixedContentIssueDetails?
    @[JSON::Field(key: "blockedByResponseIssueDetails", emit_null: false)]
    property blocked_by_response_issue_details : BlockedByResponseIssueDetails?
    @[JSON::Field(key: "heavyAdIssueDetails", emit_null: false)]
    property heavy_ad_issue_details : HeavyAdIssueDetails?
    @[JSON::Field(key: "contentSecurityPolicyIssueDetails", emit_null: false)]
    property content_security_policy_issue_details : ContentSecurityPolicyIssueDetails?
    @[JSON::Field(key: "sharedArrayBufferIssueDetails", emit_null: false)]
    property shared_array_buffer_issue_details : SharedArrayBufferIssueDetails?
    @[JSON::Field(key: "lowTextContrastIssueDetails", emit_null: false)]
    property low_text_contrast_issue_details : LowTextContrastIssueDetails?
    @[JSON::Field(key: "corsIssueDetails", emit_null: false)]
    property cors_issue_details : CorsIssueDetails?
    @[JSON::Field(key: "attributionReportingIssueDetails", emit_null: false)]
    property attribution_reporting_issue_details : AttributionReportingIssueDetails?
    @[JSON::Field(key: "quirksModeIssueDetails", emit_null: false)]
    property quirks_mode_issue_details : QuirksModeIssueDetails?
    @[JSON::Field(key: "partitioningBlobUrlIssueDetails", emit_null: false)]
    property partitioning_blob_url_issue_details : PartitioningBlobURLIssueDetails?
    @[JSON::Field(key: "navigatorUserAgentIssueDetails", emit_null: false)]
    property navigator_user_agent_issue_details : NavigatorUserAgentIssueDetails?
    @[JSON::Field(key: "genericIssueDetails", emit_null: false)]
    property generic_issue_details : GenericIssueDetails?
    @[JSON::Field(key: "deprecationIssueDetails", emit_null: false)]
    property deprecation_issue_details : DeprecationIssueDetails?
    @[JSON::Field(key: "clientHintIssueDetails", emit_null: false)]
    property client_hint_issue_details : ClientHintIssueDetails?
    @[JSON::Field(key: "federatedAuthRequestIssueDetails", emit_null: false)]
    property federated_auth_request_issue_details : FederatedAuthRequestIssueDetails?
    @[JSON::Field(key: "bounceTrackingIssueDetails", emit_null: false)]
    property bounce_tracking_issue_details : BounceTrackingIssueDetails?
    @[JSON::Field(key: "cookieDeprecationMetadataIssueDetails", emit_null: false)]
    property cookie_deprecation_metadata_issue_details : CookieDeprecationMetadataIssueDetails?
    @[JSON::Field(key: "stylesheetLoadingIssueDetails", emit_null: false)]
    property stylesheet_loading_issue_details : StylesheetLoadingIssueDetails?
    @[JSON::Field(key: "propertyRuleIssueDetails", emit_null: false)]
    property property_rule_issue_details : PropertyRuleIssueDetails?
    @[JSON::Field(key: "federatedAuthUserInfoRequestIssueDetails", emit_null: false)]
    property federated_auth_user_info_request_issue_details : FederatedAuthUserInfoRequestIssueDetails?
    @[JSON::Field(key: "sharedDictionaryIssueDetails", emit_null: false)]
    property shared_dictionary_issue_details : SharedDictionaryIssueDetails?
    @[JSON::Field(key: "elementAccessibilityIssueDetails", emit_null: false)]
    property element_accessibility_issue_details : ElementAccessibilityIssueDetails?
    @[JSON::Field(key: "sriMessageSignatureIssueDetails", emit_null: false)]
    property sri_message_signature_issue_details : SRIMessageSignatureIssueDetails?
    @[JSON::Field(key: "unencodedDigestIssueDetails", emit_null: false)]
    property unencoded_digest_issue_details : UnencodedDigestIssueDetails?
    @[JSON::Field(key: "connectionAllowlistIssueDetails", emit_null: false)]
    property connection_allowlist_issue_details : ConnectionAllowlistIssueDetails?
    @[JSON::Field(key: "userReidentificationIssueDetails", emit_null: false)]
    property user_reidentification_issue_details : UserReidentificationIssueDetails?
    @[JSON::Field(key: "permissionElementIssueDetails", emit_null: false)]
    property permission_element_issue_details : PermissionElementIssueDetails?
    @[JSON::Field(key: "performanceIssueDetails", emit_null: false)]
    property performance_issue_details : PerformanceIssueDetails?
  end

  alias IssueId = String

  struct InspectorIssue
    include JSON::Serializable
    @[JSON::Field(key: "code", emit_null: false)]
    property code : InspectorIssueCode
    @[JSON::Field(key: "details", emit_null: false)]
    property details : InspectorIssueDetails
    @[JSON::Field(key: "issueId", emit_null: false)]
    property issue_id : IssueId?
  end

  alias GetEncodedResponseEncoding = String
  GetEncodedResponseEncodingWebp = "webp"
  GetEncodedResponseEncodingJpeg = "jpeg"
  GetEncodedResponseEncodingPng  = "png"
end
