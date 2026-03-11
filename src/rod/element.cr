require "./page"
require "./context"
require "./types"
require "./error"
require "../cdp/dom/dom"
require "./lib/quad"
require "./lib/input/input"
require "./lib/js"
require "base64"

module Rod
  # Element represents a DOM element.
  class Element
    include ::Cdp::Contextable
    include ::Cdp::Sessionable

    # Remote object reference from CDP
    property object : ::Cdp::Runtime::RemoteObject

    # Parent page
    property page : Page

    # Context for cancellation/timeout
    property ctx : Context

    # Sleeper for retry logic
    property sleeper : Proc(Rod::Utils::Sleeper)
    @e : EFunc?

    def initialize(@object : ::Cdp::Runtime::RemoteObject, @page : Page, @ctx : Context = Context.background, @sleeper = -> { Rod::Utils::Sleeper.new })
      @e = ->(err : Exception?) { @page.e(err) }
    end

    # e is the error handler for Must methods.
    # It calls the configured EFunc with the error.
    protected def e(err : Exception?) : Nil
      @e.try &.call(err)
    end

    # WithPanic returns an element clone with the specified panic function.
    # The fail must stop the current goroutine's execution immediately.
    def with_panic(fail : Proc(Exception, Nil)) : self
      new_obj = self.dup
      new_obj.set_panic_handler(fail)
      new_obj
    end

    def set_panic_handler(fail : Proc(Exception, Nil)) : Nil
      @e = Browser.gen_e(fail)
    end

    protected def e_handler=(handler : EFunc?) : EFunc?
      @e = handler
    end

    # Get session ID from parent page
    def session_id : String?
      @page.session_id
    end

    # Context implementation
    def context : HTTP::Client::Context?
      @ctx
    end

    # Context returns a clone with the specified ctx for chained sub-operations.
    def context(ctx : Context) : Element
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
    def timeout(d : Time::Span) : Element
      ctx, cancel = @ctx.with_timeout(d)
      val = TimeoutContextVal.new(@ctx, cancel)
      ctx_with_val = ctx.with_value(TIMEOUT_KEY, val)
      context(ctx_with_val)
    end

    # CancelTimeout cancels the current timeout context and returns a clone with the parent context.
    def cancel_timeout : Element
      val = @ctx.value(TIMEOUT_KEY).as?(TimeoutContextVal)
      raise "no timeout context to cancel" unless val
      val.cancel.call
      context(val.parent)
    end

    # WithCancel returns a clone with a context cancel function.
    def with_cancel : Tuple(Element, ->)
      ctx, cancel = @ctx.with_cancel
      {context(ctx), cancel}
    end

    # Sleeper returns a clone with the specified sleeper for chained sub-operations.
    def sleeper(sleeper : Proc(Rod::Utils::Sleeper)) : Element
      new_obj = dup
      new_obj.sleeper = sleeper
      new_obj
    end

    # String representation
    def to_s : String
      desc = @object.description
      desc ? "<#{desc}>" : "<Element>"
    end

    # Focus sets focus on the specified element.
    def focus : Nil
      scroll_into_view
      evaluate("() => this.focus()")
    end

    # Scroll into view
    def scroll_into_view : Nil
      object_id = @object.object_id
      raise "Element has no object ID" unless object_id

      ::Cdp::DOM::ScrollIntoViewIfNeeded.new(
        node_id: nil,
        backend_node_id: nil,
        object_id: object_id,
        rect: nil
      ).call(@page)
    end

    # Click will press then release the button just like a human.
    # Before the action, it will try to scroll to the element, hover the mouse over it,
    # wait until the it's interactable and enabled.
    def click(button : String = "left", click_count : Int32 = 1) : Nil
      cleanup = try_trace(Rod::TraceTypeInput, "#{button} click")
      begin
        hover
        wait_enabled
        @page.mouse.click(button, click_count)
      ensure
        cleanup.call
      end
    end

    # Tap will scroll to the element and tap it.
    # Before the action, it will try to scroll to the element and wait until it's interactable and enabled.
    def tap : Nil
      scroll_into_view
      wait_enabled
      pt = wait_interactable
      @page.touch.tap(pt.x, pt.y)
    end

    # Type is similar with Keyboard.Type.
    # Before the action, it will try to scroll to the element and focus on it.
    def type(*keys : Input::Key) : Nil
      focus
      @page.keyboard.type(*keys)
    end

    # KeyActions is similar with Page.KeyActions.
    # Before the action, it will try to scroll to the element and focus on it.
    def key_actions : Keyboard::KeyActions
      focus
      @page.keyboard.key_actions
    end

    # SelectText selects the text that matches the regular expression.
    # Before the action, it will try to scroll to the element and focus on it.
    def select_text(regex : String) : Nil
      focus
      evaluate(<<-JS, regex)
        (regex) => {
          const match = this.value.match(new RegExp(regex));
          if (match) {
            this.setSelectionRange(match.index, match.index + match[0].length);
          }
        }
      JS
    end

    # SelectAllText selects all text
    # Before the action, it will try to scroll to the element and focus on it.
    def select_all_text : Nil
      focus
      evaluate("() => {
        const sel = window.getSelection();
        const range = document.createRange();
        range.selectNodeContents(this);
        sel.removeAllRanges();
        sel.addRange(range);
      }")
    end

    # Blur removes focus from the element.
    def blur : Nil
      evaluate("() => this.blur()")
    end

    # InputTime focuses on the element and inputs time to it.
    # Before the action, it will scroll to the element, wait until it's visible, enabled and writable.
    def input_time(t : Time) : Nil
      focus
      wait_enabled
      wait_writable
      timestamp_ms = t.to_unix_ms
      evaluate(<<-JS, timestamp_ms)
        (timestampMs) => {
          const time = new Date(timestampMs);
          const pad = (n) => n.toString().padStart(2, "0");
          const year = time.getFullYear();
          const month = pad(time.getMonth() + 1);
          const day = pad(time.getDate());
          const hour = pad(time.getHours());
          const minute = pad(time.getMinutes());

          switch (this.type) {
            case "date":
              this.value = `${year}-${month}-${day}`;
              break;
            case "datetime-local":
              this.value = `${year}-${month}-${day}T${hour}:${minute}`;
              break;
            case "month":
              this.value = `${year}-${month}`;
              break;
            case "time":
              this.value = `${hour}:${minute}`;
              break;
          }

          this.dispatchEvent(new Event("input", { bubbles: true }));
          this.dispatchEvent(new Event("change", { bubbles: true }));
        }
      JS
    end

    # InputColor focuses on the element and inputs color to it.
    # Before the action, it will scroll to the element, wait until it's visible, enabled and writable.
    def input_color(color : String) : Nil
      focus
      wait_enabled
      wait_writable
      evaluate(<<-JS, color)
        (newColor) => {
          this.value = `${newColor}`;
          this.dispatchEvent(new Event("input", { bubbles: true }));
          this.dispatchEvent(new Event("change", { bubbles: true }));
        }
      JS
    end

    # Hover the mouse over the center of the element.
    # Before the action, it will try to scroll to the element and wait until it's interactable.
    def hover : Nil
      pt = wait_interactable
      @page.mouse.move_to(pt)
    end

    # MoveMouseOut of the current element.
    def move_mouse_out : Nil
      shape_result = shape
      quads = shape_result.quads
      box = Rod::Lib::Quad.box(quads)
      raise InvisibleShapeError.new(self) unless box
      x, y, width, _height = box
      @page.mouse.move_to(Point.new(x + width, y))
    end

    # Shape returns the content quads of the element.
    # A 4-sides polygon is not necessary a rectangle. 4-sides polygons can be apart from each other.
    # For example, we use 2 4-sides polygons to describe the shape below:
    #
    #   ____________          ____________
    #  /        ___/    =    /___________/    +     _________
    # /________/                                   /________/
    def shape : ::Cdp::DOM::GetContentQuadsResult
      object_id = @object.object_id
      raise "Element has no object ID" unless object_id
      ::Cdp::DOM::GetContentQuads.new(
        node_id: nil,
        backend_node_id: nil,
        object_id: object_id
      ).call(@page)
    end

    # ScrollIntoView scrolls the element into viewport.
    def scroll_into_view : Nil
      evaluate("() => this.scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'})")
    end

    # CanvasToImage gets image data of a canvas element.
    # Default format is image/png and quality is 0.92 in browser behavior.
    def canvas_to_image(format : String = "", quality : Float64 = -1.0) : Bytes
      res = eval("(format, quality) => this.toDataURL(format, quality)", format, quality)
      data_uri = res.value.try(&.as_s?) || ""
      _, bin = parse_data_uri(data_uri)
      bin
    end

    # Resource returns the src content of the current element.
    def resource : Bytes
      src = evaluate(@page.eval_helper(Rod::JS::RESOURCE).by_promise)
      url = src.value.try(&.as_s?) || ""
      @page.context(@ctx).get_resource(url)
    end

    # BackgroundImage returns the CSS background image resource of the element.
    def background_image : Bytes
      res = eval(%(() => window.getComputedStyle(this).backgroundImage.replace(/^url\\("/, '').replace(/"\\)$/, '')))
      url = res.value.try(&.as_s?) || ""
      @page.context(@ctx).get_resource(url)
    end

    # Screenshot of the area of the element.
    def screenshot(format : ::Cdp::Page::CaptureScreenshotFormat = ::Cdp::Page::CaptureScreenshotFormatPng, quality : Int32 = 0) : Bytes
      scroll_into_view

      opts = Cdp::Page::CaptureScreenshot.new
      opts.format = format
      opts.quality = quality == 0 ? nil : quality.to_i64

      bin = @page.screenshot(false, opts)

      shape_result = shape
      if box_tuple = Rod::Lib::Quad.box(shape_result.quads)
        x, y, width, height = box_tuple
        Rod::Lib::Utils.crop_image(bin, quality,
          x.to_i,
          y.to_i,
          width.to_i,
          height.to_i
        )
      else
        raise "Failed to compute bounding box for element"
      end
    end

    private DATA_URI_REGEX = /\Adata:(.+?)?(;base64)?,/

    private def parse_data_uri(uri : String) : Tuple(String, Bytes)
      matches = DATA_URI_REGEX.match(uri)
      return {"", Bytes.new(0)} unless matches

      prefix_len = matches[0].size
      content_type = matches[1]? || ""
      encoded = uri.byte_slice(prefix_len, uri.bytesize - prefix_len) || ""

      begin
        {content_type, Base64.decode(encoded)}
      rescue
        {content_type, Bytes.new(0)}
      end
    end

    # Interactable checks if the element is interactable with cursor.
    # The cursor can be mouse, finger, stylus, etc.
    # If not interactable raises an error (NotInteractableError or subtypes).
    # Returns a point inside the element that can be used for interaction.
    def interactable : Point
      no_pointer_events = evaluate("() => getComputedStyle(this).pointerEvents === 'none'")
      if no_pointer_events.value.try(&.as_bool?) == true
        raise NoPointerEventsError.new(self)
      end

      shape_result = shape
      quads = shape_result.quads
      point = Rod::Lib::Quad.one_point_inside(quads)
      if point.nil?
        raise InvisibleShapeError.new(self)
      end

      pt = point.not_nil!
      root = @page
      while iframe_el = root.element
        root = iframe_el.page
      end

      scroll = root.context(@ctx).eval("() => ({ x: window.scrollX, y: window.scrollY })").value
      scroll_x = scroll.try(&.[]?("x")).try(&.as_f?) || 0.0
      scroll_y = scroll.try(&.[]?("y")).try(&.as_f?) || 0.0

      x = (pt.x + scroll_x).to_i
      y = (pt.y + scroll_y).to_i

      begin
        el_at_point = @page.context(@ctx).element_from_point(x, y)
        covered = begin
          !contains_element(el_at_point)
        rescue ex
          # Cross-world object checks can happen in nested frame contexts.
          msg = ex.message.to_s
          if msg.includes?("same JavaScript world")
            false
          else
            raise ex
          end
        end
        raise CoveredError.new(el_at_point) if covered
      rescue ex
        msg = ex.message.to_s
        if msg.includes?(::Cdp::ErrNodeNotFoundAtPos.message)
          raise InvisibleShapeError.new(self)
        end
        raise ex
      end

      pt
    end

    # WaitInteractable waits for the element to become interactable.
    # Returns a point inside the element that can be used for interaction.
    def wait_interactable(timeout : Time::Span = 5.seconds) : Point
      if @ctx.cancelled?
        raise(@ctx.err || ContextCanceledError.new("context cancelled"))
      end

      effective_timeout = @ctx.timeout_remaining(timeout)
      if effective_timeout <= Time::Span::ZERO
        raise TimeoutError.new("Timeout waiting for interactable (context deadline exceeded)")
      end

      deadline = Time.instant + effective_timeout
      out : Point? = nil
      err = Rod::Lib::Utils.retry(@ctx, @sleeper.call) do
        begin
          scroll_into_view
          out = interactable
          {true, nil}
        rescue ex : CoveredError
          if Time.instant >= deadline
            {true, ex}
          else
            {false, nil}
          end
        rescue ex : RodError
          if Time.instant >= deadline
            {true, ex}
          else
            {true, ex}
          end
        rescue ex
          {true, ex}
        end
      end

      raise err if err
      out.not_nil!
    end

    # Get element text content
    def text : String
      result = evaluate(@page.eval_helper(Rod::JS::TEXT))
      result.value.try(&.as_s?) || ""
    end

    # Get element HTML
    def html : String
      result = evaluate("() => this.outerHTML")
      result.value.to_s
    end

    # Get inner HTML
    def inner_html : String
      result = evaluate("() => this.innerHTML")
      result.value.to_s
    end

    # Get attribute value
    def attribute(name : String) : String?
      result = evaluate("(name) => this.getAttribute(name)", name)
      val = result.value
      val.nil? ? nil : val.to_s
    end

    # Get property value
    def property(name : String) : JSON::Any
      result = evaluate("(name) => this[name]", name)
      result.value || JSON::Any.new(nil)
    end

    # Set attribute
    def set_attribute(name : String, value : String) : Nil
      evaluate("(name, value) => this.setAttribute(name, value)", name, value)
    end

    # Input focuses on the element and inputs text to it.
    # Before the action, it will scroll to the element, wait until it's visible, enabled and writable.
    def input(text : String) : Nil
      focus
      wait_enabled
      wait_writable

      insert_error : Exception? = nil
      begin
        @page.insert_text(text)
      rescue ex
        insert_error = ex
      end

      begin
        evaluate(<<-JS)
          () => {
            this.dispatchEvent(new Event("input", { bubbles: true }));
            this.dispatchEvent(new Event("change", { bubbles: true }));
          }
        JS
      rescue
        # Match Go behavior: ignore synthetic event errors.
      end

      raise insert_error.not_nil! if insert_error
    end

    # Check if element is visible
    def visible? : Bool
      result = evaluate(<<-JS
        () => {
          const style = window.getComputedStyle(this);
          return style.display !== 'none' &&
                 style.visibility !== 'hidden' &&
                 style.opacity !== '0';
        }
        JS
      )
      result.value.try(&.as_bool?) || false
    end

    # Check if element is enabled
    def enabled? : Bool
      result = evaluate("() => !this.disabled")
      result.value.try(&.as_bool?) || false
    end

    # Disabled checks if the element is disabled.
    def disabled? : Bool
      prop = property("disabled")
      prop.as_bool? || false
    end

    # SetFiles of the current file input element.
    # ameba:disable Naming/AccessorMethodName
    def set_files(paths : Array(String)) : Nil
      abs_paths = ::Rod::Lib::Utils.absolute_paths(paths)
      object_id = @object.object_id
      raise "Element has no object ID" unless object_id
      ::Cdp::DOM::SetFileInputFiles.new(files: abs_paths, object_id: object_id, node_id: nil, backend_node_id: nil).call(@page)
    end

    # Select selects/deselects options in a <select> element.
    def select(selectors : Array(String), selected : Bool = true, t : String = SelectorType::Text) : Nil
      focus
      # TODO: trace and slow motion
      res = evaluate(@page.eval_helper(Rod::JS::SELECT, selectors, selected, t).by_user)
      unless res.value.try(&.as_bool?) == true
        raise NotFoundError.new("Element not found")
      end
    end

    # Equal checks if two elements are the same.
    def equal(elm : Element) : Bool
      result = evaluate("(elm) => this === elm", elm.object)
      result.value.try(&.as_bool?) || false
    end

    # GetXPath returns the xpath of the element.
    def get_xpath(optimized : Bool = false) : String
      opts = @page.eval_helper(Rod::JS::GET_XPATH, optimized)
      opts.by_value = true
      res = @page.evaluate(opts)
      res.value.try(&.as_s?) || ""
    end

    # WaitLoad for element like <img>.
    def wait_load : Nil
      evaluate(@page.eval_helper(Rod::JS::WAIT_LOAD).by_promise)
    end

    # WaitStableRAF waits for no shape changes across consecutive animation frames.
    def wait_stable_raf : Nil
      wait_visible

      shape_json : String? = nil
      loop do
        @page.context(@ctx).wait_repaint
        current = shape.to_json
        break if shape_json == current
        shape_json = current
      end
    end

    # WaitStable waits until no shape or position change for d duration.
    def wait_stable(duration : Time::Span = 100.milliseconds) : Nil
      wait_visible

      last_shape = shape.to_json
      loop do
        if @ctx.cancelled?
          if err = @ctx.err
            raise err
          end
          raise ContextCanceledError.new("context cancelled")
        end

        sleep(duration) if duration > Time::Span::ZERO
        current_shape = shape.to_json
        break if current_shape == last_shape
        last_shape = current_shape
      end
    end

    # Wait until the js returns true with this element bound as `this`.
    def wait(opts : EvalOptions) : Nil
      @page.context(@ctx).sleeper(@sleeper).wait(opts.this(@object))
    end

    # Wait for element to be visible
    def wait_visible(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) { visible? }
    end

    # Wait for element to be enabled
    def wait_enabled(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) { enabled? }
    end

    # Wait until the element is writable (not readonly).
    def wait_writable(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) do
        result = evaluate("() => !this.readonly")
        result.value.try(&.as_bool?) || false
      end
    end

    # Wait for element to be invisible
    def wait_invisible(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) { !visible? }
    end

    # Release the remote object
    def release : Nil
      @page.context(@ctx).release(@object)
    end

    # Remove element from DOM
    def remove : Nil
      evaluate("() => this.remove()")
      release
    end

    # Evaluate JavaScript with this element as context
    def evaluate(js : String, *params) : ::Cdp::Runtime::RemoteObject
      js_args = [] of EvalOptions::JsArg
      params.each do |param|
        case param
        when JSON::Any, JS::Function, ::Cdp::Runtime::RemoteObject, String, Int32, Int64, Float64, Bool, Nil
          js_args << param
        else
          js_args << JSON.parse(param.to_json)
        end
      end

      opts = EvalOptions.new(
        by_value: true,
        await_promise: false,
        this_obj: @object,
        js: js,
        js_args: js_args,
        user_gesture: false
      )
      @page.evaluate(opts)
    end

    # Eval is a shortcut for evaluate with AwaitPromise enabled.
    def eval(js : String, *params) : ::Cdp::Runtime::RemoteObject
      opts = @page.eval_opts(js, *params)
      opts.await_promise = true
      evaluate(opts)
    end

    # Evaluate is a shortcut of Page.evaluate with this object bound as `this`.
    def evaluate(opts : EvalOptions) : ::Cdp::Runtime::RemoteObject
      @page.context(@ctx).evaluate(opts.this(@object))
    end

    # Find element using JavaScript function with this element as context.
    def element_by_js(opts : EvalOptions) : Element
      opts_with_this = opts.this(@object)
      @page.element_by_js(opts_with_this)
    end

    # Find elements using JavaScript function with this element as context.
    def elements_by_js(opts : EvalOptions) : Elements
      opts_with_this = opts.this(@object)
      @page.elements_by_js(opts_with_this)
    end

    # Check if child element exists matching the CSS selector.
    # Returns tuple of {found, element} where element is nil if not found.
    def has(selector : String) : Tuple(Bool, Element?)
      el = element(selector)
      {true, el}
    rescue NotFoundError
      {false, nil}
    end

    # Check if child element exists matching the XPath selector.
    # Returns tuple of {found, element} where element is nil if not found.
    def has_x(xpath : String) : Tuple(Bool, Element?)
      el = element_x(xpath)
      {true, el}
    rescue NotFoundError
      {false, nil}
    end

    # Check if child element exists matching the CSS selector and text regex.
    # Returns tuple of {found, element} where element is nil if not found.
    def has_r(selector : String, regex : String) : Tuple(Bool, Element?)
      el = element_r(selector, regex)
      {true, el}
    rescue NotFoundError
      {false, nil}
    end

    # Matches checks if the element can be selected by the css selector.
    def matches(selector : String) : Bool
      result = evaluate("(s) => this.matches(s)", selector)
      result.value.try(&.as_bool?) || false
    end

    # ContainsElement check if the target is equal or inside the element.
    def contains_element(target : Element) : Bool
      js = <<-JS
        function(target) {
          for (var elem = target; elem != null; elem = elem.parentElement) {
            if (elem === this) return true;
          }
          return false;
        }
      JS
      result = evaluate(js, target.object)
      result.value.try(&.as_bool?) || false
    end

    # Describe the current element. The depth is the maximum depth at which children should be retrieved, defaults to 1,
    # use -1 for the entire subtree or provide an integer larger than 0.
    # The pierce decides whether or not iframes and shadow roots should be traversed when returning the subtree.
    def describe(depth : Int32 = 1, pierce : Bool = false) : ::Cdp::DOM::Node
      object_id = @object.object_id
      raise "Element has no object ID" unless object_id

      req = ::Cdp::DOM::DescribeNode.new(
        node_id: nil,
        backend_node_id: nil,
        object_id: object_id,
        depth: depth.to_i64,
        pierce: pierce
      )
      result = req.call(@page)
      result.node
    end

    # ShadowRoot returns the shadow root of this element.
    def shadow_root : Element
      node = describe(1, false)

      shadow_roots = node.shadow_roots
      if shadow_roots.nil? || shadow_roots.empty?
        raise NoShadowRootError.new(self)
      end

      backend_node_id = shadow_roots[0].backend_node_id
      req = ::Cdp::DOM::ResolveNode.new(
        node_id: nil,
        backend_node_id: backend_node_id,
        object_group: nil,
        execution_context_id: nil
      )
      result = req.call(@page)
      Element.new(result.object, @page)
    end

    # Frame creates a page instance that represents the iframe.
    # Go parity: returns a cloned page even when frame_id is empty.
    def frame : Page
      node = describe(1, false)
      frame_id = node.frame_id || ""

      # Clone page with new frame ID
      session_id = @page.session_id.try { |sid| SessionID.new(sid) }
      clone = Page.new(@page.browser, @page.target_id, session_id, FrameID.new(frame_id), @page.ctx, @sleeper, self)
      clone
    end

    # Find single child element by CSS selector.
    # Raises NotFoundError if element not found.
    def element(selector : String) : Element
      opts = EvalOptions.new(
        js: "/* rod.element */ function(selector) { return this.querySelector(selector) }",
        js_args: [::JSON::Any.new(selector)] of EvalOptions::JsArg
      )
      element_by_js(opts)
    end

    # Find single child element by XPath selector.
    # Raises NotFoundError if element not found.
    def element_x(xpath : String) : Element
      opts = EvalOptions.new(
        js: "function(xpath) { return document.evaluate(xpath, this, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue }",
        js_args: [::JSON::Any.new(xpath)] of EvalOptions::JsArg
      )
      element_by_js(opts)
    end

    # Find single child element by CSS selector with text matching regex.
    # Raises NotFoundError if element not found.
    def element_r(selector : String, regex : String) : Element
      opts = EvalOptions.new(
        js: "function(selector, regex) { const els = this.querySelectorAll(selector); const re = new RegExp(regex); for (const el of els) { if (re.test(el.textContent || el.innerText || '')) return el; } return null; }",
        js_args: [::JSON::Any.new(selector), ::JSON::Any.new(regex)] of EvalOptions::JsArg
      )
      element_by_js(opts)
    end

    # Find all child elements matching CSS selector.
    # Returns empty Elements if none found.
    def elements(selector : String) : Elements
      opts = EvalOptions.new(
        js: "/* rod.elements */ function(selector) { return Array.from(this.querySelectorAll(selector)) }",
        js_args: [::JSON::Any.new(selector)] of EvalOptions::JsArg,
        this_obj: @object
      )
      @page.elements_by_js(opts)
    end

    # Find all child elements matching XPath selector.
    # Returns empty Elements if none found.
    def elements_x(xpath : String) : Elements
      opts = EvalOptions.new(
        js: "function(xpath) { const out = []; const it = document.evaluate(xpath, this, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null); let n; while (n = it.iterateNext()) out.push(n); return out; }",
        js_args: [::JSON::Any.new(xpath)] of EvalOptions::JsArg
      )
      @page.elements_by_js(opts)
    end

    # Get parent element, or nil if no parent.
    def parent : Element?
      opts = EvalOptions.new(js: "function() { return this.parentElement }")
      begin
        element_by_js(opts)
      rescue NotFoundError
        nil
      end
    end

    # Get ancestor elements, optionally filtered by selector.
    def parents(selector : String? = nil) : Elements
      js = <<-JS
        function(selector) {
          let parents = [];
          let elem = this;
          while (elem = elem.parentElement) {
            parents.push(elem);
          }
          if (selector) {
            return parents.filter(el => el.matches(selector));
          }
          return parents;
        }
        JS
      js_args = selector ? [::JSON::Any.new(selector)] of EvalOptions::JsArg : [] of EvalOptions::JsArg
      opts = EvalOptions.new(js: js, js_args: js_args)
      @page.elements_by_js(opts)
    end

    # Get next sibling element, or nil if none.
    def next : Element?
      opts = EvalOptions.new(js: "function() { return this.nextElementSibling }")
      begin
        element_by_js(opts)
      rescue NotFoundError
        nil
      end
    end

    # Get previous sibling element, or nil if none.
    def previous : Element?
      opts = EvalOptions.new(js: "function() { return this.previousElementSibling }")
      begin
        element_by_js(opts)
      rescue NotFoundError
        nil
      end
    end

    # Call CDP method
    def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
      @page.call(context, session_id, method, params)
    end

    private def wait_for(timeout : Time::Span = 5.seconds, &block : -> Bool) : Nil
      # Check context cancellation before starting
      if @ctx.cancelled?
        if err = @ctx.err
          raise err
        end
        raise ContextCanceledError.new("context cancelled")
      end

      # Calculate effective timeout considering context deadline
      effective_timeout = @ctx.timeout_remaining(timeout)
      if effective_timeout <= Time::Span::ZERO
        raise TimeoutError.new("Timeout waiting for condition (context deadline exceeded)")
      end

      start_time = Time.instant
      until block.call
        # Check context cancellation each iteration
        if @ctx.cancelled?
          if err = @ctx.err
            raise err
          end
          raise ContextCanceledError.new("context cancelled")
        end

        elapsed = Time.instant - start_time
        if elapsed > effective_timeout
          raise TimeoutError.new("Timeout waiting for condition")
        end

        sleep(10.milliseconds)
      end
    end
  end

  # Elements is a collection of Element objects with helper methods.
  # Provides convenient access to first/last elements and emptiness checks.
  struct Elements
    include Enumerable(Element)

    # Internal array storage
    @elements : Array(Element)

    # Create empty Elements collection
    def initialize
      @elements = [] of Element
    end

    # Create from existing array
    def initialize(@elements : Array(Element))
    end

    # Create from elements
    def self.[](*elements : Element)
      new(elements.to_a)
    end

    # Returns the first element, or nil if the list is empty.
    def first : Element?
      @elements.first?
    end

    # Returns the last element, or nil if the list is empty.
    def last : Element?
      @elements.last?
    end

    # Returns true if the list is empty.
    def empty? : Bool
      @elements.empty?
    end

    # Returns true if the list is not empty.
    def any? : Bool
      !empty?
    end

    # Returns the number of elements.
    def size : Int32
      @elements.size
    end

    # Iterate over elements
    def each(&block : Element ->)
      @elements.each(&block)
    end

    # Access element by index
    def [](index : Int) : Element
      @elements[index]
    end

    # Access element by index with bounds check
    def []?(index : Int) : Element?
      @elements[index]?
    end

    # Add element to collection
    def <<(element : Element)
      @elements << element
      self
    end

    # Concatenate with another collection
    def concat(other : Elements)
      @elements.concat(other.@elements)
      self
    end

    # Map to array
    def map(&block : Element -> T) forall T
      @elements.map(&block)
    end

    # Filter elements
    def select(&block : Element -> Bool)
      Elements.new(@elements.select(&block))
    end

    # Convert to array
    def to_a : Array(Element)
      @elements.dup
    end
  end
end
