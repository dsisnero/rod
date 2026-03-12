require "./goob"
require "./gson"
require "http"
require "./context"
require "./lib/cdp"
require "./lib/proto"
require "./lib/defaults"
require "./lib/devices"
require "./lib/launcher"
require "./lib/utils"
require "./hijack"
require "../cdp/target/target"
require "../cdp/browser/browser"
require "../cdp/storage/storage"
require "../cdp/security/security"

module Rod
  # Browser implements these interfaces.
  class Browser < ::Cdp::Client
    include Cdp::Contextable

    # BrowserContextID is the id for incognito window
    property browser_context_id : BrowserContextID?

    @e : EFunc?
    property ctx : Context
    property sleeper : Proc(::Utils::Sleeper)
    @logger : ::Log
    @trace_logger : Rod::Lib::Utils::Log?
    @slow_motion : Time::Span
    @trace : Bool
    @monitor : String?
    @default_device : ::Rod::Lib::Devices::Device
    @control_url : String
    @client : Lib::Cdp::Client?
    @targets : Hash(String, TargetInfo)
    @targets_lock : Mutex
    @states : Hash(StateKey, JSON::Any)
    @states_lock : Mutex
    @event : Goob::Observable(Message)

    # CallbackInfo for event handling
    struct CallbackInfo
      property event_name : String
      property loader : Proc(JSON::Any, Cdp::Event)
      property callback : Proc(Cdp::Event, SessionID?, Bool?)

      def initialize(event_class : T.class, callback : Proc(Cdp::Event, SessionID?, U)) forall T, U
        @event_name = event_class.proto_event
        @loader = ->(data : JSON::Any) { event_class.from_json(Cdp.normalize_incoming(data).to_json).as(Cdp::Event) }
        @callback = ->(event : Cdp::Event, session_id : SessionID?) { callback.call(event, session_id).as(Bool?) }
      end
    end

    # New creates a browser instance.
    def initialize(@ctx : Context = Context.background, @sleeper = -> { ::Utils::Sleeper.new }, @logger = ::Defaults.logger, @slow_motion = ::Defaults.slow, @trace = ::Defaults.trace, @monitor = nil)
      @e = ->(err : Exception?) { raise err if err }
      @trace_logger = nil
      @default_device = ::Rod::Lib::Devices::LaptopWithMDPIScreen.landscape
      @control_url = ::Defaults.url
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
    def with_panic(fail : Proc(Exception, Nil)) : self
      new_obj = self.dup
      new_obj.panic_handler = fail
      new_obj
    end

    def panic_handler=(fail : Proc(Exception, Nil)) : Nil
      @e = Browser.gen_e(fail)
    end

    protected def e_handler=(handler : EFunc?) : EFunc?
      @e = handler
    end

    # Call implements Cdp::Client.
    def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
      client = @client
      raise "Browser not connected" unless client
      res = client.call(context, session_id, method, params)
      set_state(session_id.try { |sid| SessionID.new(sid) }, method, params)
      res
    end

    # ControlURL sets the remote debugging websocket URL.
    def control_url(url : String) : Browser
      @control_url = url
      self
    end

    # Client sets the cdp client.
    def client(c : Lib::Cdp::Client) : Browser
      @client = c
      self
    end

    # DefaultDevice sets the default emulation for new pages.
    def default_device(device : ::Rod::Lib::Devices::Device) : Browser
      @default_device = device
      self
    end

    # NoDefaultDevice clears default emulation.
    def no_default_device : Browser
      @default_device = ::Rod::Lib::Devices::Clear
      self
    end

    # Connect to browser via websocket URL.
    def connect(ws_url : String = "") : Nil
      if @client.nil?
        url = ws_url.empty? ? @control_url : ws_url
        url = ::Rod::Lib::Launcher::Launcher.new.launch if url.empty?

        ws = Lib::Cdp::WebSocket.new
        ws.connect(url)
        client = Lib::Cdp::Client.new(@logger)
        client.start(ws)
        @client = client
      elsif !@control_url.empty?
        raise "Browser.Client and Browser.ControlURL can't be set at the same time"
      end

      init_events

      if monitor_url = @monitor
        ::Rod::Lib::Launcher.open(serve_monitor(monitor_url))
      end

      Cdp::Target::SetDiscoverTargets.new(true, nil).call(self)
    end

    # Close the browser.
    def close : Nil
      if context_id = @browser_context_id
        Cdp::Target::DisposeBrowserContext.new(context_id.value).call(self)
      else
        Cdp::Browser::Close.new.call(self)
      end
    end

    # Incognito creates a new incognito browser context.
    def incognito : Browser
      res = Cdp::Target::CreateBrowserContext.new(nil, nil, nil, nil).call(self)
      incognito = dup
      incognito.browser_context_id = BrowserContextID.new(res.browser_context_id)
      incognito
    end

    # Page creates a new tab with optional navigation.
    def page(url : String = "about:blank") : Page
      req = Cdp::Target::CreateTarget.new(
        "about:blank",
        nil,
        nil,
        nil,
        nil,
        nil,
        @browser_context_id.try(&.value),
        nil,
        nil,
        nil,
        nil,
        nil,
        nil
      )
      target = req.call(self)
      target_id = TargetID.new(target.target_id)

      begin
        p = page_from_target(target_id)
        p.navigate(url) unless url.empty? || url == "about:blank"
        p
      rescue ex
        Cdp::Target::CloseTarget.new(target.target_id).call(self) rescue nil
        raise ex
      end
    end

    # Pages retrieves all visible page targets.
    def pages : Pages
      list = Cdp::Target::GetTargets.new(nil).call(self)
      page_list = [] of Page
      list.target_infos.each do |target|
        next unless target.type == "page"
        page_list << page_from_target(TargetID.new(target.target_id))
      end
      Pages.new(page_list)
    end

    # PageFromSession creates a page from session id.
    def page_from_session(session_id : SessionID) : Page
      page_ctx, _cancel = @ctx.with_cancel
      Page.new(self, TargetID.new(""), session_id, nil, page_ctx, @sleeper)
    end

    # PageFromTarget gets or creates a Page instance.
    def page_from_target(target_id : TargetID) : Page
      @targets_lock.synchronize do
        if info = @targets[target_id.value]?
          if page = info.page
            return page
          end
        end

        attach = Cdp::Target::AttachToTarget.new(target_id.value, true).call(self)
        sid = SessionID.new(attach.session_id)
        page_ctx, _cancel = @ctx.with_cancel
        page = Page.new(self, target_id, sid, FrameID.new(target_id.value), page_ctx, @sleeper)
        # Match Go rod: enable Page domain for newly attached pages to avoid
        # agent-not-enabled behavior for page-scoped commands.
        Cdp::Page::Enable.new(nil).call(page)

        unless @default_device.clear?
          if metrics = @default_device.metrics_emulation
            page.set_viewport(metrics)
          end
          @default_device.touch_emulation.call(page)
          if ua = @default_device.user_agent_emulation
            ua.call(page)
          end
        end

        @targets[target_id.value] = TargetInfo.new(target_id, sid, page)
        page
      end
    end

    # IgnoreCertErrors controls browser certificate handling.
    def ignore_cert_errors(enable : Bool) : Nil
      Cdp::Security::SetIgnoreCertificateErrors.new(enable).call(self)
    end

    # GetCookies returns browser cookies in current browser context.
    def get_cookies : Array(Cdp::Network::Cookie) # ameba:disable Naming/AccessorMethodName
      Cdp::Storage::GetCookies.new(@browser_context_id.try(&.value)).call(self).cookies
    end

    # SetCookies sets browser cookies. nil clears all cookies.
    def set_cookies(cookies : Array(Cdp::Network::CookieParam)? = nil) : Nil # ameba:disable Naming/AccessorMethodName
      if cookies.nil?
        Cdp::Storage::ClearCookies.new(@browser_context_id.try(&.value)).call(self)
      else
        Cdp::Storage::SetCookies.new(cookies, @browser_context_id.try(&.value)).call(self)
      end
    end

    # SetCookies accepts cookie list and converts to cookie params.
    def set_cookies(cookies : Array(Cdp::Network::Cookie)) : Nil # ameba:disable Naming/AccessorMethodName
      set_cookies(Cdp::Network.cookies_to_params(cookies))
    end

    # Headless detection mirrors Go rod: prefer command-line switches.
    # Fallback to product string when Browser.getBrowserCommandLine is unavailable.
    def headless? : Bool
      begin
        args = Cdp::Browser::GetBrowserCommandLine.new.call(self).arguments
        return args.any?(&.includes?("headless"))
      rescue
      end

      begin
        version.product.includes?("Headless")
      rescue
        false
      end
    end

    # WaitDownload waits for a matching completed download and returns metadata.
    def wait_download(dir : String) : Proc(Cdp::Browser::DownloadWillBeginEvent?)
      Cdp::Browser::SetDownloadBehavior.new(
        Cdp::Browser::SetDownloadBehaviorBehaviorAllowAndName,
        @browser_context_id.try(&.value),
        dir,
        nil
      ).call(self)

      start_event = uninitialized Cdp::Browser::DownloadWillBeginEvent?
      callbacks = {} of String => CallbackInfo
      callbacks[Cdp::Browser::DownloadWillBeginEvent.proto_event] = CallbackInfo.new(
        Cdp::Browser::DownloadWillBeginEvent,
        ->(event : Cdp::Event, _sid : SessionID?) do
          start_event = event.as(Cdp::Browser::DownloadWillBeginEvent)
          nil
        end
      )
      callbacks[Cdp::Browser::DownloadProgressEvent.proto_event] = CallbackInfo.new(
        Cdp::Browser::DownloadProgressEvent,
        ->(event : Cdp::Event, _sid : SessionID?) do
          progress = event.as(Cdp::Browser::DownloadProgressEvent)
          if start = start_event
            start.guid == progress.guid && progress.state == Cdp::Browser::DownloadProgressStateCompleted
          else
            false
          end
        end
      )
      wait = each_event(nil, callbacks)

      -> do
        begin
          wait.call
          start_event
        ensure
          Cdp::Browser::SetDownloadBehavior.new(
            Cdp::Browser::SetDownloadBehaviorBehaviorDefault,
            @browser_context_id.try(&.value),
            nil,
            nil
          ).call(self)
        end
      end
    end

    # Version info of the browser.
    def version : Cdp::Browser::GetVersionResult
      Cdp::Browser::GetVersion.new.call(self)
    end

    # EnableDomain and returns a restore function to restore previous state.
    def enable_domain(session_id : SessionID?, req : Cdp::Request) : Proc(Nil)
      key = StateKey.new(@browser_context_id, session_id, req.proto_req)
      enabled = @states_lock.synchronize { @states.has_key?(key) }
      unless enabled
        # Call enable request
        call(nil, session_id.try(&.value), req.proto_req, JSON.parse(req.to_json))
      end
      -> {
        unless enabled
          domain, _ = Cdp.parse_method_name(req.proto_req)
          call(nil, session_id.try(&.value), domain + ".disable", JSON::Any.new(nil))
        end
      }
    end

    # DisableDomain and returns a restore function to restore previous state.
    def disable_domain(session_id : SessionID?, req : Cdp::Request) : Proc(Nil)
      key = StateKey.new(@browser_context_id, session_id, req.proto_req)
      enabled = @states_lock.synchronize { @states.has_key?(key) }
      domain, _ = Cdp.parse_method_name(req.proto_req)

      if enabled
        call(nil, session_id.try(&.value), domain + ".disable", JSON::Any.new(nil))
      end

      -> {
        if enabled
          call(nil, session_id.try(&.value), req.proto_req, JSON.parse(req.to_json))
        end
      }
    end

    # SetState stores the params for a CDP method call.
    def set_state(session_id : SessionID?, method_name : String, params : JSON::Any) : Nil
      key = StateKey.new(@browser_context_id, session_id, method_name)
      @states_lock.synchronize { @states[key] = params }

      delete_key = case method_name
                   when "Emulation.clearDeviceMetricsOverride"
                     "Emulation.setDeviceMetricsOverride"
                   when "Emulation.clearGeolocationOverride"
                     "Emulation.setGeolocationOverride"
                   else
                     domain, name = Cdp.parse_method_name(method_name)
                     name == "disable" ? "#{domain}.enable" : nil
                   end

      delete_state(session_id, delete_key) if delete_key
    end

    # LoadState loads previously stored params for a CDP method call.
    # Returns true if state existed and params were loaded into the request object.
    def load_state(session_id : SessionID?, req : Cdp::Request) : Bool
      key = StateKey.new(@browser_context_id, session_id, req.proto_req)
      @states_lock.synchronize { @states.has_key?(key) }
    end

    # RemoveState deletes a state entry.
    def remove_state(key : StateKey) : Nil
      @states_lock.synchronize { @states.delete(key) }
    end

    private def delete_state(session_id : SessionID?, method_name : String) : Nil
      key = StateKey.new(@browser_context_id, session_id, method_name)
      @states_lock.synchronize { @states.delete(key) }
    end

    # Event of the browser.
    def event : Channel(Message)
      @event.subscribe(@ctx.done)
    end

    private def init_events
      client = @client
      raise "Browser not connected" unless client
      src = client.event
      done = @ctx.done
      spawn do
        loop do
          begin
            select
            when msg = src.receive
              session_id = msg.session_id.try { |sid| SessionID.new(sid) }
              @event.publish(Message.new(session_id, msg.method, msg.params))
            when done.receive?
              break
            end
          rescue Channel::ClosedError
            break
          end
        end
      end
    end

    # Context returns a clone with the specified ctx for chained sub-operations.
    def context(ctx : Context) : Browser
      new_obj = dup
      new_obj.ctx = ctx
      new_obj
    end

    # Context accessor of current instance.
    def current_context : Context
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
      new_obj = dup
      new_obj.sleeper = sleeper
      new_obj
    end

    def each_event(session_id : SessionID?, callbacks : Hash(String, CallbackInfo)) : Proc(Nil)
      restores = [] of ->

      # Enable domains for each event type if not already enabled
      callbacks.each_key do |event_name|
        domain, _ = Cdp.parse_method_name(event_name)
        begin
          call(nil, session_id.try(&.value), domain + ".enable", JSON::Any.new({} of String => JSON::Any))
          restores << -> { call(nil, session_id.try(&.value), domain + ".disable", JSON::Any.new({} of String => JSON::Any)) }
        rescue
          # Some domains may not support explicit enable/disable.
        end
      end

      browser, cancel = with_cancel
      messages = browser.event
      used = false

      -> {
        if used
          raise "can't use wait function twice"
        end
        used = true

        begin
          loop do
            select
            when msg = messages.receive?
              break unless msg
              next unless session_id.nil? || msg.session_id == session_id

              if cb_info = callbacks[msg.method]?
                event_data = msg.data || JSON::Any.new({} of String => JSON::Any)
                event = cb_info.loader.call(event_data)
                result = cb_info.callback.call(event, msg.session_id)
                if !result.nil? && result == true
                  return
                end
              end
            when _ = browser.ctx.done.receive?
              break
            end
          end
        ensure
          cancel.call
          restores.each do |restore|
            begin
              restore.call
            rescue
              # Best-effort cleanup: domain disable failures should not fail waits.
            end
          end
        end
      }
    end

    # EachEvent is similar to Page.EachEvent, but catches events of the entire browser.
    macro eachevent(*callbacks)
      {% begin %}
        begin
          cb_map = {} of String => CallbackInfo
          {% for cb in callbacks %}
            {% unless cb.is_a?(ProcLiteral) %}
              {% raise "EachEvent expects proc literals, got: #{cb.class_name}" %}
            {% end %}
            {% num_args = cb.args.size %}
            {% if num_args < 1 || num_args > 2 %}
              {% raise "EachEvent callback must have 1 or 2 arguments" %}
            {% end %}
            {% event_t = cb.args[0].restriction %}
            {% if event_t.nil? %}
              {% raise "EachEvent callback first argument must have an explicit event type restriction" %}
            {% end %}
            {% if event_t.is_a?(Union) %}
              {% non_nil = event_t.types.reject(&.==(Nil)).first %}
              {% event_t = non_nil %}
            {% end %}
            {% event_class = event_t.resolve %}
            {% if num_args == 1 %}
              # Original callback takes event only
              wrapper = ->(event : Cdp::Event, session_id : Rod::SessionID?) do
                typed_event = event.as({{event_class}})
                {{cb}}.call(typed_event)
              end
            {% elsif num_args == 2 %}
              # Original callback takes event and session_id
              wrapper = ->(event : Cdp::Event, session_id : Rod::SessionID?) do
                typed_event = event.as({{event_class}})
                {{cb}}.call(typed_event, session_id)
              end
            {% else %}
              {% raise "EachEvent callback must have 1 or 2 arguments" %}
            {% end %}
            cb_map[{{event_class}}.proto_event] = CallbackInfo.new(
              {{event_class}},
              wrapper
            )
          {% end %}
          each_event(nil, cb_map)
        end
      {% end %}
    end

    # EachEvent public API with uppercase name
    # def "EachEvent"(*callbacks)
    #   eachevent(*callbacks)
    # end

    # WaitEvent waits for the next event once.
    # For typed event access use wait_event_typed.
    def wait_event(e : Cdp::Event, session_id : SessionID? = nil) : Proc(Nil)
      wait = wait_event_typed(e.class, session_id)
      -> { wait.call; nil }
    end

    # WaitEventTyped waits for the next event once and returns the matched event payload.
    def wait_event_typed(event_class : T.class, session_id : SessionID? = nil) : Proc(T) forall T
      domain, _ = Cdp.parse_method_name(event_class.proto_event)
      begin
        call(nil, session_id.try(&.value), domain + ".enable", JSON::Any.new({} of String => JSON::Any))
      rescue
        # Some domains don't require explicit enabling.
      end

      browser, cancel = with_cancel
      messages = browser.event
      -> do
        begin
          loop do
            select
            when msg = messages.receive?
              raise "event channel closed while waiting for event #{event_class.proto_event}" unless msg
              next unless session_id.nil? || msg.session_id == session_id
              if msg.method == event_class.proto_event
                json_data = msg.data || JSON::Any.new({} of String => JSON::Any)
                return event_class.from_json(json_data.to_json).as(T)
              end
            when _ = browser.ctx.done.receive?
              raise "context canceled while waiting for event #{event_class.proto_event}"
            end
          end
        ensure
          cancel.call
          begin
            call(nil, session_id.try(&.value), domain + ".disable", JSON::Any.new({} of String => JSON::Any))
          rescue
            # Best-effort cleanup.
          end
        end
      end
    end

    private def page_info(id : TargetID) : Cdp::Target::TargetInfo
      Cdp::Target::GetTargetInfo.new(id.value).call(self).target_info
    end

    # HijackRequests same as Page.HijackRequests, but can intercept requests of the entire browser.
    def hijack_requests : HijackRouter
      HijackRouter.new(self, self).init_events
    end

    # HandleAuth for the next basic HTTP authentication.
    # It will prevent the popup that requires user to input user name and password.
    # Ref: https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication
    def handle_auth(username : String, password : String) : Proc(Exception?)
      # First disable fetch domain (stop any existing hijacking)
      disable_fetch = Cdp::Fetch::Disable.new
      disable_fetch.call(self)

      # Enable fetch domain with auth handling
      enable_auth = Cdp::Fetch::Enable.new(nil, true)
      enable_auth.call(self)

      ctx, cancel = @ctx.with_cancel
      browser_with_ctx = context(ctx)
      wait_paused = browser_with_ctx.wait_event_typed(Cdp::Fetch::RequestPausedEvent)
      wait_auth = browser_with_ctx.wait_event_typed(Cdp::Fetch::AuthRequiredEvent)

      -> do
        begin
          # Wait for request paused event
          paused_event = wait_paused.call

          # Continue the request (to trigger auth challenge)
          continue_req = Cdp::Fetch::ContinueRequest.new(paused_event.request_id, nil, nil, nil, nil, nil)
          continue_req.call(self)

          # Wait for auth required event
          auth_event = wait_auth.call

          # Respond with credentials
          auth_response = Cdp::Fetch::AuthChallengeResponse.new(
            Cdp::Fetch::AuthChallengeResponseResponseProvideCredentials,
            username,
            password
          )

          continue_auth_req = Cdp::Fetch::ContinueWithAuth.new(
            auth_event.request_id,
            auth_response
          )

          continue_auth_req.call(self)

          # Clean up
          cancel.call
          disable_fetch.call(self) # Disable auth handling

          nil # No error
        rescue ex
          # Ensure cleanup even on error
          cancel.call
          disable_fetch.call(self) rescue nil
          ex
        end
      end
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
    def load(event_class : Class) : Cdp::Event?
      klass = event_class.as(Cdp::Event.class)
      return nil unless method == klass.proto_event
      json_data = data || JSON::Any.new({} of String => JSON::Any)
      klass.from_json(json_data.to_json).as(Cdp::Event)
    end

    # Typed load helper for concrete event classes.
    def load(event_class : T.class) : T? forall T
      return nil unless method == event_class.proto_event
      json_data = data || JSON::Any.new({} of String => JSON::Any)
      event_class.from_json(json_data.to_json).as(T)
    end

    # Load event data into the given event instance (must be of correct type).
    # Returns true if the method matches and data was loaded.
    def load(event : Cdp::Event) : Bool
      return false unless method == event.proto_event
      # Since event is a struct, we cannot modify it directly.
      # Instead, create a new instance and copy fields? Not needed for now.
      # This method is kept for compatibility with Go API.
      true
    end
  end

  class Browser
    # Generate an EFunc with the specified fail function.
    # If the error is not nil, the fail function will be called.
    def self.gen_e(fail : Proc(Exception, Nil)) : EFunc
      ->(err : Exception?) do
        if err
          fail.call(err)
        end
      end
    end
  end

  # EFunc is an internal function type for error handling.
  alias EFunc = Proc(Exception?, Nil)
end
