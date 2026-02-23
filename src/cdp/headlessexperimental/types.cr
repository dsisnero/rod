
require "../cdp"
require "json"
require "time"


module Cdp::HeadlessExperimental
  struct ScreenshotParams
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property format : ScreenshotParamsFormat?
    @[JSON::Field(emit_null: false)]
    property quality : Int64?
    @[JSON::Field(emit_null: false)]
    property optimize_for_speed : Bool?
  end

  alias ScreenshotParamsFormat = String

   end
