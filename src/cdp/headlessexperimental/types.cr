require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::HeadlessExperimental
  struct ScreenshotParams
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property format : Cdp::NodeType?
    @[JSON::Field(emit_null: false)]
    property quality : Int64?
    @[JSON::Field(emit_null: false)]
    property? optimize_for_speed : Bool?
  end

  alias ScreenshotParamsFormat = String
  ScreenshotParamsFormatJpeg = "jpeg"
  ScreenshotParamsFormatPng  = "png"
  ScreenshotParamsFormatWebp = "webp"
end
