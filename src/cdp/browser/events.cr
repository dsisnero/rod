require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Browser
  @[Experimental]
  struct DownloadWillBeginEvent
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(emit_null: false)]
    property frame_id : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property guid : String
    @[JSON::Field(emit_null: false)]
    property url : String
    @[JSON::Field(emit_null: false)]
    property suggested_filename : String

    def initialize(@frame_id : Cdp::NodeType, @guid : String, @url : String, @suggested_filename : String)
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
    @[JSON::Field(emit_null: false)]
    property guid : String
    @[JSON::Field(emit_null: false)]
    property total_bytes : Float64
    @[JSON::Field(emit_null: false)]
    property received_bytes : Float64
    @[JSON::Field(emit_null: false)]
    property state : Cdp::NodeType
    @[JSON::Field(emit_null: false)]
    property file_path : String?

    def initialize(@guid : String, @total_bytes : Float64, @received_bytes : Float64, @state : Cdp::NodeType, @file_path : String?)
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
