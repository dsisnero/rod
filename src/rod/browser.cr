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
      property event_class : Cdp::Event.class
      property callback : Proc(Cdp::Event, SessionID?, Bool?)

      def initialize(@event_class, @callback)
      end
    end

    # New creates a browser instance.
    def initialize(@ctx : Context = Context.background, @sleeper = -> { ::Utils::Sleeper.new }, @logger = ::Defaults.logger, @slow_motion = ::Defaults.slow, @trace = ::Defaults.trace, @monitor = nil)
      @e = ->(err : Exception?) { raise err if err }
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
    def with_panic(fail : Proc(Exception, Nil)) : Browser
      new_obj = dup
      new_obj.instance_variable_set("@e", Browser.gen_e(fail))
      new_obj
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
      Page.new(self, TargetID.new(""), session_id, nil, @ctx, @sleeper)
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
        page = Page.new(self, target_id, sid, FrameID.new(target_id.value), @ctx, @sleeper)

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
      params = cookies.map { |cookie| Cdp::Network::CookieParam.from_json(cookie.to_json) }
      set_cookies(params)
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
      wait = eachevent(
        ->(e : Cdp::Browser::DownloadWillBeginEvent) { start_event = e },
        ->(e : Cdp::Browser::DownloadProgressEvent) {
          if start = start_event
            start.guid == e.guid && e.state == Cdp::Browser::DownloadProgressStateCompleted
          else
            false
          end
        }
      )

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
      # ameba:disable Lint/NotNil
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
      new_obj = dup
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
      new_obj = dup
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
        }
      \{% end %}
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
      matched = uninitialized T?
      cb = ->(event : Cdp::Event, _sid : SessionID?) do
        matched = event.as(T)
        true
      end
      wait = each_event(session_id, {event_class.proto_event => CallbackInfo.new(event_class, cb)})

      -> do
        wait.call
        if event = matched
          event
        else
          raise "event callback completed without payload"
        end
      end
    end

    private def page_info(id : TargetID) : Cdp::Target::TargetInfo
      Cdp::Target::GetTargetInfo.new(id.value).call(self).target_info
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
      # Since event is a struct, we cannot modify it directly.
      # Instead, create a new instance and copy fields? Not needed for now.
      # This method is kept for compatibility with Go API.
      true
    end
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
    enable_auth = Cdp::Fetch::Enable.new(handle_auth_requests: true)
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
        continue_req = Cdp::Fetch::ContinueRequest.new(request_id: paused_event.request_id)
        continue_req.call(self)

        # Wait for auth required event
        auth_event = wait_auth.call

        # Respond with credentials
        auth_response = Cdp::Fetch::AuthChallengeResponse.new(
          response: Cdp::Fetch::AuthChallengeResponseResponseProvideCredentials,
          username: username,
          password: password
        )

        continue_auth_req = Cdp::Fetch::ContinueWithAuth.new(
          request_id: auth_event.request_id,
          auth_challenge_response: auth_response
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
