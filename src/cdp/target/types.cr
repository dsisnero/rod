
require "../cdp"
require "json"
require "time"

require "../page/page"
require "../browser/browser"

module Cdp::Target
  alias TargetID = String

  alias SessionID = String

  struct TargetInfo
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property target_id : TargetID
    @[JSON::Field(emit_null: false)]
    property type : String
    @[JSON::Field(emit_null: false)]
    property title : String
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property attached : Bool
    @[JSON::Field(emit_null: false)]
    property opener_id : TargetID?
    @[JSON::Field(emit_null: false)]
    property can_access_opener : Bool
    @[JSON::Field(emit_null: false)]
    property opener_frame_id : Cdp::Page::FrameId?
    @[JSON::Field(emit_null: false)]
    property parent_frame_id : Cdp::Page::FrameId?
    @[JSON::Field(emit_null: false)]
    property browser_context_id : Cdp::Browser::BrowserContextID?
    @[JSON::Field(emit_null: false)]
    property subtype : String?
  end

  @[Experimental]
  struct FilterEntry
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property exclude : Bool?
    @[JSON::Field(emit_null: false)]
    property type : String?
  end

  @[Experimental]
  # TODO: Implement type array for Target.TargetFilter
  alias TargetFilter = JSON::Any

  @[Experimental]
  struct RemoteLocation
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property host : String
    @[JSON::Field(emit_null: false)]
    property port : Int64
  end

  @[Experimental]
  alias WindowState = String

   end
