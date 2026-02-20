require "goob"
require "gson"
require "./lib/cdp"
require "./lib/proto"
require "./lib/defaults"
require "./lib/devices"
require "./lib/launcher"
require "./lib/utils"

module Rod
  # Browser implements these interfaces.
  class Browser
    include Cdp::Client
    include Cdp::Contextable

    # BrowserContextID is the id for incognito window
    property browser_context_id : Proto::Browser::BrowserContextID?

    @e : EFunc
    @ctx : ::HTTP::Client::Context?
    @sleeper : Proc(::Utils::Sleeper)
    @logger : ::Utils::Logger
    @slow_motion : Time::Span
    @trace : Bool
    @monitor : String?
    @client : Lib::Cdp::Client?
    @targets : Hash(String, TargetInfo)
    @targets_lock : Mutex
    @event : Goob::Observable(Message)

    # New creates a browser instance.
    def initialize(@ctx : ::HTTP::Client::Context? = nil, @sleeper = ->{ ::Utils::Sleeper.new }, @logger = ::Defaults.logger, @slow_motion = ::Defaults.slow, @trace = ::Defaults.trace, @monitor = nil)
      @targets = {} of String => TargetInfo
      @targets_lock = Mutex.new
      @event = Goob::Observable(Message).new(ctx)
    end

    # Connect to browser via websocket URL.
    def connect(ws_url : String) : Nil
      ws = Lib::Cdp::WebSocket.new
      ws.connect(ws_url)
      client = Lib::Cdp::Client.new(@logger)
      client.start(ws)
      @client = client
      init_events
    end

    # Event of the browser.
    def event : Channel(Message)
      @event.subscribe(@ctx)
    end

    private def init_events
      # TODO: implement event initialization
    end
  end

  # TargetInfo represents a browser target.
  struct TargetInfo
    property target_id : Proto::Target::TargetID
    property session_id : Proto::Target::SessionID?
    property page : Page?

    def initialize(@target_id, @session_id = nil, @page = nil)
    end
  end

  # Message represents a CDP event message.
  class Message
    property session_id : Proto::Target::SessionID?
    property method : String
    property lock : Mutex
    property data : JSON::Any?

    def initialize(@session_id, @method, @data = nil)
      @lock = Mutex.new
    end
  end

  # EFunc is an internal function type.
  alias EFunc = Proc(Proto::Target::TargetID, Page)
end