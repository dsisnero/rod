require "../cdp"
require "json"
require "base64"
require "time"

require "../page/page"

module Cdp::CrashReportContext
  struct CrashReportContextEntry
    include JSON::Serializable
    @[JSON::Field(key: "key", emit_null: false)]
    property key : String
    @[JSON::Field(key: "value", emit_null: false)]
    property value : String
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId

    def initialize(@key : String, @value : String, @frame_id : Cdp::Page::FrameId)
    end
  end
end
