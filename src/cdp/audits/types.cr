require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Audits
  struct AffectedCookie
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property path : String
    @[JSON::Field(emit_null: false)]
    property domain : String
  end

  struct AffectedRequest
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property url : String
  end

  struct AffectedFrame
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property table_entry_url : String?
  end

  struct CookieIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cookie : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property raw_cookie_line : String?
    @[JSON::Field(emit_null: false)]
    property cookie_warning_reasons : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property cookie_exclusion_reasons : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property operation : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property site_for_cookies : String?
    @[JSON::Field(emit_null: false)]
    property cookie_url : String?
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property insight : Cdp::NodeType?
  end

  alias PerformanceIssueType = String
  PerformanceIssueTypeDocumentCookie = "DocumentCookie"

  struct PerformanceIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property performance_issue_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType?
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
    @[JSON::Field(emit_null: false)]
    property resource_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property resolution_status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property insecure_url : String
    @[JSON::Field(emit_null: false)]
    property main_resource_url : String
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property frame : Cdp::NodeType?
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
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property parent_frame : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property blocked_frame : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property reason : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property resolution : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64
  end

  struct ContentSecurityPolicyIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property blocked_url : String?
    @[JSON::Field(emit_null: false)]
    property violated_directive : String
    @[JSON::Field(emit_null: false)]
    property? is_report_only : Bool
    @[JSON::Field(emit_null: false)]
    property content_security_policy_violation_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_ancestor : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::NodeType?
  end

  alias SharedArrayBufferIssueType = String
  SharedArrayBufferIssueTypeTransferIssue = "TransferIssue"
  SharedArrayBufferIssueTypeCreationIssue = "CreationIssue"

  struct SharedArrayBufferIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_warning : Bool
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
  end

  struct LowTextContrastIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property violating_node_selector : String
    @[JSON::Field(emit_null: false)]
    property contrast_ratio : Float64
    @[JSON::Field(emit_null: false)]
    property threshold_aa : Float64
    @[JSON::Field(emit_null: false)]
    property threshold_aaa : Float64
    @[JSON::Field(emit_null: false)]
    property font_size : String
    @[JSON::Field(emit_null: false)]
    property font_weight : String
  end

  struct CorsIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property cors_error_status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_warning : Bool
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property location : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property initiator_origin : String?
    @[JSON::Field(emit_null: false)]
    property resource_ip_address_space : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property client_security_state : Cdp::NodeType?
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
    @[JSON::Field(emit_null: false)]
    property violation_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property invalid_parameter : String?
  end

  struct QuirksModeIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? is_limited_quirks_mode : Bool
    @[JSON::Field(emit_null: false)]
    property document_node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
  end

  struct SharedDictionaryIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property shared_dictionary_error : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
  end

  struct SRIMessageSignatureIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property error : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property signature_base : String
    @[JSON::Field(emit_null: false)]
    property integrity_assertions : Array(String)
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
  end

  struct UnencodedDigestIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property error : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
  end

  struct ConnectionAllowlistIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property error : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property error_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property violating_node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property violating_node_attribute : String?
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType?
  end

  struct DeprecationIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property affected_frame : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : String
  end

  struct BounceTrackingIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property tracking_sites : Array(String)
  end

  struct CookieDeprecationMetadataIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property allowed_sites : Array(String)
    @[JSON::Field(emit_null: false)]
    property opt_out_percentage : Float64
    @[JSON::Field(emit_null: false)]
    property? is_opt_out_top_level : Bool
    @[JSON::Field(emit_null: false)]
    property operation : Cdp::NodeType
  end

  alias ClientHintIssueReason = String
  ClientHintIssueReasonMetaTagAllowListInvalidOrigin = "MetaTagAllowListInvalidOrigin"
  ClientHintIssueReasonMetaTagModifiedHTML           = "MetaTagModifiedHTML"

  struct FederatedAuthRequestIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property federated_auth_request_issue_reason : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property federated_auth_user_info_request_issue_reason : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property client_hint_issue_reason : Cdp::NodeType
  end

  struct FailedRequestInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property failure_message : String
    @[JSON::Field(emit_null: false)]
    property request_id : Cdp::NodeType?
  end

  alias PartitioningBlobURLInfo = String
  PartitioningBlobURLInfoBlockedCrossPartitionFetching = "BlockedCrossPartitionFetching"
  PartitioningBlobURLInfoEnforceNoopenerForNavigation  = "EnforceNoopenerForNavigation"

  struct PartitioningBlobURLIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property partitioning_blob_url_info : Cdp::NodeType
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
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property element_accessibility_issue_reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? has_disallowed_attributes : Bool
  end

  alias StyleSheetLoadingIssueReason = String
  StyleSheetLoadingIssueReasonLateImportRule = "LateImportRule"
  StyleSheetLoadingIssueReasonRequestFailed  = "RequestFailed"

  struct StylesheetLoadingIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property style_sheet_loading_issue_reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property failed_request_info : Cdp::NodeType?
  end

  alias PropertyRuleIssueReason = String
  PropertyRuleIssueReasonInvalidSyntax       = "InvalidSyntax"
  PropertyRuleIssueReasonInvalidInitialValue = "InvalidInitialValue"
  PropertyRuleIssueReasonInvalidInherits     = "InvalidInherits"
  PropertyRuleIssueReasonInvalidName         = "InvalidName"

  struct PropertyRuleIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property property_rule_issue_reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property property_value : String?
  end

  alias UserReidentificationIssueType = String
  UserReidentificationIssueTypeBlockedFrameNavigation = "BlockedFrameNavigation"
  UserReidentificationIssueTypeBlockedSubresource     = "BlockedSubresource"
  UserReidentificationIssueTypeNoisedCanvasReadback   = "NoisedCanvasReadback"

  struct UserReidentificationIssueDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property request : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property source_code_location : Cdp::NodeType?
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
    @[JSON::Field(emit_null: false)]
    property issue_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property type : String?
    @[JSON::Field(emit_null: false)]
    property node_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? is_warning : Bool?
    @[JSON::Field(emit_null: false)]
    property permission_name : String?
    @[JSON::Field(emit_null: false)]
    property occluder_node_info : String?
    @[JSON::Field(emit_null: false)]
    property occluder_parent_node_info : String?
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property cookie_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property mixed_content_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property blocked_by_response_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property heavy_ad_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property content_security_policy_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property shared_array_buffer_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property low_text_contrast_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cors_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property attribution_reporting_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property quirks_mode_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property partitioning_blob_url_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property navigator_user_agent_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property generic_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property deprecation_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property client_hint_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property federated_auth_request_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property bounce_tracking_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property cookie_deprecation_metadata_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property stylesheet_loading_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property property_rule_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property federated_auth_user_info_request_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property shared_dictionary_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property element_accessibility_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property sri_message_signature_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property unencoded_digest_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property connection_allowlist_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property user_reidentification_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property permission_element_issue_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property performance_issue_details : Cdp::NodeType?
  end

  alias IssueId = String

  struct InspectorIssue
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property code : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property details : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property issue_id : Cdp::NodeType?
  end

  alias GetEncodedResponseEncoding = String
  GetEncodedResponseEncodingWebp = "webp"
  GetEncodedResponseEncodingJpeg = "jpeg"
  GetEncodedResponseEncodingPng  = "png"
end
