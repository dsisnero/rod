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
    @[JSON::Field(key: "frameId", emit_null: false)]
    property frame_id : Cdp::Page::FrameId
    @[JSON::Field(key: "guid", emit_null: false)]
    property guid : String
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String
    @[JSON::Field(key: "suggestedFilename", emit_null: false)]
    property suggested_filename : String

    def initialize(@frame_id : Cdp::Page::FrameId, @guid : String, @url : String, @suggested_filename : String)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Browser.downloadWillBegin"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Browser.downloadWillBegin"
    end
  end

  @[Experimental]
  struct DownloadProgressEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "guid", emit_null: false)]
    property guid : String
    @[JSON::Field(key: "totalBytes", emit_null: false)]
    property total_bytes : Float64
    @[JSON::Field(key: "receivedBytes", emit_null: false)]
    property received_bytes : Float64
    @[JSON::Field(key: "state", emit_null: false)]
    property state : DownloadProgressState
    @[JSON::Field(key: "filePath", emit_null: false)]
    property file_path : String?

    def initialize(@guid : String, @total_bytes : Float64, @received_bytes : Float64, @state : DownloadProgressState, @file_path : String?)
    end

    # ProtoEvent returns the protocol event name.
    def proto_event : String
      "Browser.downloadProgress"
    end

    # Class method returning protocol event name.
    def self.proto_event : String
      "Browser.downloadProgress"
    end
  end
end
