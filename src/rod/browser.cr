require "goob"
require "gson"
require "http"
require "./context"
require "./lib/cdp"
require "./lib/proto"
require "./lib/defaults"
require "./lib/devices"
require "./lib/launcher"
require "./lib/utils"

module Rod
  # Browser implements these interfaces.
  class Browser < ::Cdp::Client
    include Cdp::Contextable

    # BrowserContextID is the id for incognito window
    property browser_context_id : BrowserContextID?

    @e : EFunc?
    property ctx : Context
    @sleeper : Proc(::Utils::Sleeper)
    @logger : ::Log
    @slow_motion : Time::Span
    @trace : Bool
    @monitor : String?
    @client : Lib::Cdp::Client?
    @targets : Hash(String, TargetInfo)
    @targets_lock : Mutex
    @event : Goob::Observable(Message)

    # New creates a browser instance.
    def initialize(@ctx : Context = Context.background, @sleeper = -> { ::Utils::Sleeper.new }, @logger = ::Defaults.logger, @slow_motion = ::Defaults.slow, @trace = ::Defaults.trace, @monitor = nil)
      @e = nil
      @targets = {} of String => TargetInfo
      @targets_lock = Mutex.new
      @event = Goob::Observable(Message).new(ctx)
    end

    # Context implements Cdp::Contextable.
    def context : HTTP::Client::Context?
      @ctx
    end

    # Call implements Cdp::Client.
    def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
      client = @client
      raise "Browser not connected" unless client
      client.call(context, session_id, method, params)
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

    # Context returns a clone with the specified ctx for chained sub-operations.
    def context(ctx : Context) : Browser
      new_obj = self.clone
      new_obj.ctx = ctx
      new_obj
    end

    # GetContext of current instance.
    # ameba:disable Naming/AccessorMethodName
    def get_context : Context
      @ctx
    end

    # Timeout returns a clone with the specified total timeout of all chained sub-operations.
    def timeout(d : Time::Span) : Browser
      ctx, cancel = @ctx.with_timeout(d)
      val = TimeoutContextVal.new(@ctx, cancel)
      ctx_with_val = ctx.with_value(TIMEOUT_KEY, val)
      context(ctx_with_val)
    end

    # CancelTimeout cancels the current timeout context and returns a clone with the parent context.
    def cancel_timeout : Browser
      val = @ctx.value(TIMEOUT_KEY).as?(TimeoutContextVal)
      raise "no timeout context to cancel" unless val
      val.cancel.call
      context(val.parent)
    end

    # WithCancel returns a clone with a context cancel function.
    def with_cancel : Tuple(Browser, ->)
      ctx, cancel = @ctx.with_cancel
      {context(ctx), cancel}
    end

    # Sleeper returns a clone with the specified sleeper for chained sub-operations.
    def sleeper(sleeper : Proc(::Utils::Sleeper)) : Browser
      new_obj = self.clone
      new_obj.sleeper = sleeper
      new_obj
    end
  end

  # TargetInfo represents a browser target.
  struct TargetInfo
    property target_id : TargetID
    property session_id : SessionID?
    property page : Page?

    def initialize(@target_id, @session_id = nil, @page = nil)
    end
  end

  # Message represents a CDP event message.
  class Message
    property session_id : SessionID?
    property method : String
    property lock : Mutex
    property data : JSON::Any?

    def initialize(@session_id, @method, @data = nil)
      @lock = Mutex.new
    end
  end

  # EFunc is an internal function type.
  alias EFunc = Proc(TargetID, Page)
end
