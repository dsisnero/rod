require "../pwa/pwa"
require "json"
require "time"
require "../target/target"

module Cdp::PWA
  struct FileHandlerAccept
    include JSON::Serializable

    property media_type : String
    property file_extensions : Array(String)
  end

  struct FileHandler
    include JSON::Serializable

    property action : String
    property accepts : Array(FileHandlerAccept)
    property display_name : String
  end

  alias DisplayMode = String
end
