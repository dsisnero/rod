
require "../cdp"
require "json"
require "time"

require "../target/target"
require "../page/page"

module Cdp::Browser
  @[Experimental]
  struct DownloadWillBeginEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(emit_null: false)]
    property guid : String
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
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
    @[JSON::Field(emit_null: false)]
    property guid : String
    @[JSON::Field(emit_null: false)]
    property total_bytes : Float64
    @[JSON::Field(emit_null: false)]
    property received_bytes : Float64
    @[JSON::Field(emit_null: false)]
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
