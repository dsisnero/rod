require "../cdp"
require "json"
require "base64"
require "time"

require "../page/page"
require "../browser/browser"

module Cdp::Target
  alias TargetID = String

  alias SessionID = String

  struct TargetInfo
    include JSON::Serializable
    @[JSON::Field(key: "targetId", emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String
    @[JSON::Field(key: "title", emit_null: false)]
    property title : String
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "attached", emit_null: false)]
    property? attached : Bool
    @[JSON::Field(key: "parentId", emit_null: false)]
    property parent_id : TargetID?
    @[JSON::Field(key: "openerId", emit_null: false)]
    property opener_id : TargetID?
    @[JSON::Field(key: "canAccessOpener", emit_null: false)]
    property? can_access_opener : Bool
    @[JSON::Field(key: "openerFrameId", emit_null: false)]
    property opener_frame_id : Cdp::Page::FrameId?
    @[JSON::Field(key: "parentFrameId", emit_null: false)]
    property parent_frame_id : Cdp::Page::FrameId?
    @[JSON::Field(key: "browserContextId", emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?
    @[JSON::Field(key: "subtype", emit_null: false)]
    property subtype : String?
    @[JSON::Field(key: "embedderData", emit_null: false)]
    property embedder_data : JSON::Any?

    def initialize(@target_id : TargetID, @type : String, @title : String, @url : String, @attached : Bool, @can_access_opener : Bool, @parent_id : TargetID? = nil, @opener_id : TargetID? = nil, @opener_frame_id : Cdp::Page::FrameId? = nil, @parent_frame_id : Cdp::Page::FrameId? = nil, @browser_context_id : Cdp::Browser::BrowserContextID? = nil, @subtype : String? = nil, @embedder_data : JSON::Any? = nil)
    end
  end

  @[Experimental]
  struct FilterEntry
    include JSON::Serializable
    @[JSON::Field(key: "exclude", emit_null: false)]
    property? exclude : Bool?
    @[JSON::Field(key: "type", emit_null: false)]
    property type : String?

    def initialize(@exclude : Bool? = nil, @type : String? = nil)
    end
  end

  @[Experimental]
  # TODO: Implement type array for TargetFilter
  alias TargetFilter = JSON::Any

  @[Experimental]
  struct RemoteLocation
    include JSON::Serializable
    @[JSON::Field(key: "host", emit_null: false)]
    property host : String
    @[JSON::Field(key: "port", emit_null: false)]
    property port : Int64

    def initialize(@host : String, @port : Int64)
    end
  end

  @[Experimental]
  alias WindowState = String
  WindowStateNormal     = "normal"
  WindowStateMinimized  = "minimized"
  WindowStateMaximized  = "maximized"
  WindowStateFullscreen = "fullscreen"
end
