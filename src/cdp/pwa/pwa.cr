require "json"
require "../cdp"
require "../target/target"
require "./types"

# This domain allows interacting with the browser to control PWAs.
@[Experimental]
module Cdp::PWA
  # Commands
  struct GetOsAppState
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String

    def initialize(@manifest_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.getOsAppState"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : GetOsAppStateResult
      res = GetOsAppStateResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct GetOsAppStateResult
    include JSON::Serializable

    property badge_count : Int64
    property file_handlers : Array(FileHandler)

    def initialize(@badge_count : Int64, @file_handlers : Array(FileHandler))
    end
  end

  struct Install
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String
    @[JSON::Field(emit_null: false)]
    property install_url_or_bundle_url : String?

    def initialize(@manifest_id : String, @install_url_or_bundle_url : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.install"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Uninstall
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String

    def initialize(@manifest_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.uninstall"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Launch
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String
    @[JSON::Field(emit_null: false)]
    property url : String?

    def initialize(@manifest_id : String, @url : String?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.launch"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : LaunchResult
      res = LaunchResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct LaunchResult
    include JSON::Serializable

    property target_id : Cdp::Target::TargetID

    def initialize(@target_id : Cdp::Target::TargetID)
    end
  end

  struct LaunchFilesInApp
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String
    property files : Array(String)

    def initialize(@manifest_id : String, @files : Array(String))
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.launchFilesInApp"
    end

    # Call sends the request and returns the result.
    def call(c : Cdp::Client) : LaunchFilesInAppResult
      res = LaunchFilesInAppResult.new
      Cdp.call(proto_req, self, res, c)
      res
    end
  end

  struct LaunchFilesInAppResult
    include JSON::Serializable

    property target_ids : Array(Cdp::Target::TargetID)

    def initialize(@target_ids : Array(Cdp::Target::TargetID))
    end
  end

  struct OpenCurrentPageInApp
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String

    def initialize(@manifest_id : String)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.openCurrentPageInApp"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct ChangeAppUserSettings
    include JSON::Serializable
    include Cdp::Request

    property manifest_id : String
    @[JSON::Field(emit_null: false)]
    property link_capturing : Bool?
    @[JSON::Field(emit_null: false)]
    property display_mode : DisplayMode?

    def initialize(@manifest_id : String, @link_capturing : Bool?, @display_mode : DisplayMode?)
    end

    # ProtoReq returns the protocol method name.
    def proto_req : String
      "PWA.changeAppUserSettings"
    end

    # Call sends the request.
    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end
end
