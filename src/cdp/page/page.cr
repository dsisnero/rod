require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# Actions and events related to the inspected page belong to the page domain.
module Cdp::Page
  struct AddScriptToEvaluateOnNewDocumentResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType)
    end
  end

  struct CaptureScreenshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@data : String)
    end
  end

  @[Experimental]
  struct CaptureSnapshotResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data : String

    def initialize(@data : String)
    end
  end

  struct CreateIsolatedWorldResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property execution_context_id : Cdp::NodeType

    def initialize(@execution_context_id : Cdp::NodeType)
    end
  end

  struct GetAppManifestResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property errors : Array(Cdp::NodeType)
    @[JSON::Field(emit_null: false)]
    property data : String?
    @[JSON::Field(emit_null: false)]
    property parsed : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property manifest : Cdp::NodeType

    def initialize(@url : String, @errors : Array(Cdp::NodeType), @data : String?, @parsed : Cdp::NodeType?, @manifest : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct GetInstallabilityErrorsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property installability_errors : Array(Cdp::NodeType)

    def initialize(@installability_errors : Array(Cdp::NodeType))
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
  struct GetAdScriptAncestryResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property ad_script_ancestry : Cdp::NodeType?

    def initialize(@ad_script_ancestry : Cdp::NodeType?)
    end
  end

  struct GetFrameTreeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_tree : Cdp::NodeType

    def initialize(@frame_tree : Cdp::NodeType)
    end
  end

  struct GetLayoutMetricsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property layout_viewport : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property visual_viewport : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property content_size : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property css_layout_viewport : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property css_visual_viewport : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property css_content_size : Cdp::NodeType

    def initialize(@layout_viewport : Cdp::NodeType, @visual_viewport : Cdp::NodeType, @content_size : Cdp::NodeType, @css_layout_viewport : Cdp::NodeType, @css_visual_viewport : Cdp::NodeType, @css_content_size : Cdp::NodeType)
    end
  end

  struct GetNavigationHistoryResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property current_index : Int64
    @[JSON::Field(emit_null: false)]
    property entries : Array(Cdp::NodeType)

    def initialize(@current_index : Int64, @entries : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetResourceContentResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property content : String
    @[JSON::Field(emit_null: false)]
    property? base64_encoded : Bool

    def initialize(@content : String, @base64_encoded : Bool)
    end
  end

  @[Experimental]
  struct GetResourceTreeResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_tree : Cdp::NodeType

    def initialize(@frame_tree : Cdp::NodeType)
    end
  end

  struct NavigateResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property error_text : String?
    @[JSON::Field(emit_null: false)]
    property? is_download : Bool?

    def initialize(@frame_id : Cdp::NodeType, @loader_id : Cdp::NodeType?, @error_text : String?, @is_download : Bool?)
    end
  end

  struct PrintToPDFResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property data : String
    @[JSON::Field(emit_null: false)]
    property stream : Cdp::NodeType?

    def initialize(@data : String, @stream : Cdp::NodeType?)
    end
  end

  @[Experimental]
  struct SearchInResourceResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property result : Array(Cdp::NodeType)

    def initialize(@result : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetPermissionsPolicyStateResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property states : Array(Cdp::NodeType)

    def initialize(@states : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetOriginTrialsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property origin_trials : Array(Cdp::NodeType)

    def initialize(@origin_trials : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetAnnotatedPageContentResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property content : String

    def initialize(@content : String)
    end
  end

  # Commands
  struct AddScriptToEvaluateOnNewDocument
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property source : String
    @[JSON::Field(emit_null: false)]
    property world_name : String?
    @[JSON::Field(emit_null: false)]
    property? include_command_line_api : Bool?
    @[JSON::Field(emit_null: false)]
    property? run_immediately : Bool?

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
    property format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property quality : Int64?
    @[JSON::Field(emit_null: false)]
    property clip : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? from_surface : Bool?
    @[JSON::Field(emit_null: false)]
    property? capture_beyond_viewport : Bool?
    @[JSON::Field(emit_null: false)]
    property? optimize_for_speed : Bool?

    def initialize(@format : Cdp::NodeType?, @quality : Int64?, @clip : Cdp::NodeType?, @from_surface : Bool?, @capture_beyond_viewport : Bool?, @optimize_for_speed : Bool?)
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

  @[Experimental]
  struct CaptureSnapshot
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property format : Cdp::NodeType?

    def initialize(@format : Cdp::NodeType?)
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

  struct CreateIsolatedWorld
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property world_name : String?
    @[JSON::Field(emit_null: false)]
    property? grant_univeral_access : Bool?

    def initialize(@frame_id : Cdp::NodeType, @world_name : String?, @grant_univeral_access : Bool?)
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
    property? enable_file_chooser_opened_event : Bool?

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
  struct GetAdScriptAncestry
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String

    def initialize(@frame_id : Cdp::NodeType, @url : String)
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

  struct HandleJavaScriptDialog
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? accept : Bool
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
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property referrer : String?
    @[JSON::Field(emit_null: false)]
    property transition_type : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property referrer_policy : Cdp::NodeType?

    def initialize(@url : String, @referrer : String?, @transition_type : Cdp::NodeType?, @frame_id : Cdp::NodeType?, @referrer_policy : Cdp::NodeType?)
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

  struct NavigateToHistoryEntry
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
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
    property? landscape : Bool?
    @[JSON::Field(emit_null: false)]
    property? display_header_footer : Bool?
    @[JSON::Field(emit_null: false)]
    property? print_background : Bool?
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
    property? prefer_css_page_size : Bool?
    @[JSON::Field(emit_null: false)]
    property transfer_mode : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property? generate_tagged_pdf : Bool?
    @[JSON::Field(emit_null: false)]
    property? generate_document_outline : Bool?

    def initialize(@landscape : Bool?, @display_header_footer : Bool?, @print_background : Bool?, @scale : Float64?, @paper_width : Float64?, @paper_height : Float64?, @margin_top : Float64?, @margin_bottom : Float64?, @margin_left : Float64?, @margin_right : Float64?, @page_ranges : String?, @header_template : String?, @footer_template : String?, @prefer_css_page_size : Bool?, @transfer_mode : Cdp::NodeType?, @generate_tagged_pdf : Bool?, @generate_document_outline : Bool?)
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

  struct Reload
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? ignore_cache : Bool?
    @[JSON::Field(emit_null: false)]
    property script_to_evaluate_on_load : String?
    @[JSON::Field(emit_null: false)]
    property loader_id : Cdp::NodeType?

    def initialize(@ignore_cache : Bool?, @script_to_evaluate_on_load : String?, @loader_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property identifier : Cdp::NodeType

    def initialize(@identifier : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property query : String
    @[JSON::Field(emit_null: false)]
    property? case_sensitive : Bool?
    @[JSON::Field(emit_null: false)]
    property? is_regex : Bool?

    def initialize(@frame_id : Cdp::NodeType, @url : String, @query : String, @case_sensitive : Bool?, @is_regex : Bool?)
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
  struct SetAdBlockingEnabled
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

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
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

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
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType)
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
  struct GetOriginTrials
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType

    def initialize(@frame_id : Cdp::NodeType)
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
  struct SetFontFamilies
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property font_families : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property for_scripts : Array(Cdp::NodeType)?

    def initialize(@font_families : Cdp::NodeType, @for_scripts : Array(Cdp::NodeType)?)
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
    @[JSON::Field(emit_null: false)]
    property font_sizes : Cdp::NodeType

    def initialize(@font_sizes : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property html : String

    def initialize(@frame_id : Cdp::NodeType, @html : String)
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
    @[JSON::Field(emit_null: false)]
    property behavior : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property download_path : String?

    def initialize(@behavior : Cdp::NodeType, @download_path : String?)
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
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool

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
    property format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property quality : Int64?
    @[JSON::Field(emit_null: false)]
    property max_width : Int64?
    @[JSON::Field(emit_null: false)]
    property max_height : Int64?
    @[JSON::Field(emit_null: false)]
    property every_nth_frame : Int64?

    def initialize(@format : Cdp::NodeType?, @quality : Int64?, @max_width : Int64?, @max_height : Int64?, @every_nth_frame : Int64?)
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
    @[JSON::Field(emit_null: false)]
    property state : Cdp::NodeType

    def initialize(@state : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property scripts : Array(Cdp::NodeType)

    def initialize(@scripts : Array(Cdp::NodeType))
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
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property mode : Cdp::NodeType

    def initialize(@mode : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property mode : Cdp::NodeType

    def initialize(@mode : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property? enabled : Bool
    @[JSON::Field(emit_null: false)]
    property? cancel : Bool?

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
    @[JSON::Field(emit_null: false)]
    property? is_allowed : Bool

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
    property? include_actionable_information : Bool?

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
end
