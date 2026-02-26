require "../cdp"
require "json"
require "time"

require "../target/target"
require "../page/page"

require "./types"
require "./events"

# The Browser domain defines methods and events for browser managing.
module Cdp::Browser
  struct GetVersionResult
    include JSON::Serializable
    @[JSON::Field(key: "protocolVersion", emit_null: false)]
    property protocol_version : String
    @[JSON::Field(key: "product", emit_null: false)]
    property product : String
    @[JSON::Field(key: "revision", emit_null: false)]
    property revision : String
    @[JSON::Field(key: "userAgent", emit_null: false)]
    property user_agent : String
    @[JSON::Field(key: "jsVersion", emit_null: false)]
    property js_version : String

    def initialize(@protocol_version : String, @product : String, @revision : String, @user_agent : String, @js_version : String)
    end
  end

  @[Experimental]
  struct GetBrowserCommandLineResult
    include JSON::Serializable
    @[JSON::Field(key: "arguments", emit_null: false)]
    property arguments : Array(String)

    def initialize(@arguments : Array(String))
    end
  end

  @[Experimental]
  struct GetHistogramsResult
    include JSON::Serializable
    @[JSON::Field(key: "histograms", emit_null: false)]
    property histograms : Array(Histogram)

    def initialize(@histograms : Array(Histogram))
    end
  end

  @[Experimental]
  struct GetHistogramResult
    include JSON::Serializable
    @[JSON::Field(key: "histogram", emit_null: false)]
    property histogram : Histogram

    def initialize(@histogram : Histogram)
    end
  end

  @[Experimental]
  struct GetWindowBoundsResult
    include JSON::Serializable
    @[JSON::Field(key: "bounds", emit_null: false)]
    property bounds : Bounds

    def initialize(@bounds : Bounds)
    end
  end

  @[Experimental]
  struct GetWindowForTargetResult
    include JSON::Serializable
    @[JSON::Field(key: "windowId", emit_null: false)]
    property window_id : WindowID
    @[JSON::Field(key: "bounds", emit_null: false)]
    property bounds : Bounds

    def initialize(@window_id : WindowID, @bounds : Bounds)
    end
  end

  # Commands
  @[Experimental]
  struct SetPermission
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "permission", emit_null: false)]
    property permission : PermissionDescriptor
    @[JSON::Field(key: "setting", emit_null: false)]
    property setting : PermissionSetting
    @[JSON::Field(key: "origin", emit_null: false)]
    property origin : String?
    @[JSON::Field(key: "embeddedOrigin", emit_null: false)]
    property embedded_origin : String?
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : BrowserContextID?

    def initialize(@permission : PermissionDescriptor, @setting : PermissionSetting, @origin : String?, @embedded_origin : String?, @browser_context_id : BrowserContextID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.setPermission"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ResetPermissions
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : BrowserContextID?

    def initialize(@browser_context_id : BrowserContextID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.resetPermissions"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDownloadBehavior
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "behavior", emit_null: false)]
    property behavior : SetDownloadBehaviorBehavior
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : BrowserContextID?
    @[JSON::Field(key: "downloadPath", emit_null: false)]
    property download_path : String?
    @[JSON::Field(key: "eventsEnabled", emit_null: false)]
    property? events_enabled : Bool?

    def initialize(@behavior : SetDownloadBehaviorBehavior, @browser_context_id : BrowserContextID?, @download_path : String?, @events_enabled : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.setDownloadBehavior"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct CancelDownload
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "guid", emit_null: false)]
    property guid : String
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : BrowserContextID?

    def initialize(@guid : String, @browser_context_id : BrowserContextID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.cancelDownload"
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
      "Browser.close"
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
      "Browser.crash"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct CrashGpuProcess
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.crashGpuProcess"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct GetVersion
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.getVersion"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetVersionResult
      res = GetVersionResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetBrowserCommandLine
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.getBrowserCommandLine"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetBrowserCommandLineResult
      res = GetBrowserCommandLineResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetHistograms
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "query", emit_null: false)]
    property query : String?
    @[JSON::Field(key: "delta", emit_null: false)]
    property? delta : Bool?

    def initialize(@query : String?, @delta : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.getHistograms"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetHistogramsResult
      res = GetHistogramsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetHistogram
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "name", emit_null: false)]
    property name : String
    @[JSON::Field(key: "delta", emit_null: false)]
    property? delta : Bool?

    def initialize(@name : String, @delta : Bool?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.getHistogram"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetHistogramResult
      res = GetHistogramResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetWindowBounds
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "windowId", emit_null: false)]
    property window_id : WindowID

    def initialize(@window_id : WindowID)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.getWindowBounds"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetWindowBoundsResult
      res = GetWindowBoundsResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct GetWindowForTarget
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : Cdp::Target::TargetID?

    def initialize(@target_id : Cdp::Target::TargetID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.getWindowForTarget"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetWindowForTargetResult
      res = GetWindowForTargetResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  @[Experimental]
  struct SetWindowBounds
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "windowId", emit_null: false)]
    property window_id : WindowID
    @[JSON::Field(key: "bounds", emit_null: false)]
    property bounds : Bounds

    def initialize(@window_id : WindowID, @bounds : Bounds)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.setWindowBounds"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetContentsSize
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "windowId", emit_null: false)]
    property window_id : WindowID
    @[JSON::Field(key: "width", emit_null: false)]
    property width : Int64?
    @[JSON::Field(key: "height", emit_null: false)]
    property height : Int64?

    def initialize(@window_id : WindowID, @width : Int64?, @height : Int64?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.setContentsSize"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct SetDockTile
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "badgeLabel", emit_null: false)]
    property badge_label : String?
    @[JSON::Field(key: "image", emit_null: false)]
    property image : String?

    def initialize(@badge_label : String?, @image : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.setDockTile"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  @[Experimental]
  struct ExecuteBrowserCommand
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "commandId", emit_null: false)]
    property command_id : BrowserCommandId

    def initialize(@command_id : BrowserCommandId)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.executeBrowserCommand"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddPrivacySandboxEnrollmentOverride
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String

    def initialize(@url : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.addPrivacySandboxEnrollmentOverride"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct AddPrivacySandboxCoordinatorKeyConfig
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(key: "api", emit_null: false)]
    property api : PrivacySandboxAPI
    @[JSON::Field(key: "coordinatorOrigin", emit_null: false)]
    property coordinator_origin : String
    @[JSON::Field(key: "keyConfig", emit_null: false)]
    property key_config : String
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : BrowserContextID?

    def initialize(@api : PrivacySandboxAPI, @coordinator_origin : String, @key_config : String, @browser_context_id : BrowserContextID?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "Browser.addPrivacySandboxCoordinatorKeyConfig"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
