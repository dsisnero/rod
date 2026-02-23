require "../cdp"
require "json"
require "time"

require "../dom/dom"

require "./types"
require "./events"

# The Browser domain defines methods and events for browser managing.
module Cdp::Browser
  struct GetVersionResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property protocol_version : String
    @[JSON::Field(emit_null: false)]
    property product : String
    @[JSON::Field(emit_null: false)]
    property revision : String
    @[JSON::Field(emit_null: false)]
    property user_agent : String
    @[JSON::Field(emit_null: false)]
    property js_version : String

    def initialize(@protocol_version : String, @product : String, @revision : String, @user_agent : String, @js_version : String)
    end
  end

  @[Experimental]
  struct GetBrowserCommandLineResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property arguments : Array(String)

    def initialize(@arguments : Array(String))
    end
  end

  @[Experimental]
  struct GetHistogramsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property histograms : Array(Cdp::NodeType)

    def initialize(@histograms : Array(Cdp::NodeType))
    end
  end

  @[Experimental]
  struct GetHistogramResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property histogram : Cdp::NodeType

    def initialize(@histogram : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct GetWindowBoundsResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property bounds : Cdp::NodeType

    def initialize(@bounds : Cdp::NodeType)
    end
  end

  @[Experimental]
  struct GetWindowForTargetResult
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property window_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property bounds : Cdp::NodeType

    def initialize(@window_id : Cdp::NodeType, @bounds : Cdp::NodeType)
    end
  end

  # Commands
  @[Experimental]
  struct SetPermission
    include JSON::Serializable
    include Cdp::Request
    @[JSON::Field(emit_null: false)]
    property permission : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property setting : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property origin : String?
    @[JSON::Field(emit_null: false)]
    property embedded_origin : String?
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::NodeType?

    def initialize(@permission : Cdp::NodeType, @setting : Cdp::NodeType, @origin : String?, @embedded_origin : String?, @browser_context_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::NodeType?

    def initialize(@browser_context_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property behavior : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property download_path : String?
    @[JSON::Field(emit_null: false)]
    property? events_enabled : Bool?

    def initialize(@behavior : Cdp::NodeType, @browser_context_id : Cdp::NodeType?, @download_path : String?, @events_enabled : Bool?)
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
    @[JSON::Field(emit_null: false)]
    property guid : String
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::NodeType?

    def initialize(@guid : String, @browser_context_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property query : String?
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property window_id : Cdp::NodeType

    def initialize(@window_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property target_id : Cdp::NodeType?

    def initialize(@target_id : Cdp::NodeType?)
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
    @[JSON::Field(emit_null: false)]
    property window_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property bounds : Cdp::NodeType

    def initialize(@window_id : Cdp::NodeType, @bounds : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
    property window_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property width : Int64?
    @[JSON::Field(emit_null: false)]
    property height : Int64?

    def initialize(@window_id : Cdp::NodeType, @width : Int64?, @height : Int64?)
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
    @[JSON::Field(emit_null: false)]
    property badge_label : String?
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property command_id : Cdp::NodeType

    def initialize(@command_id : Cdp::NodeType)
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
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property api : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property coordinator_origin : String
    @[JSON::Field(emit_null: false)]
    property key_config : String
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::NodeType?

    def initialize(@api : Cdp::NodeType, @coordinator_origin : String, @key_config : String, @browser_context_id : Cdp::NodeType?)
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
