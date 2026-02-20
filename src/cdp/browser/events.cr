require "../browser/browser"
require "json"
require "time"
require "../target/target"
require "../page/page"

module Cdp::Browser
  @[Experimental]
  struct DownloadWillBeginEvent
    include JSON::Serializable
    include Cdp::Event

    property frame_id : Cdp::Page::FrameId
    property guid : String
    property url : String
    property suggested_filename : String

    def initialize(@frame_id : Cdp::Page::FrameId, @guid : String, @url : String, @suggested_filename : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Browser.downloadWillBegin"
    end
  end

  @[Experimental]
  struct DownloadProgressEvent
    include JSON::Serializable
    include Cdp::Event

    property guid : String
    property total_bytes : Float64
    property received_bytes : Float64
    property state : DownloadProgressState
    @[JSON::Field(emit_null: false)]
    property file_path : String?

    def initialize(@guid : String, @total_bytes : Float64, @received_bytes : Float64, @state : DownloadProgressState, @file_path : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Browser.downloadProgress"
    end
  end
end
