require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Page
  alias FrameId = String

  @[Experimental]
  alias AdFrameType = String
  AdFrameTypeNone  = "none"
  AdFrameTypeChild = "child"
  AdFrameTypeRoot  = "root"

  @[Experimental]
  alias AdFrameExplanation = String
  AdFrameExplanationParentIsAd          = "ParentIsAd"
  AdFrameExplanationCreatedByAdScript   = "CreatedByAdScript"
  AdFrameExplanationMatchedBlockingRule = "MatchedBlockingRule"

  @[Experimental]
  struct AdFrameStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property ad_frame_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property explanations : Array(Cdp::NodeType)?
  end

  @[Experimental]
  struct AdScriptId
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property debugger_id : Cdp::NodeType
  end

  @[Experimental]
  struct AdScriptAncestry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property ancestry_chain : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property root_script_filterlist_rule : String?
  end

  @[Experimental]
  alias SecureContextType = String
  SecureContextTypeSecure           = "Secure"
  SecureContextTypeSecureLocalhost  = "SecureLocalhost"
  SecureContextTypeInsecureScheme   = "InsecureScheme"
  SecureContextTypeInsecureAncestor = "InsecureAncestor"

  @[Experimental]
  alias CrossOriginIsolatedContextType = String
  CrossOriginIsolatedContextTypeIsolated                   = "Isolated"
  CrossOriginIsolatedContextTypeNotIsolated                = "NotIsolated"
  CrossOriginIsolatedContextTypeNotIsolatedFeatureDisabled = "NotIsolatedFeatureDisabled"

  @[Experimental]
  alias GatedAPIFeatures = String
  GatedAPIFeaturesSharedArrayBuffers                = "SharedArrayBuffers"
  GatedAPIFeaturesSharedArrayBuffersTransferAllowed = "SharedArrayBuffersTransferAllowed"
  GatedAPIFeaturesPerformanceMeasureMemory          = "PerformanceMeasureMemory"
  GatedAPIFeaturesPerformanceProfile                = "PerformanceProfile"

  @[Experimental]
  alias PermissionsPolicyFeature = String
  PermissionsPolicyFeatureAccelerometer                  = "accelerometer"
  PermissionsPolicyFeatureAllScreensCapture              = "all-screens-capture"
  PermissionsPolicyFeatureAmbientLightSensor             = "ambient-light-sensor"
  PermissionsPolicyFeatureAriaNotify                     = "aria-notify"
  PermissionsPolicyFeatureAttributionReporting           = "attribution-reporting"
  PermissionsPolicyFeatureAutofill                       = "autofill"
  PermissionsPolicyFeatureAutoplay                       = "autoplay"
  PermissionsPolicyFeatureBluetooth                      = "bluetooth"
  PermissionsPolicyFeatureBrowsingTopics                 = "browsing-topics"
  PermissionsPolicyFeatureCamera                         = "camera"
  PermissionsPolicyFeatureCapturedSurfaceControl         = "captured-surface-control"
  PermissionsPolicyFeatureChDpr                          = "ch-dpr"
  PermissionsPolicyFeatureChDeviceMemory                 = "ch-device-memory"
  PermissionsPolicyFeatureChDownlink                     = "ch-downlink"
  PermissionsPolicyFeatureChEct                          = "ch-ect"
  PermissionsPolicyFeatureChPrefersColorScheme           = "ch-prefers-color-scheme"
  PermissionsPolicyFeatureChPrefersReducedMotion         = "ch-prefers-reduced-motion"
  PermissionsPolicyFeatureChPrefersReducedTransparency   = "ch-prefers-reduced-transparency"
  PermissionsPolicyFeatureChRtt                          = "ch-rtt"
  PermissionsPolicyFeatureChSaveData                     = "ch-save-data"
  PermissionsPolicyFeatureChUa                           = "ch-ua"
  PermissionsPolicyFeatureChUaArch                       = "ch-ua-arch"
  PermissionsPolicyFeatureChUaBitness                    = "ch-ua-bitness"
  PermissionsPolicyFeatureChUaHighEntropyValues          = "ch-ua-high-entropy-values"
  PermissionsPolicyFeatureChUaPlatform                   = "ch-ua-platform"
  PermissionsPolicyFeatureChUaModel                      = "ch-ua-model"
  PermissionsPolicyFeatureChUaMobile                     = "ch-ua-mobile"
  PermissionsPolicyFeatureChUaFormFactors                = "ch-ua-form-factors"
  PermissionsPolicyFeatureChUaFullVersion                = "ch-ua-full-version"
  PermissionsPolicyFeatureChUaFullVersionList            = "ch-ua-full-version-list"
  PermissionsPolicyFeatureChUaPlatformVersion            = "ch-ua-platform-version"
  PermissionsPolicyFeatureChUaWow64                      = "ch-ua-wow64"
  PermissionsPolicyFeatureChViewportHeight               = "ch-viewport-height"
  PermissionsPolicyFeatureChViewportWidth                = "ch-viewport-width"
  PermissionsPolicyFeatureChWidth                        = "ch-width"
  PermissionsPolicyFeatureClipboardRead                  = "clipboard-read"
  PermissionsPolicyFeatureClipboardWrite                 = "clipboard-write"
  PermissionsPolicyFeatureComputePressure                = "compute-pressure"
  PermissionsPolicyFeatureControlledFrame                = "controlled-frame"
  PermissionsPolicyFeatureCrossOriginIsolated            = "cross-origin-isolated"
  PermissionsPolicyFeatureDeferredFetch                  = "deferred-fetch"
  PermissionsPolicyFeatureDeferredFetchMinimal           = "deferred-fetch-minimal"
  PermissionsPolicyFeatureDeviceAttributes               = "device-attributes"
  PermissionsPolicyFeatureDigitalCredentialsCreate       = "digital-credentials-create"
  PermissionsPolicyFeatureDigitalCredentialsGet          = "digital-credentials-get"
  PermissionsPolicyFeatureDirectSockets                  = "direct-sockets"
  PermissionsPolicyFeatureDirectSocketsMulticast         = "direct-sockets-multicast"
  PermissionsPolicyFeatureDirectSocketsPrivate           = "direct-sockets-private"
  PermissionsPolicyFeatureDisplayCapture                 = "display-capture"
  PermissionsPolicyFeatureDocumentDomain                 = "document-domain"
  PermissionsPolicyFeatureEncryptedMedia                 = "encrypted-media"
  PermissionsPolicyFeatureExecutionWhileOutOfViewport    = "execution-while-out-of-viewport"
  PermissionsPolicyFeatureExecutionWhileNotRendered      = "execution-while-not-rendered"
  PermissionsPolicyFeatureFencedUnpartitionedStorageRead = "fenced-unpartitioned-storage-read"
  PermissionsPolicyFeatureFocusWithoutUserActivation     = "focus-without-user-activation"
  PermissionsPolicyFeatureFullscreen                     = "fullscreen"
  PermissionsPolicyFeatureFrobulate                      = "frobulate"
  PermissionsPolicyFeatureGamepad                        = "gamepad"
  PermissionsPolicyFeatureGeolocation                    = "geolocation"
  PermissionsPolicyFeatureGyroscope                      = "gyroscope"
  PermissionsPolicyFeatureHid                            = "hid"
  PermissionsPolicyFeatureIdentityCredentialsGet         = "identity-credentials-get"
  PermissionsPolicyFeatureIdleDetection                  = "idle-detection"
  PermissionsPolicyFeatureInterestCohort                 = "interest-cohort"
  PermissionsPolicyFeatureJoinAdInterestGroup            = "join-ad-interest-group"
  PermissionsPolicyFeatureKeyboardMap                    = "keyboard-map"
  PermissionsPolicyFeatureLanguageDetector               = "language-detector"
  PermissionsPolicyFeatureLanguageModel                  = "language-model"
  PermissionsPolicyFeatureLocalFonts                     = "local-fonts"
  PermissionsPolicyFeatureLocalNetwork                   = "local-network"
  PermissionsPolicyFeatureLocalNetworkAccess             = "local-network-access"
  PermissionsPolicyFeatureLoopbackNetwork                = "loopback-network"
  PermissionsPolicyFeatureMagnetometer                   = "magnetometer"
  PermissionsPolicyFeatureManualText                     = "manual-text"
  PermissionsPolicyFeatureMediaPlaybackWhileNotVisible   = "media-playback-while-not-visible"
  PermissionsPolicyFeatureMicrophone                     = "microphone"
  PermissionsPolicyFeatureMidi                           = "midi"
  PermissionsPolicyFeatureOnDeviceSpeechRecognition      = "on-device-speech-recognition"
  PermissionsPolicyFeatureOtpCredentials                 = "otp-credentials"
  PermissionsPolicyFeaturePayment                        = "payment"
  PermissionsPolicyFeaturePictureInPicture               = "picture-in-picture"
  PermissionsPolicyFeaturePrivateAggregation             = "private-aggregation"
  PermissionsPolicyFeaturePrivateStateTokenIssuance      = "private-state-token-issuance"
  PermissionsPolicyFeaturePrivateStateTokenRedemption    = "private-state-token-redemption"
  PermissionsPolicyFeaturePublickeyCredentialsCreate     = "publickey-credentials-create"
  PermissionsPolicyFeaturePublickeyCredentialsGet        = "publickey-credentials-get"
  PermissionsPolicyFeatureRecordAdAuctionEvents          = "record-ad-auction-events"
  PermissionsPolicyFeatureRewriter                       = "rewriter"
  PermissionsPolicyFeatureRunAdAuction                   = "run-ad-auction"
  PermissionsPolicyFeatureScreenWakeLock                 = "screen-wake-lock"
  PermissionsPolicyFeatureSerial                         = "serial"
  PermissionsPolicyFeatureSharedStorage                  = "shared-storage"
  PermissionsPolicyFeatureSharedStorageSelectUrl         = "shared-storage-select-url"
  PermissionsPolicyFeatureSmartCard                      = "smart-card"
  PermissionsPolicyFeatureSpeakerSelection               = "speaker-selection"
  PermissionsPolicyFeatureStorageAccess                  = "storage-access"
  PermissionsPolicyFeatureSubApps                        = "sub-apps"
  PermissionsPolicyFeatureSummarizer                     = "summarizer"
  PermissionsPolicyFeatureSyncXhr                        = "sync-xhr"
  PermissionsPolicyFeatureTranslator                     = "translator"
  PermissionsPolicyFeatureUnload                         = "unload"
  PermissionsPolicyFeatureUsb                            = "usb"
  PermissionsPolicyFeatureUsbUnrestricted                = "usb-unrestricted"
  PermissionsPolicyFeatureVerticalScroll                 = "vertical-scroll"
  PermissionsPolicyFeatureWebAppInstallation             = "web-app-installation"
  PermissionsPolicyFeatureWebPrinting                    = "web-printing"
  PermissionsPolicyFeatureWebShare                       = "web-share"
  PermissionsPolicyFeatureWindowManagement               = "window-management"
  PermissionsPolicyFeatureWriter                         = "writer"
  PermissionsPolicyFeatureXrSpatialTracking              = "xr-spatial-tracking"

  @[Experimental]
  alias PermissionsPolicyBlockReason = String
  PermissionsPolicyBlockReasonHeader            = "Header"
  PermissionsPolicyBlockReasonIframeAttribute   = "IframeAttribute"
  PermissionsPolicyBlockReasonInFencedFrameTree = "InFencedFrameTree"
  PermissionsPolicyBlockReasonInIsolatedApp     = "InIsolatedApp"

  @[Experimental]
  struct PermissionsPolicyBlockLocator
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property block_reason : Cdp::NodeType
  end

  @[Experimental]
  struct PermissionsPolicyFeatureState
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property feature : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? allowed : Bool
    @[JSON::Field(emit_null: false)]
    property locator : Cdp::NodeType?
  end

  @[Experimental]
  alias OriginTrialTokenStatus = String
  OriginTrialTokenStatusSuccess                = "Success"
  OriginTrialTokenStatusNotSupported           = "NotSupported"
  OriginTrialTokenStatusInsecure               = "Insecure"
  OriginTrialTokenStatusExpired                = "Expired"
  OriginTrialTokenStatusWrongOrigin            = "WrongOrigin"
  OriginTrialTokenStatusInvalidSignature       = "InvalidSignature"
  OriginTrialTokenStatusMalformed              = "Malformed"
  OriginTrialTokenStatusWrongVersion           = "WrongVersion"
  OriginTrialTokenStatusFeatureDisabled        = "FeatureDisabled"
  OriginTrialTokenStatusTokenDisabled          = "TokenDisabled"
  OriginTrialTokenStatusFeatureDisabledForUser = "FeatureDisabledForUser"
  OriginTrialTokenStatusUnknownTrial           = "UnknownTrial"

  @[Experimental]
  alias OriginTrialStatus = String
  OriginTrialStatusEnabled               = "Enabled"
  OriginTrialStatusValidTokenNotProvided = "ValidTokenNotProvided"
  OriginTrialStatusOSNotSupported        = "OSNotSupported"
  OriginTrialStatusTrialNotAllowed       = "TrialNotAllowed"

  @[Experimental]
  alias OriginTrialUsageRestriction = String
  OriginTrialUsageRestrictionNone   = "None"
  OriginTrialUsageRestrictionSubset = "Subset"

  @[Experimental]
  struct OriginTrialToken
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property? match_sub_domains : Bool
    @[JSON::Field(emit_null: false)]
    property trial_name : String
    @[JSON::Field(emit_null: false)]
    property expiry_time : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property? is_third_party : Bool
    @[JSON::Field(emit_null: false)]
    property usage_restriction : Cdp::NodeType
  end

  @[Experimental]
  struct OriginTrialTokenWithStatus
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property raw_token_text : String
    @[JSON::Field(emit_null: false)]
    property parsed_token : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
  end

  @[Experimental]
  struct OriginTrial
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property trial_name : String
    @[JSON::Field(emit_null: false)]
    property status : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property tokens_with_status : Array(Cdp::NodeType)
  end

  @[Experimental]
  struct SecurityOriginDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property? is_localhost : Bool
  end

  struct Frame
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property parent_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property url_fragment : String?
    @[JSON::Field(emit_null: false)]
    property domain_and_registry : String
    @[JSON::Field(emit_null: false)]
    property security_origin : String
    @[JSON::Field(emit_null: false)]
    property security_origin_details : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property unreachable_url : String?
    @[JSON::Field(emit_null: false)]
    property ad_frame_status : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property secure_context_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property cross_origin_isolated_context_type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property gated_api_features : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property state : FrameState
    @[JSON::Field(emit_null: false)]
    property root : DOM::Node?
    @[JSON::Field(emit_null: false)]
    property nodes : Hash(DOM::NodeId, DOM::Node?)
    @[JSON::Field(emit_null: false)]
    property mutex : Mutex
  end

  # FrameState is the state of a Frame.
  @[Flags]
  enum FrameState : UInt16
    # Frame state flags
    FrameDOMContentEventFired = 1 << 15
    FrameLoadEventFired       = 1 << 14
    FrameAttached             = 1 << 13
    FrameNavigated            = 1 << 12
    FrameLoading              = 1 << 11
    FrameScheduledNavigation  = 1 << 10
  end

  # EmptyFrameID is the "non-existent" frame id.
  EMPTY_FRAME_ID = FrameId.new("")

  @[Experimental]
  struct FrameResource
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property last_modified : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property content_size : Float64?
    @[JSON::Field(emit_null: false)]
    property? failed : Bool?
    @[JSON::Field(emit_null: false)]
    property? canceled : Bool?
  end

  @[Experimental]
  struct FrameResourceTree
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property child_frames : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property resources : Array(Cdp::NodeType)
  end

  struct FrameTree
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property child_frames : Array(Cdp::NodeType)?
  end

  alias ScriptIdentifier = String

  alias TransitionType = String
  TransitionTypeLink             = "link"
  TransitionTypeTyped            = "typed"
  TransitionTypeAddressBar       = "address_bar"
  TransitionTypeAutoBookmark     = "auto_bookmark"
  TransitionTypeAutoSubframe     = "auto_subframe"
  TransitionTypeManualSubframe   = "manual_subframe"
  TransitionTypeGenerated        = "generated"
  TransitionTypeAutoToplevel     = "auto_toplevel"
  TransitionTypeFormSubmit       = "form_submit"
  TransitionTypeReload           = "reload"
  TransitionTypeKeyword          = "keyword"
  TransitionTypeKeywordGenerated = "keyword_generated"
  TransitionTypeOther            = "other"

  struct NavigationEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : Int64
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property user_typed_url : String
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property transition_type : Cdp::NodeType
  end

  @[Experimental]
  struct ScreencastFrameMetadata
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property offset_top : Float64
    @[JSON::Field(emit_null: false)]
    property page_scale_factor : Float64
    @[JSON::Field(emit_null: false)]
    property device_width : Float64
    @[JSON::Field(emit_null: false)]
    property device_height : Float64
    @[JSON::Field(emit_null: false)]
    property scroll_offset_x : Float64
    @[JSON::Field(emit_null: false)]
    property scroll_offset_y : Float64
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::NodeType?
  end

  alias DialogType = String
  DialogTypeAlert        = "alert"
  DialogTypeConfirm      = "confirm"
  DialogTypePrompt       = "prompt"
  DialogTypeBeforeunload = "beforeunload"

  struct AppManifestError
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property message : String
    @[JSON::Field(emit_null: false)]
    property critical : Int64
    @[JSON::Field(emit_null: false)]
    property line : Int64
    @[JSON::Field(emit_null: false)]
    property column : Int64
  end

  @[Experimental]
  struct AppManifestParsedProperties
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property scope : String
  end

  struct LayoutViewport
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property page_x : Int64
    @[JSON::Field(emit_null: false)]
    property page_y : Int64
    @[JSON::Field(emit_null: false)]
    property client_width : Int64
    @[JSON::Field(emit_null: false)]
    property client_height : Int64
  end

  struct VisualViewport
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property offset_x : Float64
    @[JSON::Field(emit_null: false)]
    property offset_y : Float64
    @[JSON::Field(emit_null: false)]
    property page_x : Float64
    @[JSON::Field(emit_null: false)]
    property page_y : Float64
    @[JSON::Field(emit_null: false)]
    property client_width : Float64
    @[JSON::Field(emit_null: false)]
    property client_height : Float64
    @[JSON::Field(emit_null: false)]
    property scale : Float64
    @[JSON::Field(emit_null: false)]
    property zoom : Float64?
  end

  struct Viewport
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property x : Float64
    @[JSON::Field(emit_null: false)]
    property y : Float64
    @[JSON::Field(emit_null: false)]
    property width : Float64
    @[JSON::Field(emit_null: false)]
    property height : Float64
    @[JSON::Field(emit_null: false)]
    property scale : Float64
  end

  @[Experimental]
  struct FontFamilies
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property standard : String?
    @[JSON::Field(emit_null: false)]
    property fixed : String?
    @[JSON::Field(emit_null: false)]
    property serif : String?
    @[JSON::Field(emit_null: false)]
    property sans_serif : String?
    @[JSON::Field(emit_null: false)]
    property cursive : String?
    @[JSON::Field(emit_null: false)]
    property fantasy : String?
    @[JSON::Field(emit_null: false)]
    property math : String?
  end

  @[Experimental]
  struct ScriptFontFamilies
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property script : String
    @[JSON::Field(emit_null: false)]
    property font_families : Cdp::NodeType
  end

  @[Experimental]
  struct FontSizes
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property standard : Int64?
    @[JSON::Field(emit_null: false)]
    property fixed : Int64?
  end

  @[Experimental]
  alias ClientNavigationReason = String
  ClientNavigationReasonAnchorClick            = "anchorClick"
  ClientNavigationReasonFormSubmissionGet      = "formSubmissionGet"
  ClientNavigationReasonFormSubmissionPost     = "formSubmissionPost"
  ClientNavigationReasonHttpHeaderRefresh      = "httpHeaderRefresh"
  ClientNavigationReasonInitialFrameNavigation = "initialFrameNavigation"
  ClientNavigationReasonMetaTagRefresh         = "metaTagRefresh"
  ClientNavigationReasonOther                  = "other"
  ClientNavigationReasonPageBlockInterstitial  = "pageBlockInterstitial"
  ClientNavigationReasonReload                 = "reload"
  ClientNavigationReasonScriptInitiated        = "scriptInitiated"

  @[Experimental]
  alias ClientNavigationDisposition = String
  ClientNavigationDispositionCurrentTab = "currentTab"
  ClientNavigationDispositionNewTab     = "newTab"
  ClientNavigationDispositionNewWindow  = "newWindow"
  ClientNavigationDispositionDownload   = "download"

  @[Experimental]
  struct InstallabilityErrorArgument
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property value : String
  end

  @[Experimental]
  struct InstallabilityError
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property error_id : String
    @[JSON::Field(emit_null: false)]
    property error_arguments : Array(Cdp::NodeType)
  end

  @[Experimental]
  alias ReferrerPolicy = String
  ReferrerPolicyNoReferrer                  = "noReferrer"
  ReferrerPolicyNoReferrerWhenDowngrade     = "noReferrerWhenDowngrade"
  ReferrerPolicyOrigin                      = "origin"
  ReferrerPolicyOriginWhenCrossOrigin       = "originWhenCrossOrigin"
  ReferrerPolicySameOrigin                  = "sameOrigin"
  ReferrerPolicyStrictOrigin                = "strictOrigin"
  ReferrerPolicyStrictOriginWhenCrossOrigin = "strictOriginWhenCrossOrigin"
  ReferrerPolicyUnsafeUrl                   = "unsafeUrl"

  @[Experimental]
  struct CompilationCacheParams
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property? eager : Bool?
  end

  @[Experimental]
  struct FileFilter
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property accepts : Array(String)?
  end

  @[Experimental]
  struct FileHandler
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property action : String
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property icons : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property accepts : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property launch_type : String
  end

  @[Experimental]
  struct ImageResource
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property sizes : String?
    @[JSON::Field(emit_null: false)]
    property type : String?
  end

  @[Experimental]
  struct LaunchHandler
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property client_mode : String
  end

  @[Experimental]
  struct ProtocolHandler
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property protocol : String
    @[JSON::Field(emit_null: false)]
    property url : String
  end

  @[Experimental]
  struct RelatedApplication
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property id : String?
    @[JSON::Field(emit_null: false)]
    property url : String
  end

  @[Experimental]
  struct ScopeExtension
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property origin : String
    @[JSON::Field(emit_null: false)]
    property? has_origin_wildcard : Bool
  end

  @[Experimental]
  struct Screenshot
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property image : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property form_factor : String
    @[JSON::Field(emit_null: false)]
    property label : String?
  end

  @[Experimental]
  struct ShareTarget
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property action : String
    @[JSON::Field(emit_null: false)]
    property method : String
    @[JSON::Field(emit_null: false)]
    property enctype : String
    @[JSON::Field(emit_null: false)]
    property title : String?
    @[JSON::Field(emit_null: false)]
    property text : String?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property files : Array(Cdp::NodeType)?
  end

  @[Experimental]
  struct Shortcut
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property url : String
  end

  @[Experimental]
  struct WebAppManifest
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property background_color : String?
    @[JSON::Field(emit_null: false)]
    property description : String?
    @[JSON::Field(emit_null: false)]
    property dir : String?
    @[JSON::Field(emit_null: false)]
    property display : String?
    @[JSON::Field(emit_null: false)]
    property display_overrides : Array(String)?
    @[JSON::Field(emit_null: false)]
    property file_handlers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property icons : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property id : String?
    @[JSON::Field(emit_null: false)]
    property lang : String?
    @[JSON::Field(emit_null: false)]
    property launch_handler : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property orientation : String?
    @[JSON::Field(emit_null: false)]
    property? prefer_related_applications : Bool?
    @[JSON::Field(emit_null: false)]
    property protocol_handlers : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property related_applications : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property scope : String?
    @[JSON::Field(emit_null: false)]
    property scope_extensions : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property screenshots : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property share_target : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property short_name : String?
    @[JSON::Field(emit_null: false)]
    property shortcuts : Array(Cdp::NodeType)?
    @[JSON::Field(emit_null: false)]
    property start_url : String?
    @[JSON::Field(emit_null: false)]
    property theme_color : String?
  end

  @[Experimental]
  alias NavigationType = String
  NavigationTypeNavigation              = "Navigation"
  NavigationTypeBackForwardCacheRestore = "BackForwardCacheRestore"

  @[Experimental]
  alias BackForwardCacheNotRestoredReason = String
  BackForwardCacheNotRestoredReasonNotPrimaryMainFrame                                      = "NotPrimaryMainFrame"
  BackForwardCacheNotRestoredReasonBackForwardCacheDisabled                                 = "BackForwardCacheDisabled"
  BackForwardCacheNotRestoredReasonRelatedActiveContentsExist                               = "RelatedActiveContentsExist"
  BackForwardCacheNotRestoredReasonHTTPStatusNotOK                                          = "HTTPStatusNotOK"
  BackForwardCacheNotRestoredReasonSchemeNotHTTPOrHTTPS                                     = "SchemeNotHTTPOrHTTPS"
  BackForwardCacheNotRestoredReasonLoading                                                  = "Loading"
  BackForwardCacheNotRestoredReasonWasGrantedMediaAccess                                    = "WasGrantedMediaAccess"
  BackForwardCacheNotRestoredReasonDisableForRenderFrameHostCalled                          = "DisableForRenderFrameHostCalled"
  BackForwardCacheNotRestoredReasonDomainNotAllowed                                         = "DomainNotAllowed"
  BackForwardCacheNotRestoredReasonHTTPMethodNotGET                                         = "HTTPMethodNotGET"
  BackForwardCacheNotRestoredReasonSubframeIsNavigating                                     = "SubframeIsNavigating"
  BackForwardCacheNotRestoredReasonTimeout                                                  = "Timeout"
  BackForwardCacheNotRestoredReasonCacheLimit                                               = "CacheLimit"
  BackForwardCacheNotRestoredReasonJavaScriptExecution                                      = "JavaScriptExecution"
  BackForwardCacheNotRestoredReasonRendererProcessKilled                                    = "RendererProcessKilled"
  BackForwardCacheNotRestoredReasonRendererProcessCrashed                                   = "RendererProcessCrashed"
  BackForwardCacheNotRestoredReasonSchedulerTrackedFeatureUsed                              = "SchedulerTrackedFeatureUsed"
  BackForwardCacheNotRestoredReasonConflictingBrowsingInstance                              = "ConflictingBrowsingInstance"
  BackForwardCacheNotRestoredReasonCacheFlushed                                             = "CacheFlushed"
  BackForwardCacheNotRestoredReasonServiceWorkerVersionActivation                           = "ServiceWorkerVersionActivation"
  BackForwardCacheNotRestoredReasonSessionRestored                                          = "SessionRestored"
  BackForwardCacheNotRestoredReasonServiceWorkerPostMessage                                 = "ServiceWorkerPostMessage"
  BackForwardCacheNotRestoredReasonEnteredBackForwardCacheBeforeServiceWorkerHostAdded      = "EnteredBackForwardCacheBeforeServiceWorkerHostAdded"
  BackForwardCacheNotRestoredReasonRenderFrameHostReusedSameSite                            = "RenderFrameHostReused_SameSite"
  BackForwardCacheNotRestoredReasonRenderFrameHostReusedCrossSite                           = "RenderFrameHostReused_CrossSite"
  BackForwardCacheNotRestoredReasonServiceWorkerClaim                                       = "ServiceWorkerClaim"
  BackForwardCacheNotRestoredReasonIgnoreEventAndEvict                                      = "IgnoreEventAndEvict"
  BackForwardCacheNotRestoredReasonHaveInnerContents                                        = "HaveInnerContents"
  BackForwardCacheNotRestoredReasonTimeoutPuttingInCache                                    = "TimeoutPuttingInCache"
  BackForwardCacheNotRestoredReasonBackForwardCacheDisabledByLowMemory                      = "BackForwardCacheDisabledByLowMemory"
  BackForwardCacheNotRestoredReasonBackForwardCacheDisabledByCommandLine                    = "BackForwardCacheDisabledByCommandLine"
  BackForwardCacheNotRestoredReasonNetworkRequestDatapipeDrainedAsBytesConsumer             = "NetworkRequestDatapipeDrainedAsBytesConsumer"
  BackForwardCacheNotRestoredReasonNetworkRequestRedirected                                 = "NetworkRequestRedirected"
  BackForwardCacheNotRestoredReasonNetworkRequestTimeout                                    = "NetworkRequestTimeout"
  BackForwardCacheNotRestoredReasonNetworkExceedsBufferLimit                                = "NetworkExceedsBufferLimit"
  BackForwardCacheNotRestoredReasonNavigationCancelledWhileRestoring                        = "NavigationCancelledWhileRestoring"
  BackForwardCacheNotRestoredReasonNotMostRecentNavigationEntry                             = "NotMostRecentNavigationEntry"
  BackForwardCacheNotRestoredReasonBackForwardCacheDisabledForPrerender                     = "BackForwardCacheDisabledForPrerender"
  BackForwardCacheNotRestoredReasonUserAgentOverrideDiffers                                 = "UserAgentOverrideDiffers"
  BackForwardCacheNotRestoredReasonForegroundCacheLimit                                     = "ForegroundCacheLimit"
  BackForwardCacheNotRestoredReasonBrowsingInstanceNotSwapped                               = "BrowsingInstanceNotSwapped"
  BackForwardCacheNotRestoredReasonBackForwardCacheDisabledForDelegate                      = "BackForwardCacheDisabledForDelegate"
  BackForwardCacheNotRestoredReasonUnloadHandlerExistsInMainFrame                           = "UnloadHandlerExistsInMainFrame"
  BackForwardCacheNotRestoredReasonUnloadHandlerExistsInSubFrame                            = "UnloadHandlerExistsInSubFrame"
  BackForwardCacheNotRestoredReasonServiceWorkerUnregistration                              = "ServiceWorkerUnregistration"
  BackForwardCacheNotRestoredReasonCacheControlNoStore                                      = "CacheControlNoStore"
  BackForwardCacheNotRestoredReasonCacheControlNoStoreCookieModified                        = "CacheControlNoStoreCookieModified"
  BackForwardCacheNotRestoredReasonCacheControlNoStoreHTTPOnlyCookieModified                = "CacheControlNoStoreHTTPOnlyCookieModified"
  BackForwardCacheNotRestoredReasonNoResponseHead                                           = "NoResponseHead"
  BackForwardCacheNotRestoredReasonUnknown                                                  = "Unknown"
  BackForwardCacheNotRestoredReasonActivationNavigationsDisallowedForBug1234857             = "ActivationNavigationsDisallowedForBug1234857"
  BackForwardCacheNotRestoredReasonErrorDocument                                            = "ErrorDocument"
  BackForwardCacheNotRestoredReasonFencedFramesEmbedder                                     = "FencedFramesEmbedder"
  BackForwardCacheNotRestoredReasonCookieDisabled                                           = "CookieDisabled"
  BackForwardCacheNotRestoredReasonHTTPAuthRequired                                         = "HTTPAuthRequired"
  BackForwardCacheNotRestoredReasonCookieFlushed                                            = "CookieFlushed"
  BackForwardCacheNotRestoredReasonBroadcastChannelOnMessage                                = "BroadcastChannelOnMessage"
  BackForwardCacheNotRestoredReasonWebViewSettingsChanged                                   = "WebViewSettingsChanged"
  BackForwardCacheNotRestoredReasonWebViewJavaScriptObjectChanged                           = "WebViewJavaScriptObjectChanged"
  BackForwardCacheNotRestoredReasonWebViewMessageListenerInjected                           = "WebViewMessageListenerInjected"
  BackForwardCacheNotRestoredReasonWebViewSafeBrowsingAllowlistChanged                      = "WebViewSafeBrowsingAllowlistChanged"
  BackForwardCacheNotRestoredReasonWebViewDocumentStartJavascriptChanged                    = "WebViewDocumentStartJavascriptChanged"
  BackForwardCacheNotRestoredReasonWebSocket                                                = "WebSocket"
  BackForwardCacheNotRestoredReasonWebTransport                                             = "WebTransport"
  BackForwardCacheNotRestoredReasonWebRTC                                                   = "WebRTC"
  BackForwardCacheNotRestoredReasonMainResourceHasCacheControlNoStore                       = "MainResourceHasCacheControlNoStore"
  BackForwardCacheNotRestoredReasonMainResourceHasCacheControlNoCache                       = "MainResourceHasCacheControlNoCache"
  BackForwardCacheNotRestoredReasonSubresourceHasCacheControlNoStore                        = "SubresourceHasCacheControlNoStore"
  BackForwardCacheNotRestoredReasonSubresourceHasCacheControlNoCache                        = "SubresourceHasCacheControlNoCache"
  BackForwardCacheNotRestoredReasonContainsPlugins                                          = "ContainsPlugins"
  BackForwardCacheNotRestoredReasonDocumentLoaded                                           = "DocumentLoaded"
  BackForwardCacheNotRestoredReasonOutstandingNetworkRequestOthers                          = "OutstandingNetworkRequestOthers"
  BackForwardCacheNotRestoredReasonRequestedMIDIPermission                                  = "RequestedMIDIPermission"
  BackForwardCacheNotRestoredReasonRequestedAudioCapturePermission                          = "RequestedAudioCapturePermission"
  BackForwardCacheNotRestoredReasonRequestedVideoCapturePermission                          = "RequestedVideoCapturePermission"
  BackForwardCacheNotRestoredReasonRequestedBackForwardCacheBlockedSensors                  = "RequestedBackForwardCacheBlockedSensors"
  BackForwardCacheNotRestoredReasonRequestedBackgroundWorkPermission                        = "RequestedBackgroundWorkPermission"
  BackForwardCacheNotRestoredReasonBroadcastChannel                                         = "BroadcastChannel"
  BackForwardCacheNotRestoredReasonWebXR                                                    = "WebXR"
  BackForwardCacheNotRestoredReasonSharedWorker                                             = "SharedWorker"
  BackForwardCacheNotRestoredReasonSharedWorkerMessage                                      = "SharedWorkerMessage"
  BackForwardCacheNotRestoredReasonSharedWorkerWithNoActiveClient                           = "SharedWorkerWithNoActiveClient"
  BackForwardCacheNotRestoredReasonWebLocks                                                 = "WebLocks"
  BackForwardCacheNotRestoredReasonWebLocksContention                                       = "WebLocksContention"
  BackForwardCacheNotRestoredReasonWebHID                                                   = "WebHID"
  BackForwardCacheNotRestoredReasonWebBluetooth                                             = "WebBluetooth"
  BackForwardCacheNotRestoredReasonWebShare                                                 = "WebShare"
  BackForwardCacheNotRestoredReasonRequestedStorageAccessGrant                              = "RequestedStorageAccessGrant"
  BackForwardCacheNotRestoredReasonWebNfc                                                   = "WebNfc"
  BackForwardCacheNotRestoredReasonOutstandingNetworkRequestFetch                           = "OutstandingNetworkRequestFetch"
  BackForwardCacheNotRestoredReasonOutstandingNetworkRequestXHR                             = "OutstandingNetworkRequestXHR"
  BackForwardCacheNotRestoredReasonAppBanner                                                = "AppBanner"
  BackForwardCacheNotRestoredReasonPrinting                                                 = "Printing"
  BackForwardCacheNotRestoredReasonWebDatabase                                              = "WebDatabase"
  BackForwardCacheNotRestoredReasonPictureInPicture                                         = "PictureInPicture"
  BackForwardCacheNotRestoredReasonSpeechRecognizer                                         = "SpeechRecognizer"
  BackForwardCacheNotRestoredReasonIdleManager                                              = "IdleManager"
  BackForwardCacheNotRestoredReasonPaymentManager                                           = "PaymentManager"
  BackForwardCacheNotRestoredReasonSpeechSynthesis                                          = "SpeechSynthesis"
  BackForwardCacheNotRestoredReasonKeyboardLock                                             = "KeyboardLock"
  BackForwardCacheNotRestoredReasonWebOTPService                                            = "WebOTPService"
  BackForwardCacheNotRestoredReasonOutstandingNetworkRequestDirectSocket                    = "OutstandingNetworkRequestDirectSocket"
  BackForwardCacheNotRestoredReasonInjectedJavascript                                       = "InjectedJavascript"
  BackForwardCacheNotRestoredReasonInjectedStyleSheet                                       = "InjectedStyleSheet"
  BackForwardCacheNotRestoredReasonKeepaliveRequest                                         = "KeepaliveRequest"
  BackForwardCacheNotRestoredReasonIndexedDBEvent                                           = "IndexedDBEvent"
  BackForwardCacheNotRestoredReasonDummy                                                    = "Dummy"
  BackForwardCacheNotRestoredReasonJsNetworkRequestReceivedCacheControlNoStoreResource      = "JsNetworkRequestReceivedCacheControlNoStoreResource"
  BackForwardCacheNotRestoredReasonWebRTCUsedWithCCNS                                       = "WebRTCUsedWithCCNS"
  BackForwardCacheNotRestoredReasonWebTransportUsedWithCCNS                                 = "WebTransportUsedWithCCNS"
  BackForwardCacheNotRestoredReasonWebSocketUsedWithCCNS                                    = "WebSocketUsedWithCCNS"
  BackForwardCacheNotRestoredReasonSmartCard                                                = "SmartCard"
  BackForwardCacheNotRestoredReasonLiveMediaStreamTrack                                     = "LiveMediaStreamTrack"
  BackForwardCacheNotRestoredReasonUnloadHandler                                            = "UnloadHandler"
  BackForwardCacheNotRestoredReasonParserAborted                                            = "ParserAborted"
  BackForwardCacheNotRestoredReasonContentSecurityHandler                                   = "ContentSecurityHandler"
  BackForwardCacheNotRestoredReasonContentWebAuthenticationAPI                              = "ContentWebAuthenticationAPI"
  BackForwardCacheNotRestoredReasonContentFileChooser                                       = "ContentFileChooser"
  BackForwardCacheNotRestoredReasonContentSerial                                            = "ContentSerial"
  BackForwardCacheNotRestoredReasonContentFileSystemAccess                                  = "ContentFileSystemAccess"
  BackForwardCacheNotRestoredReasonContentMediaDevicesDispatcherHost                        = "ContentMediaDevicesDispatcherHost"
  BackForwardCacheNotRestoredReasonContentWebBluetooth                                      = "ContentWebBluetooth"
  BackForwardCacheNotRestoredReasonContentWebUSB                                            = "ContentWebUSB"
  BackForwardCacheNotRestoredReasonContentMediaSessionService                               = "ContentMediaSessionService"
  BackForwardCacheNotRestoredReasonContentScreenReader                                      = "ContentScreenReader"
  BackForwardCacheNotRestoredReasonContentDiscarded                                         = "ContentDiscarded"
  BackForwardCacheNotRestoredReasonEmbedderPopupBlockerTabHelper                            = "EmbedderPopupBlockerTabHelper"
  BackForwardCacheNotRestoredReasonEmbedderSafeBrowsingTriggeredPopupBlocker                = "EmbedderSafeBrowsingTriggeredPopupBlocker"
  BackForwardCacheNotRestoredReasonEmbedderSafeBrowsingThreatDetails                        = "EmbedderSafeBrowsingThreatDetails"
  BackForwardCacheNotRestoredReasonEmbedderAppBannerManager                                 = "EmbedderAppBannerManager"
  BackForwardCacheNotRestoredReasonEmbedderDomDistillerViewerSource                         = "EmbedderDomDistillerViewerSource"
  BackForwardCacheNotRestoredReasonEmbedderDomDistillerSelfDeletingRequestDelegate          = "EmbedderDomDistillerSelfDeletingRequestDelegate"
  BackForwardCacheNotRestoredReasonEmbedderOomInterventionTabHelper                         = "EmbedderOomInterventionTabHelper"
  BackForwardCacheNotRestoredReasonEmbedderOfflinePage                                      = "EmbedderOfflinePage"
  BackForwardCacheNotRestoredReasonEmbedderChromePasswordManagerClientBindCredentialManager = "EmbedderChromePasswordManagerClientBindCredentialManager"
  BackForwardCacheNotRestoredReasonEmbedderPermissionRequestManager                         = "EmbedderPermissionRequestManager"
  BackForwardCacheNotRestoredReasonEmbedderModalDialog                                      = "EmbedderModalDialog"
  BackForwardCacheNotRestoredReasonEmbedderExtensions                                       = "EmbedderExtensions"
  BackForwardCacheNotRestoredReasonEmbedderExtensionMessaging                               = "EmbedderExtensionMessaging"
  BackForwardCacheNotRestoredReasonEmbedderExtensionMessagingForOpenPort                    = "EmbedderExtensionMessagingForOpenPort"
  BackForwardCacheNotRestoredReasonEmbedderExtensionSentMessageToCachedFrame                = "EmbedderExtensionSentMessageToCachedFrame"
  BackForwardCacheNotRestoredReasonRequestedByWebViewClient                                 = "RequestedByWebViewClient"
  BackForwardCacheNotRestoredReasonPostMessageByWebViewClient                               = "PostMessageByWebViewClient"
  BackForwardCacheNotRestoredReasonCacheControlNoStoreDeviceBoundSessionTerminated          = "CacheControlNoStoreDeviceBoundSessionTerminated"
  BackForwardCacheNotRestoredReasonCacheLimitPrunedOnModerateMemoryPressure                 = "CacheLimitPrunedOnModerateMemoryPressure"
  BackForwardCacheNotRestoredReasonCacheLimitPrunedOnCriticalMemoryPressure                 = "CacheLimitPrunedOnCriticalMemoryPressure"

  @[Experimental]
  alias BackForwardCacheNotRestoredReasonType = String
  BackForwardCacheNotRestoredReasonTypeSupportPending    = "SupportPending"
  BackForwardCacheNotRestoredReasonTypePageSupportNeeded = "PageSupportNeeded"
  BackForwardCacheNotRestoredReasonTypeCircumstantial    = "Circumstantial"

  @[Experimental]
  struct BackForwardCacheBlockingDetails
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property function : String?
    @[JSON::Field(emit_null: false)]
    property line_number : Int64
    @[JSON::Field(emit_null: false)]
    property column_number : Int64
  end

  @[Experimental]
  struct BackForwardCacheNotRestoredExplanation
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property type : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property reason : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property context : String?
    @[JSON::Field(emit_null: false)]
    property details : Array(Cdp::NodeType)?
  end

  @[Experimental]
  struct BackForwardCacheNotRestoredExplanationTree
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property explanations : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property children : Array(Cdp::NodeType)
  end

  alias FileChooserOpenedMode = String
  FileChooserOpenedModeSelectSingle   = "selectSingle"
  FileChooserOpenedModeSelectMultiple = "selectMultiple"

  alias FrameDetachedReason = String
  FrameDetachedReasonRemove = "remove"
  FrameDetachedReasonSwap   = "swap"

  alias FrameStartedNavigatingNavigationType = String
  FrameStartedNavigatingNavigationTypeReload                   = "reload"
  FrameStartedNavigatingNavigationTypeReloadBypassingCache     = "reloadBypassingCache"
  FrameStartedNavigatingNavigationTypeRestore                  = "restore"
  FrameStartedNavigatingNavigationTypeRestoreWithPost          = "restoreWithPost"
  FrameStartedNavigatingNavigationTypeHistorySameDocument      = "historySameDocument"
  FrameStartedNavigatingNavigationTypeHistoryDifferentDocument = "historyDifferentDocument"
  FrameStartedNavigatingNavigationTypeSameDocument             = "sameDocument"
  FrameStartedNavigatingNavigationTypeDifferentDocument        = "differentDocument"

  alias DownloadProgressState = String
  DownloadProgressStateInProgress = "inProgress"
  DownloadProgressStateCompleted  = "completed"
  DownloadProgressStateCanceled   = "canceled"

  alias NavigatedWithinDocumentNavigationType = String
  NavigatedWithinDocumentNavigationTypeFragment   = "fragment"
  NavigatedWithinDocumentNavigationTypeHistoryApi = "historyApi"
  NavigatedWithinDocumentNavigationTypeOther      = "other"

  alias CaptureScreenshotFormat = String
  CaptureScreenshotFormatJpeg = "jpeg"
  CaptureScreenshotFormatPng  = "png"
  CaptureScreenshotFormatWebp = "webp"

  alias CaptureSnapshotFormat = String
  CaptureSnapshotFormatMhtml = "mhtml"

  alias PrintToPDFTransferMode = String
  PrintToPDFTransferModeReturnAsBase64 = "ReturnAsBase64"
  PrintToPDFTransferModeReturnAsStream = "ReturnAsStream"

  alias SetDownloadBehaviorBehavior = String
  SetDownloadBehaviorBehaviorDeny    = "deny"
  SetDownloadBehaviorBehaviorAllow   = "allow"
  SetDownloadBehaviorBehaviorDefault = "default"

  alias ScreencastFormat = String
  ScreencastFormatJpeg = "jpeg"
  ScreencastFormatPng  = "png"

  alias SetWebLifecycleStateState = String
  SetWebLifecycleStateStateFrozen = "frozen"
  SetWebLifecycleStateStateActive = "active"

  alias SetSPCTransactionModeMode = String
  SetSPCTransactionModeModeNone                       = "none"
  SetSPCTransactionModeModeAutoAccept                 = "autoAccept"
  SetSPCTransactionModeModeAutoChooseToAuthAnotherWay = "autoChooseToAuthAnotherWay"
  SetSPCTransactionModeModeAutoReject                 = "autoReject"
  SetSPCTransactionModeModeAutoOptOut                 = "autoOptOut"

  alias SetRPHRegistrationModeMode = String
  SetRPHRegistrationModeModeNone       = "none"
  SetRPHRegistrationModeModeAutoAccept = "autoAccept"
  SetRPHRegistrationModeModeAutoReject = "autoReject"
end
