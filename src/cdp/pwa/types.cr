require "../cdp"
require "json"
require "time"

require "../target/target"

module Cdp::PWA
  struct FileHandlerAccept
    include JSON::Serializable
    @[JSON::Field(key: "mediaType", emit_null: false)]
    property media_type : String
    @[JSON::Field(key: "fileExtensions", emit_null: false)]
    property file_extensions : Array(String)
  end

  struct FileHandler
    include JSON::Serializable
    @[JSON::Field(key: "action", emit_null: false)]
    property action : String
    @[JSON::Field(key: "accepts", emit_null: false)]
    property accepts : Array(FileHandlerAccept)
    @[JSON::Field(key: "displayName", emit_null: false)]
    property display_name : String
  end

  alias DisplayMode = String
  DisplayModeStandalone = "standalone"
  DisplayModeBrowser    = "browser"
end
