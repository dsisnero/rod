require "../cdp"
require "json"

# Console domain (deprecated in CDP, retained for Go proto compatibility).
module Cdp::Console
  alias ConsoleMessageSource = String
  ConsoleMessageSourceXml         = "xml"
  ConsoleMessageSourceJavascript  = "javascript"
  ConsoleMessageSourceNetwork     = "network"
  ConsoleMessageSourceConsoleApi  = "console-api"
  ConsoleMessageSourceStorage     = "storage"
  ConsoleMessageSourceAppcache    = "appcache"
  ConsoleMessageSourceRendering   = "rendering"
  ConsoleMessageSourceSecurity    = "security"
  ConsoleMessageSourceOther       = "other"
  ConsoleMessageSourceDeprecation = "deprecation"
  ConsoleMessageSourceWorker      = "worker"

  alias ConsoleMessageLevel = String
  ConsoleMessageLevelLog     = "log"
  ConsoleMessageLevelWarning = "warning"
  ConsoleMessageLevelError   = "error"
  ConsoleMessageLevelDebug   = "debug"
  ConsoleMessageLevelInfo    = "info"

  struct ConsoleMessage
    include JSON::Serializable
    @[JSON::Field(key: "source", emit_null: false)]
    property source : ConsoleMessageSource
    @[JSON::Field(key: "level", emit_null: false)]
    property level : ConsoleMessageLevel
    @[JSON::Field(key: "text", emit_null: false)]
    property text : String
    @[JSON::Field(key: "url", emit_null: false)]
    property url : String?
    @[JSON::Field(key: "line", emit_null: false)]
    property line : Int32?
    @[JSON::Field(key: "column", emit_null: false)]
    property column : Int32?

    def initialize(@source : ConsoleMessageSource, @level : ConsoleMessageLevel, @text : String, @url : String? = nil, @line : Int32? = nil, @column : Int32? = nil)
    end
  end

  struct ClearMessages
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    def proto_req : String
      "Console.clearMessages"
    end

    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Disable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    def proto_req : String
      "Console.disable"
    end

    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct Enable
    include JSON::Serializable
    include Cdp::Request

    def initialize
    end

    def proto_req : String
      "Console.enable"
    end

    def call(c : Cdp::Client) : Nil
      Cdp.call(proto_req, self, nil, c)
    end
  end

  struct MessageAdded
    include JSON::Serializable
    include Cdp::Event
    @[JSON::Field(key: "message", emit_null: false)]
    property message : ConsoleMessage

    def initialize(@message : ConsoleMessage)
    end

    def proto_event : String
      "Console.messageAdded"
    end

    def self.proto_event : String
      "Console.messageAdded"
    end
  end
end
