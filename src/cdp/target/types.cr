require "../target/target"
require "json"
require "time"
require "../browser/browser"

module Cdp::Target
  alias TargetID = String

  alias SessionID = String

  struct TargetInfo
    include JSON::Serializable

    property target_id : TargetID
    property type : String
    property title : String
    property url : String
    property attached : Bool
    @[JSON::Field(emit_null: false)]
    property opener_id : TargetID?
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

    property host : String
    property port : Int64
  end

  @[Experimental]
  alias WindowState = String
end
