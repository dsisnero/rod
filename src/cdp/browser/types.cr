
require "../cdp"
require "json"
require "time"

require "../target/target"
require "../page/page"

module Cdp::Browser
  @[Experimental]
  alias BrowserContextID = String

  @[Experimental]
  alias WindowID = Int64

  @[Experimental]
  alias WindowState = String

  @[Experimental]
  struct Bounds
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property left : Int64?
    @[JSON::Field(emit_null: false)]
    property top : Int64?
    @[JSON::Field(emit_null: false)]
    property width : Int64?
    @[JSON::Field(emit_null: false)]
    property height : Int64?
    @[JSON::Field(emit_null: false)]
    property window_state : WindowState?
  end

  @[Experimental]
  alias PermissionType = String

  @[Experimental]
  alias PermissionSetting = String

  @[Experimental]
  struct PermissionDescriptor
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property sysex : Bool?
    @[JSON::Field(emit_null: false)]
    property user_visible_only : Bool?
    @[JSON::Field(emit_null: false)]
    property allow_without_sanitization : Bool?
    @[JSON::Field(emit_null: false)]
    property allow_without_gesture : Bool?
    @[JSON::Field(emit_null: false)]
    property pan_tilt_zoom : Bool?
  end

  @[Experimental]
  alias BrowserCommandId = String

  @[Experimental]
  struct Bucket
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property low : Int64
    @[JSON::Field(emit_null: false)]
    property high : Int64
    @[JSON::Field(emit_null: false)]
    property count : Int64
  end

  @[Experimental]
  struct Histogram
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property name : String
    @[JSON::Field(emit_null: false)]
    property sum : Int64
    @[JSON::Field(emit_null: false)]
    property count : Int64
    @[JSON::Field(emit_null: false)]
    property buckets : Array(Bucket)
  end

  @[Experimental]
  alias PrivacySandboxAPI = String

  alias DownloadProgressState = String

  alias SetDownloadBehaviorBehavior = String

   end
