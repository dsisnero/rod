require "../page/page"
require "json"
require "time"
require "../runtime/runtime"
require "../dom/dom"
require "../network/network"
require "../io/io"

module Cdp::Page
  alias FrameId = String

  @[Experimental]
  alias AdFrameType = String

  @[Experimental]
  alias AdFrameExplanation = String

  @[Experimental]
  struct AdFrameStatus
    include JSON::Serializable

    property ad_frame_type : AdFrameType
    @[JSON::Field(emit_null: false)]
    property explanations : Array(AdFrameExplanation)?
  end

  @[Experimental]
  struct AdScriptId
    include JSON::Serializable

    property script_id : Cdp::Runtime::ScriptId
    property debugger_id : Cdp::Runtime::UniqueDebuggerId
  end

  @[Experimental]
  struct AdScriptAncestry
    include JSON::Serializable

    property ancestry_chain : Array(AdScriptId)
    @[JSON::Field(emit_null: false)]
    property root_script_filterlist_rule : String?
  end

  @[Experimental]
  alias SecureContextType = String

  @[Experimental]
  alias CrossOriginIsolatedContextType = String

  @[Experimental]
  alias GatedAPIFeatures = String

  @[Experimental]
  alias PermissionsPolicyFeature = String

  @[Experimental]
  alias PermissionsPolicyBlockReason = String

  @[Experimental]
  struct PermissionsPolicyBlockLocator
    include JSON::Serializable

    property frame_id : FrameId
    property block_reason : PermissionsPolicyBlockReason
  end

  @[Experimental]
  struct PermissionsPolicyFeatureState
    include JSON::Serializable

    property feature : PermissionsPolicyFeature
    property allowed : Bool
    @[JSON::Field(emit_null: false)]
    property locator : PermissionsPolicyBlockLocator?
  end

  @[Experimental]
  alias OriginTrialTokenStatus = String

  @[Experimental]
  alias OriginTrialStatus = String

  @[Experimental]
  alias OriginTrialUsageRestriction = String

  @[Experimental]
  struct OriginTrialToken
    include JSON::Serializable

    property origin : String
    property match_sub_domains : Bool
    property trial_name : String
    property expiry_time : Cdp::Network::TimeSinceEpoch
    property is_third_party : Bool
    property usage_restriction : OriginTrialUsageRestriction
  end

  @[Experimental]
  struct OriginTrialTokenWithStatus
    include JSON::Serializable

    property raw_token_text : String
    @[JSON::Field(emit_null: false)]
    property parsed_token : OriginTrialToken?
    property status : OriginTrialTokenStatus
  end

  @[Experimental]
  struct OriginTrial
    include JSON::Serializable

    property trial_name : String
    property status : OriginTrialStatus
    property tokens_with_status : Array(OriginTrialTokenWithStatus)
  end

  @[Experimental]
  struct SecurityOriginDetails
    include JSON::Serializable

    property is_localhost : Bool
  end

  struct Frame
    include JSON::Serializable

    property id : FrameId
    @[JSON::Field(emit_null: false)]
    property parent_id : FrameId?
    property loader_id : Cdp::Network::LoaderId
    @[JSON::Field(emit_null: false)]
    property name : String?
    property url : String
    @[JSON::Field(emit_null: false)]
    property url_fragment : String?
    property domain_and_registry : String
    property security_origin : String
    @[JSON::Field(emit_null: false)]
    property security_origin_details : SecurityOriginDetails?
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property unreachable_url : String?
    @[JSON::Field(emit_null: false)]
    property ad_frame_status : AdFrameStatus?
    property secure_context_type : SecureContextType
    property cross_origin_isolated_context_type : CrossOriginIsolatedContextType
    property gated_api_features : Array(GatedAPIFeatures)
    property state : FrameState
    property root : Node?
    property nodes : Hash(NodeId, Node?)
    property mutex : Mutex
  end

  @[Experimental]
  struct FrameResource
    include JSON::Serializable

    property url : String
    property type : Cdp::Network::ResourceType
    property mime_type : String
    @[JSON::Field(emit_null: false)]
    property last_modified : Cdp::Network::TimeSinceEpoch?
    @[JSON::Field(emit_null: false)]
    property content_size : Float64?
    @[JSON::Field(emit_null: false)]
    property failed : Bool?
    @[JSON::Field(emit_null: false)]
    property canceled : Bool?
  end

  @[Experimental]
  struct FrameResourceTree
    include JSON::Serializable

    property frame : Frame
    @[JSON::Field(emit_null: false)]
    property child_frames : Array(FrameResourceTree)?
    property resources : Array(FrameResource)
  end

  struct FrameTree
    include JSON::Serializable

    property frame : Frame
    @[JSON::Field(emit_null: false)]
    property child_frames : Array(FrameTree)?
  end

  alias ScriptIdentifier = String

  alias TransitionType = String

  struct NavigationEntry
    include JSON::Serializable

    property id : Int64
    property url : String
    property user_typed_url : String
    property title : String
    property transition_type : TransitionType
  end

  @[Experimental]
  struct ScreencastFrameMetadata
    include JSON::Serializable

    property offset_top : Float64
    property page_scale_factor : Float64
    property device_width : Float64
    property device_height : Float64
    property scroll_offset_x : Float64
    property scroll_offset_y : Float64
    @[JSON::Field(emit_null: false)]
    property timestamp : Cdp::Network::TimeSinceEpoch?
  end

  alias DialogType = String

  struct AppManifestError
    include JSON::Serializable

    property message : String
    property critical : Int64
    property line : Int64
    property column : Int64
  end

  @[Experimental]
  struct AppManifestParsedProperties
    include JSON::Serializable

    property scope : String
  end

  struct LayoutViewport
    include JSON::Serializable

    property page_x : Int64
    property page_y : Int64
    property client_width : Int64
    property client_height : Int64
  end

  struct VisualViewport
    include JSON::Serializable

    property offset_x : Float64
    property offset_y : Float64
    property page_x : Float64
    property page_y : Float64
    property client_width : Float64
    property client_height : Float64
    property scale : Float64
    @[JSON::Field(emit_null: false)]
    property zoom : Float64?
  end

  struct Viewport
    include JSON::Serializable

    property x : Float64
    property y : Float64
    property width : Float64
    property height : Float64
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

    property script : String
    property font_families : FontFamilies
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

  @[Experimental]
  alias ClientNavigationDisposition = String

  @[Experimental]
  struct InstallabilityErrorArgument
    include JSON::Serializable

    property name : String
    property value : String
  end

  @[Experimental]
  struct InstallabilityError
    include JSON::Serializable

    property error_id : String
    property error_arguments : Array(InstallabilityErrorArgument)
  end

  @[Experimental]
  alias ReferrerPolicy = String

  @[Experimental]
  struct CompilationCacheParams
    include JSON::Serializable

    property url : String
    @[JSON::Field(emit_null: false)]
    property eager : Bool?
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

    property action : String
    property name : String
    @[JSON::Field(emit_null: false)]
    property icons : Array(ImageResource)?
    @[JSON::Field(emit_null: false)]
    property accepts : Array(FileFilter)?
    property launch_type : String
  end

  @[Experimental]
  struct ImageResource
    include JSON::Serializable

    property url : String
    @[JSON::Field(emit_null: false)]
    property sizes : String?
    @[JSON::Field(emit_null: false)]
    property type : String?
  end

  @[Experimental]
  struct LaunchHandler
    include JSON::Serializable

    property client_mode : String
  end

  @[Experimental]
  struct ProtocolHandler
    include JSON::Serializable

    property protocol : String
    property url : String
  end

  @[Experimental]
  struct RelatedApplication
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property id : String?
    property url : String
  end

  @[Experimental]
  struct ScopeExtension
    include JSON::Serializable

    property origin : String
    property has_origin_wildcard : Bool
  end

  @[Experimental]
  struct Screenshot
    include JSON::Serializable

    property image : ImageResource
    property form_factor : String
    @[JSON::Field(emit_null: false)]
    property label : String?
  end

  @[Experimental]
  struct ShareTarget
    include JSON::Serializable

    property action : String
    property method : String
    property enctype : String
    @[JSON::Field(emit_null: false)]
    property title : String?
    @[JSON::Field(emit_null: false)]
    property text : String?
    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property files : Array(FileFilter)?
  end

  @[Experimental]
  struct Shortcut
    include JSON::Serializable

    property name : String
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
    property file_handlers : Array(FileHandler)?
    @[JSON::Field(emit_null: false)]
    property icons : Array(ImageResource)?
    @[JSON::Field(emit_null: false)]
    property id : String?
    @[JSON::Field(emit_null: false)]
    property lang : String?
    @[JSON::Field(emit_null: false)]
    property launch_handler : LaunchHandler?
    @[JSON::Field(emit_null: false)]
    property name : String?
    @[JSON::Field(emit_null: false)]
    property orientation : String?
    @[JSON::Field(emit_null: false)]
    property prefer_related_applications : Bool?
    @[JSON::Field(emit_null: false)]
    property protocol_handlers : Array(ProtocolHandler)?
    @[JSON::Field(emit_null: false)]
    property related_applications : Array(RelatedApplication)?
    @[JSON::Field(emit_null: false)]
    property scope : String?
    @[JSON::Field(emit_null: false)]
    property scope_extensions : Array(ScopeExtension)?
    @[JSON::Field(emit_null: false)]
    property screenshots : Array(Screenshot)?
    @[JSON::Field(emit_null: false)]
    property share_target : ShareTarget?
    @[JSON::Field(emit_null: false)]
    property short_name : String?
    @[JSON::Field(emit_null: false)]
    property shortcuts : Array(Shortcut)?
    @[JSON::Field(emit_null: false)]
    property start_url : String?
    @[JSON::Field(emit_null: false)]
    property theme_color : String?
  end

  @[Experimental]
  alias NavigationType = String

  @[Experimental]
  alias BackForwardCacheNotRestoredReason = String

  @[Experimental]
  alias BackForwardCacheNotRestoredReasonType = String

  @[Experimental]
  struct BackForwardCacheBlockingDetails
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property url : String?
    @[JSON::Field(emit_null: false)]
    property function : String?
    property line_number : Int64
    property column_number : Int64
  end

  @[Experimental]
  struct BackForwardCacheNotRestoredExplanation
    include JSON::Serializable

    property type : BackForwardCacheNotRestoredReasonType
    property reason : BackForwardCacheNotRestoredReason
    @[JSON::Field(emit_null: false)]
    property context : String?
    @[JSON::Field(emit_null: false)]
    property details : Array(BackForwardCacheBlockingDetails)?
  end

  @[Experimental]
  struct BackForwardCacheNotRestoredExplanationTree
    include JSON::Serializable

    property url : String
    property explanations : Array(BackForwardCacheNotRestoredExplanation)
    property children : Array(BackForwardCacheNotRestoredExplanationTree)
  end

  alias FileChooserOpenedMode = String

  alias FrameDetachedReason = String

  alias FrameStartedNavigatingNavigationType = String

  alias NavigatedWithinDocumentNavigationType = String

  alias CaptureScreenshotFormat = String

  alias CaptureSnapshotFormat = String

  alias PrintToPDFTransferMode = String

  alias SetDownloadBehaviorBehavior = String

  alias ScreencastFormat = String

  alias SetWebLifecycleStateState = String

  alias SetSPCTransactionModeMode = String

  alias SetRPHRegistrationModeMode = String
end
