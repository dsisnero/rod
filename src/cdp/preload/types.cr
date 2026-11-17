require "../cdp"
require "json"
require "base64"
require "time"

require "../network/network"
require "../dom/dom"
require "../page/page"

module Cdp::Preload
  alias RuleSetId = String

  struct RuleSet
    include JSON::Serializable
    @[JSON::Field(key: "id", emit_null: false)]
    property id : RuleSetId
    @[JSON::Field(key: "loaderId", emit_null: false)]
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(key: "sourceText", emit_null: false)]
    property source_text : String
    @[JSON::Field(key: "backendNodeId", emit_null: false)]
    property backend_node_id : Cdp::DOM::BackendNodeId?
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String?
    @[JSON::Field(key: "requestId", emit_null: false)]
    property request_id : Cdp::Network::RequestId?
    @[JSON::Field(key: "errorType", emit_null: false)]
    property error_type : RuleSetErrorType?
    @[JSON::Field(key: "tag", emit_null: false)]
    property tag : String?

    def initialize(@id : RuleSetId, @loader_id : Cdp::Network::LoaderId, @source_text : String, @backend_node_id : Cdp::DOM::BackendNodeId? = nil, @url : String? = nil, @request_id : Cdp::Network::RequestId? = nil, @error_type : RuleSetErrorType? = nil, @tag : String? = nil)
    end
  end

  alias RuleSetErrorType = String
  RuleSetErrorTypeSourceIsNotJsonObject  = "SourceIsNotJsonObject"
  RuleSetErrorTypeInvalidRulesSkipped    = "InvalidRulesSkipped"
  RuleSetErrorTypeInvalidRulesetLevelTag = "InvalidRulesetLevelTag"

  alias SpeculationAction = String
  SpeculationActionPrefetch             = "Prefetch"
  SpeculationActionPrerender            = "Prerender"
  SpeculationActionPrerenderUntilScript = "PrerenderUntilScript"

  alias SpeculationTargetHint = String
  SpeculationTargetHintBlank = "Blank"
  SpeculationTargetHintSelf  = "Self"

  struct PreloadingAttemptKey
    include JSON::Serializable
    @[JSON::Field(key: "loaderId", emit_null: false)]
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(key: "action", emit_null: false)]
    property action : SpeculationAction
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "formSubmission", emit_null: false)]
    property? form_submission : Bool?
    @[JSON::Field(key: "targetHint", emit_null: false)]
    property target_hint : SpeculationTargetHint?

    def initialize(@loader_id : Cdp::Network::LoaderId, @action : SpeculationAction, @url : String, @form_submission : Bool? = nil, @target_hint : SpeculationTargetHint? = nil)
    end
  end

  struct PreloadingAttemptSource
    include JSON::Serializable
    @[JSON::Field(key: "key", emit_null: false)]
    property key : PreloadingAttemptKey
    @[JSON::Field(key: "ruleSetIds", emit_null: false)]
    property rule_set_ids : Array(RuleSetId)
    @[JSON::Field(key: "nodeIds", emit_null: false)]
    property node_ids : Array(Cdp::DOM::BackendNodeId)

    def initialize(@key : PreloadingAttemptKey, @rule_set_ids : Array(RuleSetId), @node_ids : Array(Cdp::DOM::BackendNodeId))
    end
  end

  alias PreloadPipelineId = String

  alias PrerenderFinalStatus = String
  PrerenderFinalStatusActivated                                                  = "Activated"
  PrerenderFinalStatusDestroyed                                                  = "Destroyed"
  PrerenderFinalStatusLowEndDevice                                               = "LowEndDevice"
  PrerenderFinalStatusInvalidSchemeRedirect                                      = "InvalidSchemeRedirect"
  PrerenderFinalStatusInvalidSchemeNavigation                                    = "InvalidSchemeNavigation"
  PrerenderFinalStatusNavigationRequestBlockedByCsp                              = "NavigationRequestBlockedByCsp"
  PrerenderFinalStatusMojoBinderPolicy                                           = "MojoBinderPolicy"
  PrerenderFinalStatusRendererProcessCrashed                                     = "RendererProcessCrashed"
  PrerenderFinalStatusRendererProcessKilled                                      = "RendererProcessKilled"
  PrerenderFinalStatusDownload                                                   = "Download"
  PrerenderFinalStatusTriggerDestroyed                                           = "TriggerDestroyed"
  PrerenderFinalStatusNavigationNotCommitted                                     = "NavigationNotCommitted"
  PrerenderFinalStatusNavigationBadHttpStatus                                    = "NavigationBadHttpStatus"
  PrerenderFinalStatusClientCertRequested                                        = "ClientCertRequested"
  PrerenderFinalStatusNavigationRequestNetworkError                              = "NavigationRequestNetworkError"
  PrerenderFinalStatusCancelAllHostsForTesting                                   = "CancelAllHostsForTesting"
  PrerenderFinalStatusDidFailLoad                                                = "DidFailLoad"
  PrerenderFinalStatusStop                                                       = "Stop"
  PrerenderFinalStatusSslCertificateError                                        = "SslCertificateError"
  PrerenderFinalStatusLoginAuthRequested                                         = "LoginAuthRequested"
  PrerenderFinalStatusUaChangeRequiresReload                                     = "UaChangeRequiresReload"
  PrerenderFinalStatusBlockedByClient                                            = "BlockedByClient"
  PrerenderFinalStatusAudioOutputDeviceRequested                                 = "AudioOutputDeviceRequested"
  PrerenderFinalStatusMixedContent                                               = "MixedContent"
  PrerenderFinalStatusTriggerBackgrounded                                        = "TriggerBackgrounded"
  PrerenderFinalStatusMemoryLimitExceeded                                        = "MemoryLimitExceeded"
  PrerenderFinalStatusDataSaverEnabled                                           = "DataSaverEnabled"
  PrerenderFinalStatusTriggerUrlHasEffectiveUrl                                  = "TriggerUrlHasEffectiveUrl"
  PrerenderFinalStatusActivatedBeforeStarted                                     = "ActivatedBeforeStarted"
  PrerenderFinalStatusInactivePageRestriction                                    = "InactivePageRestriction"
  PrerenderFinalStatusStartFailed                                                = "StartFailed"
  PrerenderFinalStatusTimeoutBackgrounded                                        = "TimeoutBackgrounded"
  PrerenderFinalStatusCrossSiteRedirectInInitialNavigation                       = "CrossSiteRedirectInInitialNavigation"
  PrerenderFinalStatusCrossSiteNavigationInInitialNavigation                     = "CrossSiteNavigationInInitialNavigation"
  PrerenderFinalStatusSameSiteCrossOriginRedirectNotOptInInInitialNavigation     = "SameSiteCrossOriginRedirectNotOptInInInitialNavigation"
  PrerenderFinalStatusSameSiteCrossOriginNavigationNotOptInInInitialNavigation   = "SameSiteCrossOriginNavigationNotOptInInInitialNavigation"
  PrerenderFinalStatusActivationNavigationParameterMismatch                      = "ActivationNavigationParameterMismatch"
  PrerenderFinalStatusActivatedInBackground                                      = "ActivatedInBackground"
  PrerenderFinalStatusEmbedderHostDisallowed                                     = "EmbedderHostDisallowed"
  PrerenderFinalStatusActivationNavigationDestroyedBeforeSuccess                 = "ActivationNavigationDestroyedBeforeSuccess"
  PrerenderFinalStatusTabClosedByUserGesture                                     = "TabClosedByUserGesture"
  PrerenderFinalStatusTabClosedWithoutUserGesture                                = "TabClosedWithoutUserGesture"
  PrerenderFinalStatusPrimaryMainFrameRendererProcessCrashed                     = "PrimaryMainFrameRendererProcessCrashed"
  PrerenderFinalStatusPrimaryMainFrameRendererProcessKilled                      = "PrimaryMainFrameRendererProcessKilled"
  PrerenderFinalStatusActivationFramePolicyNotCompatible                         = "ActivationFramePolicyNotCompatible"
  PrerenderFinalStatusPreloadingDisabled                                         = "PreloadingDisabled"
  PrerenderFinalStatusBatterySaverEnabled                                        = "BatterySaverEnabled"
  PrerenderFinalStatusActivatedDuringMainFrameNavigation                         = "ActivatedDuringMainFrameNavigation"
  PrerenderFinalStatusPreloadingUnsupportedByWebContents                         = "PreloadingUnsupportedByWebContents"
  PrerenderFinalStatusCrossSiteRedirectInMainFrameNavigation                     = "CrossSiteRedirectInMainFrameNavigation"
  PrerenderFinalStatusCrossSiteNavigationInMainFrameNavigation                   = "CrossSiteNavigationInMainFrameNavigation"
  PrerenderFinalStatusSameSiteCrossOriginRedirectNotOptInInMainFrameNavigation   = "SameSiteCrossOriginRedirectNotOptInInMainFrameNavigation"
  PrerenderFinalStatusSameSiteCrossOriginNavigationNotOptInInMainFrameNavigation = "SameSiteCrossOriginNavigationNotOptInInMainFrameNavigation"
  PrerenderFinalStatusMemoryPressureOnTrigger                                    = "MemoryPressureOnTrigger"
  PrerenderFinalStatusMemoryPressureAfterTriggered                               = "MemoryPressureAfterTriggered"
  PrerenderFinalStatusPrerenderingDisabledByDevTools                             = "PrerenderingDisabledByDevTools"
  PrerenderFinalStatusSpeculationRuleRemoved                                     = "SpeculationRuleRemoved"
  PrerenderFinalStatusActivatedWithAuxiliaryBrowsingContexts                     = "ActivatedWithAuxiliaryBrowsingContexts"
  PrerenderFinalStatusMaxNumOfRunningEagerPrerendersExceeded                     = "MaxNumOfRunningEagerPrerendersExceeded"
  PrerenderFinalStatusMaxNumOfRunningNonEagerPrerendersExceeded                  = "MaxNumOfRunningNonEagerPrerendersExceeded"
  PrerenderFinalStatusMaxNumOfRunningEmbedderPrerendersExceeded                  = "MaxNumOfRunningEmbedderPrerendersExceeded"
  PrerenderFinalStatusPrerenderingUrlHasEffectiveUrl                             = "PrerenderingUrlHasEffectiveUrl"
  PrerenderFinalStatusRedirectedPrerenderingUrlHasEffectiveUrl                   = "RedirectedPrerenderingUrlHasEffectiveUrl"
  PrerenderFinalStatusActivationUrlHasEffectiveUrl                               = "ActivationUrlHasEffectiveUrl"
  PrerenderFinalStatusJavaScriptInterfaceAdded                                   = "JavaScriptInterfaceAdded"
  PrerenderFinalStatusJavaScriptInterfaceRemoved                                 = "JavaScriptInterfaceRemoved"
  PrerenderFinalStatusAllPrerenderingCanceled                                    = "AllPrerenderingCanceled"
  PrerenderFinalStatusWindowClosed                                               = "WindowClosed"
  PrerenderFinalStatusSlowNetwork                                                = "SlowNetwork"
  PrerenderFinalStatusOtherPrerenderedPageActivated                              = "OtherPrerenderedPageActivated"
  PrerenderFinalStatusV8OptimizerDisabled                                        = "V8OptimizerDisabled"
  PrerenderFinalStatusPrerenderFailedDuringPrefetch                              = "PrerenderFailedDuringPrefetch"
  PrerenderFinalStatusBrowsingDataRemoved                                        = "BrowsingDataRemoved"
  PrerenderFinalStatusPrerenderHostReused                                        = "PrerenderHostReused"
  PrerenderFinalStatusFormSubmitWhenPrerendering                                 = "FormSubmitWhenPrerendering"
  PrerenderFinalStatusCrossDocumentRestart                                       = "CrossDocumentRestart"
  PrerenderFinalStatusPrefetchFailedCrossOriginSubframe                          = "PrefetchFailedCrossOriginSubframe"
  PrerenderFinalStatusUnexpectedMainFrameNavigation                              = "UnexpectedMainFrameNavigation"

  alias PreloadingStatus = String
  PreloadingStatusPending      = "Pending"
  PreloadingStatusRunning      = "Running"
  PreloadingStatusReady        = "Ready"
  PreloadingStatusSuccess      = "Success"
  PreloadingStatusFailure      = "Failure"
  PreloadingStatusNotSupported = "NotSupported"

  alias PrefetchStatus = String
  PrefetchStatusPrefetchAllowed                                             = "PrefetchAllowed"
  PrefetchStatusPrefetchFailedIneligibleRedirect                            = "PrefetchFailedIneligibleRedirect"
  PrefetchStatusPrefetchFailedInvalidRedirect                               = "PrefetchFailedInvalidRedirect"
  PrefetchStatusPrefetchFailedMIMENotSupported                              = "PrefetchFailedMIMENotSupported"
  PrefetchStatusPrefetchFailedNetError                                      = "PrefetchFailedNetError"
  PrefetchStatusPrefetchFailedNon2XX                                        = "PrefetchFailedNon2XX"
  PrefetchStatusPrefetchEvictedAfterBrowsingDataRemoved                     = "PrefetchEvictedAfterBrowsingDataRemoved"
  PrefetchStatusPrefetchEvictedAfterCandidateRemoved                        = "PrefetchEvictedAfterCandidateRemoved"
  PrefetchStatusPrefetchEvictedForNewerPrefetch                             = "PrefetchEvictedForNewerPrefetch"
  PrefetchStatusPrefetchHeldback                                            = "PrefetchHeldback"
  PrefetchStatusPrefetchIneligibleRetryAfter                                = "PrefetchIneligibleRetryAfter"
  PrefetchStatusPrefetchIsPrivacyDecoy                                      = "PrefetchIsPrivacyDecoy"
  PrefetchStatusPrefetchIsStale                                             = "PrefetchIsStale"
  PrefetchStatusPrefetchNotEligibleBlockedByConnectionAllowlist             = "PrefetchNotEligibleBlockedByConnectionAllowlist"
  PrefetchStatusPrefetchNotEligibleBrowserContextOffTheRecord               = "PrefetchNotEligibleBrowserContextOffTheRecord"
  PrefetchStatusPrefetchNotEligibleCrossOrigin                              = "PrefetchNotEligibleCrossOrigin"
  PrefetchStatusPrefetchNotEligibleDataSaverEnabled                         = "PrefetchNotEligibleDataSaverEnabled"
  PrefetchStatusPrefetchNotEligibleExistingProxy                            = "PrefetchNotEligibleExistingProxy"
  PrefetchStatusPrefetchNotEligibleHostIsNonUnique                          = "PrefetchNotEligibleHostIsNonUnique"
  PrefetchStatusPrefetchNotEligibleNonDefaultStoragePartition               = "PrefetchNotEligibleNonDefaultStoragePartition"
  PrefetchStatusPrefetchNotEligibleSameSiteCrossOriginPrefetchRequiredProxy = "PrefetchNotEligibleSameSiteCrossOriginPrefetchRequiredProxy"
  PrefetchStatusPrefetchNotEligibleSchemeIsNotHttps                         = "PrefetchNotEligibleSchemeIsNotHttps"
  PrefetchStatusPrefetchNotEligibleUserHasCookies                           = "PrefetchNotEligibleUserHasCookies"
  PrefetchStatusPrefetchNotEligibleUserHasServiceWorker                     = "PrefetchNotEligibleUserHasServiceWorker"
  PrefetchStatusPrefetchNotEligibleUserHasServiceWorkerNoFetchHandler       = "PrefetchNotEligibleUserHasServiceWorkerNoFetchHandler"
  PrefetchStatusPrefetchNotEligibleRedirectFromServiceWorker                = "PrefetchNotEligibleRedirectFromServiceWorker"
  PrefetchStatusPrefetchNotEligibleRedirectToServiceWorker                  = "PrefetchNotEligibleRedirectToServiceWorker"
  PrefetchStatusPrefetchNotEligibleBatterySaverEnabled                      = "PrefetchNotEligibleBatterySaverEnabled"
  PrefetchStatusPrefetchNotEligiblePreloadingDisabled                       = "PrefetchNotEligiblePreloadingDisabled"
  PrefetchStatusPrefetchNotFinishedInTime                                   = "PrefetchNotFinishedInTime"
  PrefetchStatusPrefetchNotStarted                                          = "PrefetchNotStarted"
  PrefetchStatusPrefetchNotUsedCookiesChanged                               = "PrefetchNotUsedCookiesChanged"
  PrefetchStatusPrefetchProxyNotAvailable                                   = "PrefetchProxyNotAvailable"
  PrefetchStatusPrefetchResponseUsed                                        = "PrefetchResponseUsed"
  PrefetchStatusPrefetchSuccessfulButNotUsed                                = "PrefetchSuccessfulButNotUsed"
  PrefetchStatusPrefetchNotUsedProbeFailed                                  = "PrefetchNotUsedProbeFailed"
  PrefetchStatusPrefetchCancelledOnUserNavigation                           = "PrefetchCancelledOnUserNavigation"

  struct PrerenderMismatchedHeaders
    include JSON::Serializable
    @[JSON::Field(key: "headerName", emit_null: false)]
    property header_name : String
    @[JSON::Field(key: "initialValue", emit_null: false)]
    property initial_value : String?
    @[JSON::Field(key: "activationValue", emit_null: false)]
    property activation_value : String?

    def initialize(@header_name : String, @initial_value : String? = nil, @activation_value : String? = nil)
    end
  end
end
