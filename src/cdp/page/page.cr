require "json"
require "../cdp"
require "../runtime/runtime"
require "../dom/dom"
require "../network/network"
require "../io/io"
require "./types"

# Actions and events related to the inspected page belong to the page domain.
module Cdp::Page
  # Commands
  struct AddScriptToEvaluateOnNewDocument
    include JSON::Serializable
    include Cdp::Request

    property source : String
    @[JSON::Field(emit_null: false)]
    property world_name : String?
    @[JSON::Field(emit_null: false)]
    property include_command_line_api : Bool?
    @[JSON::Field(emit_null: false)]
    property run_immediately : Bool?

    def initialize(@source : String, @world_name : String?, @include_command_line_api : Bool?, @run_immediately : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.addScriptToEvaluateOnNewDocument"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AddScriptToEvaluateOnNewDocumentResult
      res = AddScriptToEvaluateOnNewDocumentResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct AddScriptToEvaluateOnNewDocumentResult
    include JSON::Serializable

    property identifier : ScriptIdentifier

    def initialize(@identifier : ScriptIdentifier)
    end
  end

  struct BringToFront
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.bringToFront"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CaptureScreenshot
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property format : CaptureScreenshotFormat?
    @[JSON::Field(emit_null: false)]
    property quality : Int64?
    @[JSON::Field(emit_null: false)]
    property clip : Viewport?
    @[JSON::Field(emit_null: false)]
    property from_surface : Bool?
    @[JSON::Field(emit_null: false)]
    property capture_beyond_viewport : Bool?
    @[JSON::Field(emit_null: false)]
    property optimize_for_speed : Bool?

    def initialize(@format : CaptureScreenshotFormat?, @quality : Int64?, @clip : Viewport?, @from_surface : Bool?, @capture_beyond_viewport : Bool?, @optimize_for_speed : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.captureScreenshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CaptureScreenshotResult
      res = CaptureScreenshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CaptureScreenshotResult
    include JSON::Serializable

    property data : String

    def initialize(@data : String)
    end
  end

  @[Experimental]
  struct CaptureSnapshot
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property format : CaptureSnapshotFormat?

    def initialize(@format : CaptureSnapshotFormat?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.captureSnapshot"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CaptureSnapshotResult
      res = CaptureSnapshotResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct CaptureSnapshotResult
    include JSON::Serializable

    property data : String

    def initialize(@data : String)
    end
  end

  struct CreateIsolatedWorld
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property world_name : String?
    @[JSON::Field(emit_null: false)]
    property grant_univeral_access : Bool?

    def initialize(@frame_id : FrameId, @world_name : String?, @grant_univeral_access : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.createIsolatedWorld"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CreateIsolatedWorldResult
      res = CreateIsolatedWorldResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CreateIsolatedWorldResult
    include JSON::Serializable

    property execution_context_id : Cdp::Runtime::ExecutionContextId

    def initialize(@execution_context_id : Cdp::Runtime::ExecutionContextId)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.disable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property enable_file_chooser_opened_event : Bool?

    def initialize(@enable_file_chooser_opened_event : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.enable"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetAppManifest
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property manifest_id : String?

    def initialize(@manifest_id : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getAppManifest"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAppManifestResult
      res = GetAppManifestResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetAppManifestResult
    include JSON::Serializable

    property url : String
    property errors : Array(AppManifestError)
    @[JSON::Field(emit_null: false)]
    property data : String?
    property manifest : WebAppManifest

    def initialize(@url : String, @errors : Array(AppManifestError), @data : String?, @manifest : WebAppManifest)
    end
  end

  @[Experimental]
  struct GetInstallabilityErrors
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getInstallabilityErrors"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetInstallabilityErrorsResult
      res = GetInstallabilityErrorsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetInstallabilityErrorsResult
    include JSON::Serializable

    property installability_errors : Array(InstallabilityError)

    def initialize(@installability_errors : Array(InstallabilityError))
    end
  end

  @[Experimental]
  struct GetAppId
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getAppId"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAppIdResult
      res = GetAppIdResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAppIdResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property app_id : String?
    @[JSON::Field(emit_null: false)]
    property recommended_id : String?

    def initialize(@app_id : String?, @recommended_id : String?)
    end
  end

  @[Experimental]
  struct GetAdScriptAncestry
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId

    def initialize(@frame_id : FrameId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getAdScriptAncestry"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAdScriptAncestryResult
      res = GetAdScriptAncestryResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAdScriptAncestryResult
    include JSON::Serializable

    @[JSON::Field(emit_null: false)]
    property ad_script_ancestry : AdScriptAncestry?

    def initialize(@ad_script_ancestry : AdScriptAncestry?)
    end
  end

  struct GetFrameTree
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getFrameTree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetFrameTreeResult
      res = GetFrameTreeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetFrameTreeResult
    include JSON::Serializable

    property frame_tree : FrameTree

    def initialize(@frame_tree : FrameTree)
    end
  end

  struct GetLayoutMetrics
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getLayoutMetrics"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetLayoutMetricsResult
      res = GetLayoutMetricsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetLayoutMetricsResult
    include JSON::Serializable

    property css_layout_viewport : LayoutViewport
    property css_visual_viewport : VisualViewport
    property css_content_size : Cdp::DOM::Rect

    def initialize(@css_layout_viewport : LayoutViewport, @css_visual_viewport : VisualViewport, @css_content_size : Cdp::DOM::Rect)
    end
  end

  struct GetNavigationHistory
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getNavigationHistory"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetNavigationHistoryResult
      res = GetNavigationHistoryResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetNavigationHistoryResult
    include JSON::Serializable

    property current_index : Int64
    property entries : Array(NavigationEntry)

    def initialize(@current_index : Int64, @entries : Array(NavigationEntry))
    end
  end

  struct ResetNavigationHistory
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.resetNavigationHistory"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetResourceContent
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId
    property url : String

    def initialize(@frame_id : FrameId, @url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getResourceContent"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetResourceContentResult
      res = GetResourceContentResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetResourceContentResult
    include JSON::Serializable

    property content : String
    property base64_encoded : Bool

    def initialize(@content : String, @base64_encoded : Bool)
    end
  end

  @[Experimental]
  struct GetResourceTree
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getResourceTree"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetResourceTreeResult
      res = GetResourceTreeResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetResourceTreeResult
    include JSON::Serializable

    property frame_tree : FrameResourceTree

    def initialize(@frame_tree : FrameResourceTree)
    end
  end

  struct HandleJavaScriptDialog
    include JSON::Serializable
    include Cdp::Request

    property accept : Bool
    @[JSON::Field(emit_null: false)]
    property prompt_text : String?

    def initialize(@accept : Bool, @prompt_text : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.handleJavaScriptDialog"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Navigate
    include JSON::Serializable
    include Cdp::Request

    property url : String
    @[JSON::Field(emit_null: false)]
    property referrer : String?
    @[JSON::Field(emit_null: false)]
    property transition_type : TransitionType?
    @[JSON::Field(emit_null: false)]
    property frame_id : FrameId?
    @[JSON::Field(emit_null: false)]
    property referrer_policy : ReferrerPolicy?

    def initialize(@url : String, @referrer : String?, @transition_type : TransitionType?, @frame_id : FrameId?, @referrer_policy : ReferrerPolicy?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.navigate"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : NavigateResult
      res = NavigateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct NavigateResult
    include JSON::Serializable

    property frame_id : FrameId
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::Network::LoaderId?
    @[JSON::Field(emit_null: false)]
    property error_text : String?
    @[JSON::Field(emit_null: false)]
    property is_download : Bool?

    def initialize(@frame_id : FrameId, @loader_id : Cdp::Network::LoaderId?, @error_text : String?, @is_download : Bool?)
    end
  end

  struct NavigateToHistoryEntry
    include JSON::Serializable
    include Cdp::Request

    property entry_id : Int64

    def initialize(@entry_id : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.navigateToHistoryEntry"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct PrintToPDF
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property landscape : Bool?
    @[JSON::Field(emit_null: false)]
    property display_header_footer : Bool?
    @[JSON::Field(emit_null: false)]
    property print_background : Bool?
    @[JSON::Field(emit_null: false)]
    property scale : Float64?
    @[JSON::Field(emit_null: false)]
    property paper_width : Float64?
    @[JSON::Field(emit_null: false)]
    property paper_height : Float64?
    @[JSON::Field(emit_null: false)]
    property margin_top : Float64?
    @[JSON::Field(emit_null: false)]
    property margin_bottom : Float64?
    @[JSON::Field(emit_null: false)]
    property margin_left : Float64?
    @[JSON::Field(emit_null: false)]
    property margin_right : Float64?
    @[JSON::Field(emit_null: false)]
    property page_ranges : String?
    @[JSON::Field(emit_null: false)]
    property header_template : String?
    @[JSON::Field(emit_null: false)]
    property footer_template : String?
    @[JSON::Field(emit_null: false)]
    property prefer_css_page_size : Bool?
    @[JSON::Field(emit_null: false)]
    property transfer_mode : PrintToPDFTransferMode?
    @[JSON::Field(emit_null: false)]
    property generate_tagged_pdf : Bool?
    @[JSON::Field(emit_null: false)]
    property generate_document_outline : Bool?

    def initialize(@landscape : Bool?, @display_header_footer : Bool?, @print_background : Bool?, @scale : Float64?, @paper_width : Float64?, @paper_height : Float64?, @margin_top : Float64?, @margin_bottom : Float64?, @margin_left : Float64?, @margin_right : Float64?, @page_ranges : String?, @header_template : String?, @footer_template : String?, @prefer_css_page_size : Bool?, @transfer_mode : PrintToPDFTransferMode?, @generate_tagged_pdf : Bool?, @generate_document_outline : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.printToPDF"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : PrintToPDFResult
      res = PrintToPDFResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct PrintToPDFResult
    include JSON::Serializable

    property data : String
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::IO::StreamHandle?

    def initialize(@data : String, @stream : Cdp::IO::StreamHandle?)
    end
  end

  struct Reload
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property ignore_cache : Bool?
    @[JSON::Field(emit_null: false)]
    property script_to_evaluate_on_load : String?
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::Network::LoaderId?

    def initialize(@ignore_cache : Bool?, @script_to_evaluate_on_load : String?, @loader_id : Cdp::Network::LoaderId?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.reload"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct RemoveScriptToEvaluateOnNewDocument
    include JSON::Serializable
    include Cdp::Request

    property identifier : ScriptIdentifier

    def initialize(@identifier : ScriptIdentifier)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.removeScriptToEvaluateOnNewDocument"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ScreencastFrameAck
    include JSON::Serializable
    include Cdp::Request

    property session_id : Int64

    def initialize(@session_id : Int64)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.screencastFrameAck"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SearchInResource
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId
    property url : String
    property query : String
    @[JSON::Field(emit_null: false)]
    property case_sensitive : Bool?
    @[JSON::Field(emit_null: false)]
    property is_regex : Bool?

    def initialize(@frame_id : FrameId, @url : String, @query : String, @case_sensitive : Bool?, @is_regex : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.searchInResource"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : SearchInResourceResult
      res = SearchInResourceResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SearchInResourceResult
    include JSON::Serializable

    property result : Array(Cdp::Debugger::SearchMatch)

    def initialize(@result : Array(Cdp::Debugger::SearchMatch))
    end
  end

  @[Experimental]
  struct SetAdBlockingEnabled
    include JSON::Serializable
    include Cdp::Request

    property enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setAdBlockingEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetBypassCSP
    include JSON::Serializable
    include Cdp::Request

    property enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setBypassCSP"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetPermissionsPolicyState
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId

    def initialize(@frame_id : FrameId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getPermissionsPolicyState"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetPermissionsPolicyStateResult
      res = GetPermissionsPolicyStateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetPermissionsPolicyStateResult
    include JSON::Serializable

    property states : Array(PermissionsPolicyFeatureState)

    def initialize(@states : Array(PermissionsPolicyFeatureState))
    end
  end

  @[Experimental]
  struct GetOriginTrials
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId

    def initialize(@frame_id : FrameId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getOriginTrials"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetOriginTrialsResult
      res = GetOriginTrialsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetOriginTrialsResult
    include JSON::Serializable

    property origin_trials : Array(OriginTrial)

    def initialize(@origin_trials : Array(OriginTrial))
    end
  end

  @[Experimental]
  struct SetFontFamilies
    include JSON::Serializable
    include Cdp::Request

    property font_families : FontFamilies
    @[JSON::Field(emit_null: false)]
    property for_scripts : Array(ScriptFontFamilies)?

    def initialize(@font_families : FontFamilies, @for_scripts : Array(ScriptFontFamilies)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setFontFamilies"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetFontSizes
    include JSON::Serializable
    include Cdp::Request

    property font_sizes : FontSizes

    def initialize(@font_sizes : FontSizes)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setFontSizes"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDocumentContent
    include JSON::Serializable
    include Cdp::Request

    property frame_id : FrameId
    property html : String

    def initialize(@frame_id : FrameId, @html : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setDocumentContent"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Deprecated]
  @[Experimental]
  struct SetDownloadBehavior
    include JSON::Serializable
    include Cdp::Request

    property behavior : SetDownloadBehaviorBehavior
    @[JSON::Field(emit_null: false)]
    property download_path : String?

    def initialize(@behavior : SetDownloadBehaviorBehavior, @download_path : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setDownloadBehavior"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetLifecycleEventsEnabled
    include JSON::Serializable
    include Cdp::Request

    property enabled : Bool

    def initialize(@enabled : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setLifecycleEventsEnabled"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct StartScreencast
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property format : ScreencastFormat?
    @[JSON::Field(emit_null: false)]
    property quality : Int64?
    @[JSON::Field(emit_null: false)]
    property max_width : Int64?
    @[JSON::Field(emit_null: false)]
    property max_height : Int64?
    @[JSON::Field(emit_null: false)]
    property every_nth_frame : Int64?

    def initialize(@format : ScreencastFormat?, @quality : Int64?, @max_width : Int64?, @max_height : Int64?, @every_nth_frame : Int64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.startScreencast"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct StopLoading
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.stopLoading"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct Crash
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.crash"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Close
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.close"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetWebLifecycleState
    include JSON::Serializable
    include Cdp::Request

    property state : SetWebLifecycleStateState

    def initialize(@state : SetWebLifecycleStateState)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setWebLifecycleState"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct StopScreencast
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.stopScreencast"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ProduceCompilationCache
    include JSON::Serializable
    include Cdp::Request

    property scripts : Array(CompilationCacheParams)

    def initialize(@scripts : Array(CompilationCacheParams))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.produceCompilationCache"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct AddCompilationCache
    include JSON::Serializable
    include Cdp::Request

    property url : String
    property data : String

    def initialize(@url : String, @data : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.addCompilationCache"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ClearCompilationCache
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.clearCompilationCache"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetSPCTransactionMode
    include JSON::Serializable
    include Cdp::Request

    property mode : SetSPCTransactionModeMode

    def initialize(@mode : SetSPCTransactionModeMode)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setSPCTransactionMode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetRPHRegistrationMode
    include JSON::Serializable
    include Cdp::Request

    property mode : SetRPHRegistrationModeMode

    def initialize(@mode : SetRPHRegistrationModeMode)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setRPHRegistrationMode"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GenerateTestReport
    include JSON::Serializable
    include Cdp::Request

    property message : String
    @[JSON::Field(emit_null: false)]
    property group : String?

    def initialize(@message : String, @group : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.generateTestReport"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct WaitForDebugger
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.waitForDebugger"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetInterceptFileChooserDialog
    include JSON::Serializable
    include Cdp::Request

    property enabled : Bool
    @[JSON::Field(emit_null: false)]
    property cancel : Bool?

    def initialize(@enabled : Bool, @cancel : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setInterceptFileChooserDialog"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetPrerenderingAllowed
    include JSON::Serializable
    include Cdp::Request

    property is_allowed : Bool

    def initialize(@is_allowed : Bool)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.setPrerenderingAllowed"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetAnnotatedPageContent
    include JSON::Serializable
    include Cdp::Request

    @[JSON::Field(emit_null: false)]
    property include_actionable_information : Bool?

    def initialize(@include_actionable_information : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Page.getAnnotatedPageContent"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetAnnotatedPageContentResult
      res = GetAnnotatedPageContentResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetAnnotatedPageContentResult
    include JSON::Serializable

    property content : String

    def initialize(@content : String)
    end
  end
end
