require "../cdp"
require "json"
require "time"

require "../target/target"

module Cdp::PWA
  struct FileHandlerAccept
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property media_type : String
    @[JSON::Field(emit_null: false)]
    property file_extensions : Array(String)
  end

  struct FileHandler
    include JSON::Serializable
    @[JSON::Field(emit_null: false)]
    property action : String
    @[JSON::Field(emit_null: false)]
    property accepts : Array(FileHandlerAccept)
    @[JSON::Field(emit_null: false)]
    property display_name : String
  end

  alias DisplayMode = String
  DisplayModeStandalone = "standalone"
  DisplayModeBrowser    = "browser"
end
