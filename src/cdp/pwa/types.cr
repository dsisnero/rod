require "../cdp"
require "json"
require "base64"
require "time"

require "../target/target"

module Cdp::PWA
  struct FileHandlerAccept
    include JSON::Serializable
    @[JSON::Field(key: "mediaType", emit_null: false)]
    property media_type : String
    @[JSON::Field(key: "fileExtensions", emit_null: false)]
    property file_extensions : Array(String)

    def initialize(@media_type : String, @file_extensions : Array(String))
    end
  end

  struct FileHandler
    include JSON::Serializable
    @[JSON::Field(key: "action", emit_null: false)]
    property action : String
    @[JSON::Field(key: "accepts", emit_null: false)]
    property accepts : Array(FileHandlerAccept)
    @[JSON::Field(key: "displayName", emit_null: false)]
    property display_name : String

    def initialize(@action : String, @accepts : Array(FileHandlerAccept), @display_name : String)
    end
  end

  alias DisplayMode = String
  DisplayModeStandalone = "standalone"
  DisplayModeBrowser    = "browser"
end
