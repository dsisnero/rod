require "../cdp"
require "json"
require "time"

require "../page/page"
require "../browser/browser"

require "./types"
require "./events"

# Supports additional targets discovery and allows to attach to them.
module Cdp::Target
  struct AttachToTargetResult
    include JSON::Serializable
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : SessionID

    def initialize(@session_id : SessionID)
    end
  end

  @[Experimental]
  struct AttachToBrowserTargetResult
    include JSON::Serializable
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : SessionID

    def initialize(@session_id : SessionID)
    end
  end

  struct CloseTargetResult
    include JSON::Serializable

    def initialize
    end
  end

  struct CreateBrowserContextResult
    include JSON::Serializable
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID

    def initialize(@browser_context_id : Cdp::Browser::BrowserContextID)
    end
  end

  struct GetBrowserContextsResult
    include JSON::Serializable
    @[JSON::Field(key: "browserContextIds", emit_null: false)]
    property browser_context_ids : Array(Cdp::Browser::BrowserContextID)
    @[JSON::Field(key: "defaultBrowserContextId", emit_null: false)]
    property default_browser_context_id : Cdp::Browser::BrowserContextID?

    def initialize(@browser_context_ids : Array(Cdp::Browser::BrowserContextID), @default_browser_context_id : Cdp::Browser::BrowserContextID?)
    end
  end

  struct CreateTargetResult
    include JSON::Serializable
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end
  end

  @[Experimental]
  struct GetTargetInfoResult
    include JSON::Serializable
    @[JSON::Field(key: "targetInfo", emit_null: false)]
    property target_info : TargetInfo

    def initialize(@target_info : TargetInfo)
    end
  end

  struct GetTargetsResult
    include JSON::Serializable
    @[JSON::Field(key: "targetInfos", emit_null: false)]
    property target_infos : Array(TargetInfo)

    def initialize(@target_infos : Array(TargetInfo))
    end
  end

  @[Experimental]
  struct GetDevToolsTargetResult
    include JSON::Serializable
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID?

    def initialize(@target_id : TargetID?)
    end
  end

  @[Experimental]
  struct OpenDevToolsResult
    include JSON::Serializable
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end
  end

  # Commands
  struct ActivateTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.activateTarget"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AttachToTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(key: "flatten", emit_null: false)]
    property? flatten : Bool?

    def initialize(@target_id : TargetID, @flatten : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.attachToTarget"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AttachToTargetResult
      res = AttachToTargetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct AttachToBrowserTarget
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.attachToBrowserTarget"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : AttachToBrowserTargetResult
      res = AttachToBrowserTargetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CloseTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.closeTarget"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CloseTargetResult
      res = CloseTargetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct ExposeDevToolsProtocol
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(key: "bindingName", emit_null: false)]
    property binding_name : String?
    @[JSON::Field(key: "inheritPermissions", emit_null: false)]
    property? inherit_permissions : Bool?

    def initialize(@target_id : TargetID, @binding_name : String?, @inherit_permissions : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.exposeDevToolsProtocol"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct CreateBrowserContext
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "disposeOnDetach", emit_null: false)]
    property? dispose_on_detach : Bool?
    @[JSON::Field(key: "proxyServer", emit_null: false)]
    property proxy_server : String?
    @[JSON::Field(key: "proxyBypassList", emit_null: false)]
    property proxy_bypass_list : String?
    @[JSON::Field(key: "originsWithUniversalNetworkAccess", emit_null: false)]
    property origins_with_universal_network_access : Array(String)?

    def initialize(@dispose_on_detach : Bool?, @proxy_server : String?, @proxy_bypass_list : String?, @origins_with_universal_network_access : Array(String)?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.createBrowserContext"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CreateBrowserContextResult
      res = CreateBrowserContextResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetBrowserContexts
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.getBrowserContexts"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBrowserContextsResult
      res = GetBrowserContextsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct CreateTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "left", emit_null: false)]
    property left : Int64?
    @[JSON::Field(key: "top", emit_null: false)]
    property top : Int64?
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Int64?
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Int64?
    @[JSON::Field(key: "windowState", emit_null: false)]
    property window_state : WindowState?
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?
    @[JSON::Field(key: "enableBeginFrameControl", emit_null: false)]
    property? enable_begin_frame_control : Bool?
    @[JSON::Field(key: "newWindow", emit_null: false)]
    property? new_window : Bool?
    @[JSON::Field(key: "background", emit_null: false)]
    property? background : Bool?
    @[JSON::Field(key: "forTab", emit_null: false)]
    property? for_tab : Bool?
    @[JSON::Field(key: "hidden", emit_null: false)]
    property? hidden : Bool?
    @[JSON::Field(key: "focus", emit_null: false)]
    property? focus : Bool?

    def initialize(@url : String, @left : Int64?, @top : Int64?, @width : Int64?, @height : Int64?, @window_state : WindowState?, @browser_context_id : Cdp::Browser::BrowserContextID?, @enable_begin_frame_control : Bool?, @new_window : Bool?, @background : Bool?, @for_tab : Bool?, @hidden : Bool?, @focus : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.createTarget"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : CreateTargetResult
      res = CreateTargetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct DetachFromTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : SessionID?
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID?

    def initialize(@session_id : SessionID?, @target_id : TargetID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.detachFromTarget"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct DisposeBrowserContext
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID

    def initialize(@browser_context_id : Cdp::Browser::BrowserContextID)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.disposeBrowserContext"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetTargetInfo
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID?

    def initialize(@target_id : TargetID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.getTargetInfo"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetTargetInfoResult
      res = GetTargetInfoResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetTargets
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "filter", emit_null: false)]
    property filter : TargetFilter?

    def initialize(@filter : TargetFilter?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.getTargets"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetTargetsResult
      res = GetTargetsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct SetAutoAttach
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "autoAttach", emit_null: false)]
    property? auto_attach : Bool
    @[JSON::Field(key: "waitForDebuggerOnStart", emit_null: false)]
    property? wait_for_debugger_on_start : Bool
    @[JSON::Field(key: "flatten", emit_null: false)]
    property? flatten : Bool?
    @[JSON::Field(key: "filter", emit_null: false)]
    property filter : TargetFilter?

    def initialize(@auto_attach : Bool, @wait_for_debugger_on_start : Bool, @flatten : Bool?, @filter : TargetFilter?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.setAutoAttach"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct AutoAttachRelated
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(key: "waitForDebuggerOnStart", emit_null: false)]
    property? wait_for_debugger_on_start : Bool
    @[JSON::Field(key: "filter", emit_null: false)]
    property filter : TargetFilter?

    def initialize(@target_id : TargetID, @wait_for_debugger_on_start : Bool, @filter : TargetFilter?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.autoAttachRelated"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct SetDiscoverTargets
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "discover", emit_null: false)]
    property? discover : Bool
    @[JSON::Field(key: "filter", emit_null: false)]
    property filter : TargetFilter?

    def initialize(@discover : Bool, @filter : TargetFilter?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.setDiscoverTargets"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetRemoteLocations
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "locations", emit_null: false)]
    property locations : Array(RemoteLocation)

    def initialize(@locations : Array(RemoteLocation))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.setRemoteLocations"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct GetDevToolsTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID

    def initialize(@target_id : TargetID)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.getDevToolsTarget"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetDevToolsTargetResult
      res = GetDevToolsTargetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct OpenDevTools
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(key: "panelId", emit_null: false)]
    property panel_id : String?

    def initialize(@target_id : TargetID, @panel_id : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Target.openDevTools"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : OpenDevToolsResult
      res = OpenDevToolsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end
end
