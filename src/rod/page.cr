require "./browser"
require "./types"
require "./query"
require "./keyboard"
require "./mouse"
require "./touch"
require "./lib/js"
require "../cdp/cdp"
require "../cdp/runtime/runtime"

module Rod
  # QueryOptions provides configuration for element queries.
  # Controls timeout, retry behavior, and element visibility requirements.
  struct QueryOptions
    # Maximum time to wait for element
    property timeout : Time::Span

    # Interval between retries
    property retry_interval : Time::Span

    # Wait for element to be visible
    property? visible : Bool

    # Wait for element to be enabled
    property? enabled : Bool

    def initialize(
      @timeout : Time::Span = 5.seconds,
      @retry_interval : Time::Span = 100.milliseconds,
      @visible : Bool = false,
      @enabled : Bool = false,
    )
    end
  end

  # EvalOptions for Page.Evaluate.
  struct EvalOptions
    alias JsArg = ::JSON::Any | JS::Function | ::Cdp::Runtime::RemoteObject

    # If enabled the eval result will be a plain JSON value.
    # If disabled the eval result will be a reference of a remote js object.
    property? by_value : Bool

    property? await_promise : Bool

    # ThisObj represents the "this" object in the JS
    property this_obj : ::Cdp::Runtime::RemoteObject?

    # JS function definition to execute.
    property js : String

    # JSArgs represents the arguments that will be passed to JS.
    property js_args : Array(JsArg)

    # Whether execution should be treated as initiated by user in the UI.
    property? user_gesture : Bool

    def initialize(
      @by_value : Bool = true,
      @await_promise : Bool = false,
      @this_obj : ::Cdp::Runtime::RemoteObject? = nil,
      @js : String = "",
      @js_args : Array(JsArg) = [] of JsArg,
      @user_gesture : Bool = false,
    )
    end

    # Set the obj as ThisObj.
    def this(obj : ::Cdp::Runtime::RemoteObject) : EvalOptions
      @this_obj = obj
      self
    end

    # Disable ByValue.
    def by_object : EvalOptions
      @by_value = false
      self
    end

    # Enable UserGesture.
    def by_user : EvalOptions
      @user_gesture = true
      self
    end

    # Enable AwaitPromise.
    def by_promise : EvalOptions
      @await_promise = true
      self
    end

    # Format JS function for CallFunctionOn.
    def format_to_js_func : String
      js = @js.strip(" \t\n\v\f\r;")
      "function() { return (#{js}).apply(this, arguments) }"
    end

    # String representation for debugging.
    def to_s(io : IO) : Nil
      fn = @js
      args = @js_args
      params_str = ""
      this_str = ""

      if this_obj = @this_obj
        this_str = this_obj.description.to_s
      end

      if !args.empty?
        if args.first.is_a?(JS::Function)
          f = args.first.as(JS::Function)
          fn = "rod." + f.name
          args = args[1..]
        end

        params_str = args.to_json.strip("[]\r\n")
      end

      io << fn << "(" << params_str << ") " << this_str
    end
  end

  class Page < ::Cdp::Client
    include ::Cdp::Contextable
    include ::Cdp::Sessionable
    alias JS = Rod::JS

    # JavaScript context ID for function caching
    @js_ctx_id : String? = nil
    @js_ctx_lock = Mutex.new

    # Cached helper functions: js_context_id -> {function_name -> remote_object_id}
    @helpers : Hash(String, Hash(String, String))? = nil
    @helpers_lock = Mutex.new

    property browser : Browser
    property target_id : TargetID
    property session_id : SessionID?
    property frame_id : FrameID?
    property ctx : Nil
    property keyboard : Keyboard?
    property mouse : Mouse?
    property touch : Touch?
    property element : Element?

    # IsIframe tells if it's iframe.
    def iframe? : Bool
      !@element.nil?
    end

    # Sleeper for retry logic
    @sleeper : Proc(Rod::Utils::Sleeper)

    def keyboard : Keyboard
      @keyboard ||= Keyboard.new(self)
    end

    def mouse : Mouse
      @mouse ||= Mouse.new(self)
    end

    def touch : Touch
      @touch ||= Touch.new(self)
    end

    # InsertText is like pasting text into the page.
    def insert_text(text : String) : Nil
      event = Cdp::Input::InsertText.new(text: text)
      event.call(self)
    end

    # StopLoading stops loading the page.
    def stop_loading : Nil
      Cdp::Page::StopLoading.new.call(self)
    end

    def initialize(@browser, @target_id, @session_id = nil, @frame_id = nil, @ctx = nil, @sleeper = -> { Rod::Utils::Sleeper.new }, @element = nil)
    end

    # Retry a block that may raise NotFoundError until it succeeds or timeout expires.
    private def retry_finding(timeout : Time::Span, interval : Time::Span, &block : -> T) : T forall T
      start_time = Time.monotonic
      loop do
        begin
          return block.call
        rescue NotFoundError
          elapsed = Time.monotonic - start_time
          if elapsed >= timeout
            raise NotFoundError.new("Element not found within #{timeout}")
          end
          sleep(interval)
        end
      end
    end

    # Check if element matches QueryOptions (visible/enabled requirements)
    private def element_matches_options?(element : Element, opts : QueryOptions) : Bool
      return true unless opts.visible? || opts.enabled?

      if opts.visible? && !element.visible?
        return false
      end

      if opts.enabled? && !element.enabled?
        return false
      end

      true
    end

    # Call implements Cdp::Client.
    def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
      browser.call(context, session_id, method, params)
    end

    # Context implements Cdp::Contextable.
    def context : Nil
      @ctx # ameba:disable Lint/UnusedExpression
    end

    # Sessionable implementation
    def session_id : String?
      @session_id.try(&.value)
    end

    # Navigate to URL.
    def navigate(url : String) : Nil
      if url.empty?
        url = "about:blank"
      end

      # try to stop loading
      stop_loading

      res = Cdp::Page::Navigate.new(url: url, referrer: nil, transition_type: nil, frame_id: nil, referrer_policy: nil).call(self)
      if error_text = res.error_text
        raise NavigationError.new(error_text)
      end

      unset_js_ctx_id
    end

    # Reload page.
    def reload : Nil
      # TODO: implement proper wait for navigation event (rod-edo)
      # For now use CDP reload (doesn't work for iframes)
      Cdp::Page::Reload.new.call(self)
      unset_js_ctx_id
    end

    # Navigate back in history.
    def back : Nil
      evaluate(eval_opts("() => history.back()").by_user)
    end

    # Navigate forward in history.
    def forward : Nil
      evaluate(eval_opts("() => history.forward()").by_user)
    end

    # GetNavigationHistory returns navigation history entries.
    def navigation_history : Cdp::Page::GetNavigationHistoryResult
      Cdp::Page::GetNavigationHistory.new.call(self)
    end

    # ResetNavigationHistory resets navigation history.
    def reset_navigation_history : Nil
      Cdp::Page::ResetNavigationHistory.new.call(self)
    end

    # Evaluate JavaScript.
    def evaluate(js : String, args : Array(JSON::Any)? = nil) : ::Cdp::Runtime::RemoteObject
      eval(js, args || [] of JSON::Any)
    end

    # Check if element exists matching the CSS selector.
    # Returns tuple of {found, element} where element is nil if not found.
    def has(selector : String) : Tuple(Bool, Element?)
      el = element(selector)
      {true, el}
    rescue NotFoundError
      {false, nil}
    end

    # Convenience method - just check existence without returning element.
    def has_element?(selector : String) : Bool
      has(selector)[0]
    end

    # Check if element exists matching the XPath selector.
    # Returns tuple of {found, element} where element is nil if not found.
    def has_x(xpath : String) : Tuple(Bool, Element?)
      el = element_x(xpath)
      {true, el}
    rescue NotFoundError
      {false, nil}
    end

    # Check if element exists matching the CSS selector and text regex.
    # Returns tuple of {found, element} where element is nil if not found.
    def has_r(selector : String, regex : String) : Tuple(Bool, Element?)
      el = element_r(selector, regex)
      {true, el}
    rescue NotFoundError
      {false, nil}
    end

    # Find single element by CSS selector.
    # Raises NotFoundError if element not found within timeout.
    def element(selector : String, opts : QueryOptions? = nil) : Element
      opts ||= QueryOptions.new
      element_by_css(selector, opts)
    end

    # Find single element by CSS selector, returns nil if not found.
    def element_optional(selector : String, opts : QueryOptions? = nil) : Element?
      element(selector, opts)
    rescue NotFoundError
      nil
    end

    # Find all elements matching CSS selector.
    # Returns empty Elements if none found.
    def elements(selector : String, opts : QueryOptions? = nil) : Elements
      opts ||= QueryOptions.new
      elements_by_css(selector, opts)
    end

    # Find single element by XPath selector.
    # Raises NotFoundError if element not found within timeout.
    def element_x(xpath : String, opts : QueryOptions? = nil) : Element
      opts ||= QueryOptions.new
      element_by_xpath(xpath, opts)
    end

    # Find all elements matching XPath selector.
    # Returns empty Elements if none found.
    def elements_x(xpath : String, opts : QueryOptions? = nil) : Elements
      opts ||= QueryOptions.new
      elements_by_xpath(xpath, opts)
    end

    # Find single element by CSS selector with text matching regex.
    # Raises NotFoundError if element not found within timeout.
    def element_r(selector : String, regex : String, opts : QueryOptions? = nil) : Element
      opts ||= QueryOptions.new
      element_by_regex(selector, regex, opts)
    end

    # Eval is a shortcut for Page.Evaluate with AwaitPromise, ByValue set to true.
    def eval(js : String, args : Array(::JSON::Any) = [] of ::JSON::Any) : ::Cdp::Runtime::RemoteObject
      opts = EvalOptions.new(js: js, js_args: args, await_promise: true, by_value: true)
      evaluate(opts)
    end

    # Evaluate js on the page.
    def evaluate(opts : EvalOptions) : ::Cdp::Runtime::RemoteObject
      # Simple exponential backoff sleeper similar to Go's utils.BackoffSleeper
      backoff = BackoffSleeper.new(30.milliseconds, 3.seconds)

      loop do
        begin
          return evaluate_internal(opts)
        rescue ex : ::Rod::Lib::Cdp::Error
          # Check if error is context not found
          if ctx_not_found_error?(ex)
            if opts.this_obj
              raise NotFoundError.new("Object not found: #{opts.this_obj}")
            end

            # Wait before retry
            backoff.sleep
            unset_js_ctx_id
            next
          end
          # Other CDP errors: re-raise
          raise ex
        rescue ex
          # Any other exception (non-CDP) re-raise
          raise ex
        end
      end
    end

    # Simple exponential backoff sleeper for retry logic
    private class BackoffSleeper
      def initialize(@initial : Time::Span, @max : Time::Span)
        @current = @initial
      end

      def sleep : Nil
        sleep_duration = @current
        # Increase for next time (exponential with jitter)
        @current = (@current * 2).clamp(@initial, @max)
        ::sleep(sleep_duration)
      end
    end

    # eval_helper creates EvalOptions for a JS helper function.
    private def eval_helper(fn : JS::Function, *args) : EvalOptions
      js_args = [fn.as(EvalOptions::JsArg)] + args.map { |arg| ::JSON::Any.new(arg).as(EvalOptions::JsArg) }
      js = "function (f /* #{fn.name} */, ...args) { return f.apply(this, args) }"
      EvalOptions.new(
        js: js,
        js_args: js_args,
        by_value: true
      )
    end

    # eval_opts creates an EvalOptions with ByValue set to true (similar to Go's Eval).
    def eval_opts(js : String, *args) : EvalOptions
      js_args = args.map { |arg| ::JSON::Any.new(arg).as(EvalOptions::JsArg) }
      EvalOptions.new(js: js, js_args: js_args, by_value: true)
    end

    # Expose fn to the page's window object with the name. The exposure survives reloads.
    # Call stop to unbind the fn.
    def expose(name : String, fn : Proc(::JSON::Any, ::JSON::Any)) : Proc(Nil)
      # TODO: Implement expose functionality (requires event system)
      raise NotImplementedError.new("Page#expose not yet implemented")
    end

    # element_by_js returns the element from the return value of the js function.
    def element_by_js(opts : EvalOptions) : Element
      # Evaluate with by_object to get remote object reference
      eval_opts = opts.by_object
      res = evaluate(eval_opts)
      # Check if result is null or undefined
      if res.type == "undefined" || res.type == "null" || res.subtype == "null"
        raise NotFoundError.new("Element not found via JavaScript")
      end
      # Ensure result is an object with object_id
      unless res.object_id
        raise "JavaScript did not return an element object (type: #{res.type})"
      end
      # Ensure it's a DOM node
      unless res.subtype == "node"
        raise "JavaScript did not return a DOM node (subtype: #{res.subtype})"
      end
      Element.new(res, self)
    end

    # elements_by_js returns the elements from the return value of the js.
    def elements_by_js(opts : EvalOptions) : Elements
      # Evaluate with by_object to get remote object reference
      eval_opts = opts.by_object
      res = evaluate(eval_opts)

      # Ensure result is an array
      unless res.subtype == "array"
        raise "JavaScript did not return an array (subtype: #{res.subtype})"
      end

      object_id = res.object_id
      unless object_id
        raise "Array object has no object ID"
      end

      begin
        # Get array elements
        req = ::Cdp::Runtime::GetProperties.new(
          object_id: object_id,
          own_properties: true,
          accessor_properties_only: nil,
          generate_preview: nil,
          non_indexed_properties_only: nil
        )
        props = req.call(self)
        if ex = props.exception_details
          raise "Failed to get array properties: #{ex}"
        end

        # Filter for array elements, skipping __proto__ and length
        elements = [] of Element
        props.result.each do |prop|
          # Skip __proto__ and length properties
          next if prop.name == "__proto__" || prop.name == "length"

          # Ensure we have a value
          next unless prop.value

          # Ensure it's a DOM node
          unless prop.value.subtype == "node"
            raise "Expected DOM node but got subtype: #{prop.value.subtype}"
          end

          # Create element from remote object
          elem = Element.new(prop.value, self)
          elements << elem
        end

        Elements.new(elements)
      ensure
        # Release the array object
        release(res)
      end
    end

    # release releases a remote object.
    def release(obj : ::Cdp::Runtime::RemoteObject) : Nil
      return unless obj.object_id
      req = ::Cdp::Runtime::ReleaseObject.new(object_id: obj.object_id)
      req.call(self)
    end

    # Convert a DOM NodeID to an Element.
    def element_from_node(node_id : ::Cdp::Dom::NodeId) : Element
      req = ::Cdp::Dom::ResolveNode.new(node_id: node_id, backend_node_id: nil, object_group: nil, execution_context_id: nil)
      result = req.call(self)
      Element.new(result.object, self)
    end

    # search performs a text search across the page.
    # Returns a SearchResult object that can be used to retrieve matched elements.
    def search(query : String) : SearchResult
      req = ::Cdp::Dom::PerformSearch.new(query: query, include_user_agent_shadow_dom: true)
      result = req.call(self)
      SearchResult.new(result, self)
    end

    # race creates a RaceContext to race multiple element queries.
    def race : RaceContext
      RaceContext.new(self)
    end

    private def evaluate_internal(opts : EvalOptions) : ::Cdp::Runtime::RemoteObject
      # Format arguments for CallFunctionOn
      args = format_args(opts)

      req = ::Cdp::Runtime::CallFunctionOn.new(
        function_declaration: opts.format_to_js_func,
        object_id: opts.this_obj.try(&.object_id),
        arguments: args,
        await_promise: opts.await_promise?,
        return_by_value: opts.by_value?,
        user_gesture: opts.user_gesture?,
        silent: nil,
        generate_preview: nil,
        execution_context_id: nil,
        object_group: nil,
        throw_on_side_effect: nil,
        unique_context_id: nil,
        serialization_options: nil
      )

      res = req.call(self)
      if ex = res.exception_details
        raise "JavaScript evaluation error: #{ex}"
      end
      res.result
    end

    # Get cached helper function ID.
    private def get_helper(js_ctx_id : String, name : String) : String?
      @helpers_lock.synchronize do
        helpers = @helpers
        return unless helpers
        per_ctx = helpers[js_ctx_id]?
        return unless per_ctx
        per_ctx[name]?
      end
    end

    # Set cached helper function ID.
    private def set_helper(js_ctx_id : String, name : String, fn_id : String) : Nil
      @helpers_lock.synchronize do
        helpers = @helpers ||= Hash(String, Hash(String, String)).new
        per_ctx = helpers[js_ctx_id]?
        unless per_ctx
          per_ctx = Hash(String, String).new
          helpers[js_ctx_id] = per_ctx
        end
        per_ctx[name] = fn_id
      end
    end

    # Get JavaScript context ID (window object).
    private def get_js_ctx_id : String
      @js_ctx_lock.synchronize do
        if id = @js_ctx_id
          return id
        end
        # Evaluate "window" to get global object
        req = ::Cdp::Runtime::Evaluate.new(expression: "window")
        res = req.call(self)
        if ex = res.exception_details
          raise "Failed to get window object: #{ex}"
        end
        id = res.result.object_id
        raise "No object ID returned for window" unless id
        @js_ctx_id = id
        # Clear helpers for this context (if any)
        @helpers_lock.synchronize { @helpers = nil }
        id
      end
    end

    # Clear cached JavaScript context ID.
    private def unset_js_ctx_id : Nil
      @js_ctx_lock.synchronize do
        @js_ctx_id = nil
        @helpers_lock.synchronize { @helpers = nil }
      end
    end

    # Check if error is a context not found error.
    private def ctx_not_found_error?(error : ::Exception) : Bool
      # Check if it's a Rod::Lib::Cdp::Error with code -32000 and matching message
      if error.is_a?(::Rod::Lib::Cdp::Error)
        return error.code == -32000 && error.message.includes?("Cannot find context with specified id")
      end
      false
    end

    # Ensure JavaScript helper function is loaded and return its remote object ID.
    private def ensure_js_helper(fn : JS::Function) : String
      js_ctx_id = get_js_ctx_id
      # First, ensure the root "functions" object exists
      root_id = get_helper(js_ctx_id, "functions")
      unless root_id
        req = ::Cdp::Runtime::CallFunctionOn.new(
          function_declaration: JS::FUNCTIONS.definition,
          object_id: js_ctx_id,
          arguments: nil,
          await_promise: false,
          return_by_value: false
        )
        res = req.call(self)
        if ex = res.exception_details
          raise "Failed to create functions object: #{ex}"
        end
        root_id = res.result.object_id
        raise "No object ID returned for functions" unless root_id
        set_helper(js_ctx_id, "functions", root_id)
      end
      # Check if function already cached
      cached_id = get_helper(js_ctx_id, fn.name)
      return cached_id if cached_id
      # Ensure dependencies are loaded
      fn.dependencies.each { |dep| ensure_js_helper(dep) }
      # Create the function
      create_js = <<-JS
        functions => {
          const f = functions.#{fn.name} = #{fn.definition};
          f.toString = () => 'fn';
          return f
        }
        JS
      req = ::Cdp::Runtime::CallFunctionOn.new(
        function_declaration: create_js,
        object_id: js_ctx_id,
        arguments: [::Cdp::Runtime::CallArgument.new(object_id: root_id)],
        await_promise: false,
        return_by_value: false
      )
      res = req.call(self)
      if ex = res.exception_details
        raise "Failed to create helper function #{fn.name}: #{ex}"
      end
      fn_id = res.result.object_id
      raise "No object ID returned for function #{fn.name}" unless fn_id
      set_helper(js_ctx_id, fn.name, fn_id)
      fn_id
    end

    # Update format_args to handle JS::Function arguments
    private def format_args(opts : EvalOptions) : Array(::Cdp::Runtime::CallArgument)?
      return if opts.js_args.empty?
      opts.js_args.map do |arg|
        case arg
        when JS::Function
          fn_id = ensure_js_helper(arg)
          ::Cdp::Runtime::CallArgument.new(object_id: fn_id)
        when ::Cdp::Runtime::RemoteObject
          ::Cdp::Runtime::CallArgument.new(object_id: arg.object_id)
        else
          ::Cdp::Runtime::CallArgument.new(value: arg)
        end
      end
    end

    private def element_by_css(selector : String, opts : QueryOptions) : Element
      # Use JavaScript helper function 'element' to find element
      eval_opts = eval_helper(JS::ELEMENT, selector)

      if opts.timeout > 0.seconds
        retry_finding(opts.timeout, opts.retry_interval) do
          element_by_js(eval_opts)
        end
      else
        element_by_js(eval_opts)
      end
    rescue ex : NotFoundError
      raise ex
    rescue ex
      raise NotFoundError.new("Element not found: #{selector}", cause: ex)
    end

    private def elements_by_css(selector : String, opts : QueryOptions) : Elements
      eval_opts = eval_helper(JS::ELEMENTS, selector)
      elements_by_js(eval_opts)
    end

    private def element_by_xpath(xpath : String, opts : QueryOptions) : Element
      eval_opts = eval_helper(JS::ELEMENT_X, xpath)

      if opts.timeout > 0.seconds
        retry_finding(opts.timeout, opts.retry_interval) do
          element_by_js(eval_opts)
        end
      else
        element_by_js(eval_opts)
      end
    rescue ex : NotFoundError
      raise ex
    rescue ex
      raise NotFoundError.new("Element not found via XPath: #{xpath}", cause: ex)
    end

    private def elements_by_xpath(xpath : String, opts : QueryOptions) : Elements
      eval_opts = eval_helper(JS::ELEMENTS_X, xpath)
      elements_by_js(eval_opts)
    end

    private def element_by_regex(selector : String, regex : String, opts : QueryOptions) : Element
      eval_opts = eval_helper(JS::ELEMENT_R, selector, regex)

      if opts.timeout > 0.seconds
        retry_finding(opts.timeout, opts.retry_interval) do
          element_by_js(eval_opts)
        end
      else
        element_by_js(eval_opts)
      end
    rescue ex : NotFoundError
      raise ex
    rescue ex
      raise NotFoundError.new("Element not found via regex: #{selector} / #{regex}", cause: ex)
    end
  end

  # Pages is a collection of Page objects with helper methods.
  # Provides convenient access to first/last pages and search functionality.
  struct Pages
    include Enumerable(Page)

    # Internal array storage
    @pages : Array(Page)

    # Create empty Pages collection
    def initialize
      @pages = [] of Page
    end

    # Create from existing array
    def initialize(@pages : Array(Page))
    end

    # Create from pages
    def self.[](*pages : Page)
      new(pages.to_a)
    end

    # Returns the first page, or nil if the list is empty.
    def first : Page?
      @pages.first?
    end

    # Returns the last page, or nil if the list is empty.
    def last : Page?
      @pages.last?
    end

    # Returns true if the list is empty.
    def empty? : Bool
      @pages.empty?
    end

    # Returns true if the list is not empty.
    def any? : Bool
      !empty?
    end

    # Returns the number of pages.
    def size : Int32
      @pages.size
    end

    # Iterate over pages
    def each(&block : Page ->)
      @pages.each(&block)
    end

    # Access page by index
    def [](index : Int) : Page
      @pages[index]
    end

    # Access page by index with bounds check
    def []?(index : Int) : Page?
      @pages[index]?
    end

    # Add page to collection
    def <<(page : Page)
      @pages << page
      self
    end

    # Find the page that has the specified element with the css selector.
    # Returns nil if no page contains the element.
    def find(selector : String) : Page?
      @pages.each do |page|
        if page.has_element?(selector)
          return page
        end
      end
      nil
    end

    # Find the page that has the url that matches the js_regex.
    # Returns nil if no page matches.
    def find_by_url(js_regex : String) : Page?
      regex = Regex.new(js_regex) # ameba:disable Lint/UselessAssign
      @pages.each do |_|
        # TODO: Implement Page#url method
        # For now, return nil
        # url = page.url
        # return page if regex.match?(url)
      end
      nil
    end

    # Convert to array
    def to_a : Array(Page)
      @pages.dup
    end
  end
end
