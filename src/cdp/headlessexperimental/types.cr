require "../cdp"
require "json"
require "time"

module Cdp::HeadlessExperimental
  struct ScreenshotParams
    include JSON::Serializable
    @[JSON::Field(key: "format", emit_null: false)]
    property format : ScreenshotParamsFormat?
    @[JSON::Field(key: "quality", emit_null: false)]
    property quality : Int64?
    @[JSON::Field(key: "optimizeForSpeed", emit_null: false)]
    property? optimize_for_speed : Bool?
  end

  alias ScreenshotParamsFormat = String
  ScreenshotParamsFormatJpeg = "jpeg"
  ScreenshotParamsFormatPng  = "png"
  ScreenshotParamsFormatWebp = "webp"
end
