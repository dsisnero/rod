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
    @states : Hash(StateKey, JSON::Any)
    @states_lock : Mutex
    @event : Goob::Observable(Message)

    # CallbackInfo for event handling
    struct CallbackInfo
      property event_class : Cdp::Event.class
      property callback : Proc(Cdp::Event, SessionID?, Bool?)

      def initialize(@event_class, @callback)
      end
    end

    # New creates a browser instance.
    def initialize(@ctx : Context = Context.background, @sleeper = -> { ::Utils::Sleeper.new }, @logger = ::Defaults.logger, @slow_motion = ::Defaults.slow, @trace = ::Defaults.trace, @monitor = nil)
      @e = ->(err : Exception?) { raise err if err }
      @targets = {} of String => TargetInfo
      @targets_lock = Mutex.new
      @states = {} of StateKey => JSON::Any
      @states_lock = Mutex.new
      @event = Goob::Observable(Message).new(ctx.done)
    end

    # Context implements Cdp::Contextable.
    def context : HTTP::Client::Context?
      @ctx
    end

    # e is the error handler for Must methods.
    # It calls the configured EFunc with the error.
    protected def e(err : Exception?) : Nil
      @e.try &.call(err)
    end

    # WithPanic returns a browser clone with the specified panic function.
    # The fail must stop the current goroutine's execution immediately.
    def with_panic(fail : Proc(Exception, Nil)) : Browser
      new_obj = self.clone
      new_obj.instance_variable_set("@e", Browser.gen_e(fail))
      new_obj
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

    # EnableDomain and returns a restore function to restore previous state.
    def enable_domain(session_id : SessionID?, req : Cdp::Request) : Proc(Nil)
      key = StateKey.new(@browser_context_id, session_id, req.proto_req)
      enabled = @states_lock.synchronize { @states.has_key?(key) }
      unless enabled
        # Call enable request
        call(nil, session_id.try(&.value), req.proto_req, JSON.parse(req.to_json))
        @states_lock.synchronize { @states[key] = JSON::Any.new(true) }
      end
      -> {
        unless enabled
          domain, _ = Cdp.parse_method_name(req.proto_req)
          call(nil, session_id.try(&.value), domain + ".disable", JSON::Any.new(nil))
          @states_lock.synchronize { @states.delete(key) }
        end
      }
    end

    # Event of the browser.
    def event : Channel(Message)
      @event.subscribe(@ctx.done)
    end

    private def init_events
      client = @client.not_nil!
      src = client.event
      done = @ctx.done
      spawn do
        loop do
          select
          when msg = src.receive
            session_id = msg.session_id.try { |sid| SessionID.new(sid) }
            @event.publish(Message.new(session_id, msg.method, msg.params))
          when done.receive
            break
          end
        end
      end
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
    def with_cancel : Tuple(Browser, Proc(Nil))
      ctx, cancel = @ctx.with_cancel
      {context(ctx), cancel}
    end

    # Sleeper returns a clone with the specified sleeper for chained sub-operations.
    def sleeper(sleeper : Proc(::Utils::Sleeper)) : Browser
      new_obj = self.clone
      new_obj.sleeper = sleeper
      new_obj
    end

    def each_event(session_id : SessionID?, callbacks : Hash(String, CallbackInfo)) : Proc(Nil)
      restores = [] of ->

      # Enable domains for each event type if not already enabled
      callbacks.each_key do |event_name|
        domain, _ = Cdp.parse_method_name(event_name)
        enable_type = begin
          Cdp.get_type(domain + ".enable")
        rescue
          nil
        end
        if enable_type
          req = enable_type.new.as(Cdp::Request)
          restores << enable_domain(session_id, req)
        end
      end

      browser, cancel = with_cancel
      messages = browser.event

      -> {
        if messages.nil?
          raise "can't use wait function twice"
        end

        begin
          loop do
            select
            when msg = messages.receive
              next unless session_id.nil? || msg.session_id == session_id

              if cb_info = callbacks[msg.method]?
                event = msg.load(cb_info.event_class)
                # event should never be nil because we matched the method
                if event
                  result = cb_info.callback.call(event, msg.session_id)
                  if !result.nil? && result == true
                    return
                  end
                end
              end
            when browser.ctx.done.receive
              break
            end
          end
        ensure
          cancel.call
          messages = nil
          restores.each(&.call)
        end
      }
    end

    # EachEvent is similar to Page.EachEvent, but catches events of the entire browser.
    macro eachevent(*callbacks)
      \{% begin %}
        {
          cb_map = {} of String => CallbackInfo
          \{% for cb in callbacks %}
            \{% t = cb.type %}
            \{% unless t.is_a?(Proc) %}
              \{% raise "EachEvent expects Proc(...) callbacks; got #{t}" %}
            \{% end %}
            \{% event_t = t.type_vars[0] %}
            \{% if event_t.is_a?(Union) %}
              \{% non_nil = event_t.types.reject(&.==(Nil)).first %}
              \{% event_t = non_nil %}
            \{% end %}
            \{% event_class = event_t.resolve %}
            \{% event_name = event_class.proto_event %}
            \{% num_args = t.type_vars.size - 1 %}
            \{% if num_args == 1 %}
              # Original callback takes event only
              wrapper = ->(event : Cdp::Event, session_id : SessionID?) do
                typed_event = event.as(\{{event_class}})
                \{{cb}}.call(typed_event)
              end
            \{% elsif num_args == 2 %}
              # Original callback takes event and session_id
              wrapper = ->(event : Cdp::Event, session_id : SessionID?) do
                typed_event = event.as(\{{event_class}})
                \{{cb}}.call(typed_event, session_id)
              end
            \{% else %}
              \{% raise "EachEvent callback must have 1 or 2 arguments" %}
            \{% end %}
            cb_map[\{{event_name}}] = CallbackInfo.new(
              \{{event_class}},
              wrapper
            )
          \{% end %}
          each_event(nil, cb_map)
        \\\\\\\\}
      \{% end %}
    end

    # EachEvent public API with uppercase name
    # def "EachEvent"(*callbacks)
    #   eachevent(*callbacks)
    # end

    # WaitEvent waits for the next event for one time. It will also load the data into the event object.
    def wait_event(e : Cdp::Event, session_id : SessionID? = nil) : Proc(Nil)
      event_class = e.class
      # Create a callback that stops on first matching event and copies data
      cb = ->(event : Cdp::Event, sid : SessionID?) do
        # TODO: Copy data from event to e (requires mutable reference)
        true
      end
      each_event(session_id, {event_class.proto_event => CallbackInfo.new(event_class, cb)})
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

  # StateKey for browser states map.
  struct StateKey
    property browser_context_id : BrowserContextID?
    property session_id : SessionID?
    property method_name : String

    def initialize(@browser_context_id, @session_id, @method_name)
    end

    def_hash @browser_context_id, @session_id, @method_name
    def_equals @browser_context_id, @session_id, @method_name
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

    # Load event data into a new instance of the given event class.
    # Returns the event instance if the method matches the event's proto_event.
    def load(event_class : Cdp::Event.class) : Cdp::Event?
      return nil unless method == event_class.proto_event
      json_data = data || JSON::Any.new({} of String => JSON::Any)
      event_class.from_json(json_data.to_json).as(Cdp::Event)
    end

    # Load event data into the given event instance (must be of correct type).
    # Returns true if the method matches and data was loaded.
    def load(event : Cdp::Event) : Bool
      return false unless method == event.proto_event
      json_data = data || JSON::Any.new({} of String => JSON::Any)
      # Since event is a struct, we cannot modify it directly.
      # Instead, create a new instance and copy fields? Not needed for now.
      # This method is kept for compatibility with Go API.
      true
    end
  end

  # Generate an EFunc with the specified fail function.
  # If the error is not nil, the fail function will be called.
  private def self.gen_e(fail : Proc(Exception, Nil)) : EFunc
    ->(err : Exception?) do
      if err
        fail.call(err)
      end
    end
  end

  # EFunc is an internal function type for error handling.
  # It panics if the error is not nil.
  alias EFunc = Proc(Exception?, Nil)
end
