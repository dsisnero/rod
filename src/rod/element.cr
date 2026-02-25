require "./page"
require "./context"
require "./types"
require "./error"
require "../cdp/dom/dom"
require "./lib/quad"
require "./lib/input/input"
require "./lib/js"

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
    def with_panic(fail : Proc(Exception, Nil)) : Element
      new_obj = self.clone
      new_obj.instance_variable_set("@e", Browser.gen_e(fail))
      new_obj
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
      new_obj = self.clone
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
      # TODO: Implement ScrollIntoViewIfNeeded CDP call
      # For now, just evaluate JS
      evaluate("() => this.scrollIntoViewIfNeeded()")
    end

    # Click will press then release the button just like a human.
    # Before the action, it will try to scroll to the element, hover the mouse over it,
    # wait until the it's interactable and enabled.
    def click(button : String = "left", click_count : Int32 = 1) : Nil
      hover
      wait_enabled
      @page.mouse.click(button, click_count)
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
      # TODO: Implement JavaScript helper for selecting text
      evaluate(<<-JS, regex)
        (regex) => {
          const sel = window.getSelection();
          const range = document.createRange();
          const text = this.textContent || this.innerText || '';
          const match = text.match(new RegExp(regex));
          if (match) {
            // Simplified implementation
            range.selectNodeContents(this);
            sel.removeAllRanges();
            sel.addRange(range);
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
      # TODO: Implement proper time input for date/time input elements
      evaluate("(time) => this.value = time.toISOString().slice(0, -1)", t)
    end

    # InputColor focuses on the element and inputs color to it.
    # Before the action, it will scroll to the element, wait until it's visible, enabled and writable.
    def input_color(color : String) : Nil
      focus
      wait_enabled
      evaluate("(color) => this.value = color", color)
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
      ::Cdp::DOM::GetContentQuads.new(object_id: object_id).call(@page)
    end

    # ScrollIntoView scrolls the element into viewport.
    def scroll_into_view : Nil
      evaluate("() => this.scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'})")
    end

    # Screenshot of the area of the element.
    def screenshot(format : String = "png", quality : Int32 = 0) : Bytes
      scroll_into_view

      opts = Cdp::Page::CaptureScreenshot.new
      opts.format = format
      opts.quality = quality == 0 ? nil : quality

      bin = @page.screenshot(false, opts)

      shape_result = shape
      # Convert quads to JSON::Any for Quad.box
      json_quads = shape_result.quads.map { |q| ::JSON::Any.new(q) }
      if box_tuple = Rod::Lib::Quad.box(json_quads)
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

    # Interactable checks if the element is interactable with cursor.
    # The cursor can be mouse, finger, stylus, etc.
    # If not interactable raises an error (NotInteractableError or subtypes).
    # Returns a point inside the element that can be used for interaction.
    def interactable : Point
      # Check pointer-events CSS property
      no_pointer_events = evaluate("() => getComputedStyle(this).pointerEvents === 'none'")
      if no_pointer_events.value.as_bool?
        raise NoPointerEventsError.new(self)
      end

      # Get shape
      shape_result = shape
      quads = shape_result.quads
      point = Rod::Lib::Quad.one_point_inside(quads)
      if point.nil?
        raise InvisibleShapeError.new(self)
      end

      # TODO: Check if element is covered by another element
      # For now, assume it's not covered
      point
    end

    # WaitInteractable waits for the element to become interactable.
    # Returns a point inside the element that can be used for interaction.
    def wait_interactable(timeout : Time::Span = 5.seconds) : Point
      # Check context cancellation before starting
      if @ctx.cancelled?
        raise @ctx.err if @ctx.err
        raise ContextCanceledError.new("context cancelled")
      end

      # Calculate effective timeout considering context deadline
      effective_timeout = @ctx.timeout_remaining(timeout)
      if effective_timeout <= Time::Span::ZERO
        raise TimeoutError.new("Timeout waiting for interactable (context deadline exceeded)")
      end

      start = Time.monotonic
      loop do
        # Check context cancellation each iteration
        if @ctx.cancelled?
          raise @ctx.err if @ctx.err
          raise ContextCanceledError.new("context cancelled")
        end

        begin
          return interactable
        rescue e : RodError
          if Rod.is?(e, NotInteractableError)
            if Time.monotonic - start > effective_timeout
              raise e
            end
            sleep(100.milliseconds)
          else
            raise e
          end
        end
      end
    end

    # Get element text content
    def text : String
      result = evaluate("() => this.textContent || this.innerText || ''")
      result.value.to_s
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
      result.value
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
      # TODO: Implement WaitWritable
      # Clear existing value by selecting all and replacing
      evaluate("() => {
        this.select();
        this.value = '';
      }")
      # Use page.insert_text to simulate text input
      @page.insert_text(text)
      # TODO: Trigger input event
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
      result.value.as_bool? || false
    end

    # Check if element is enabled
    def enabled? : Bool
      result = evaluate("() => !this.disabled")
      result.value.as_bool? || false
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
      res = @page.evaluate(@page.eval_helper(Rod::JS::SELECT, selectors, selected, t).by_user)
      unless res.value.try(&.as_bool?) == true
        raise NotFoundError.new("Element not found")
      end
    end

    # Equal checks if two elements are the same.
    def equal(elm : Element) : Bool
      result = evaluate("(elm) => this === elm", elm.object)
      result.value.as_bool? || false
    end

    # GetXPath returns the xpath of the element.
    def get_xpath(optimized : Bool = false) : String
      res = @page.evaluate(@page.eval_helper(Rod::JS::GET_XPATH, optimized).by_value)
      res.value.as_s? || ""
    end

    # WaitStableRAF waits for the element to be stable using requestAnimationFrame.
    def wait_stable_raf : Nil
      wait_visible
      # TODO: Implement proper RAF stability check
      # For now, delegate to wait_stable
      wait_stable
    end

    # Wait for element to be stable (no layout changes for a period)
    def wait_stable(duration : Time::Span = 100.milliseconds) : Nil
      # TODO: Implement proper stability check
      # Check context cancellation before sleeping
      if @ctx.cancelled?
        raise @ctx.err if @ctx.err
        raise ContextCanceledError.new("context cancelled")
      end
      sleep(duration)
    end

    # Wait for element to be visible
    def wait_visible(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) { visible? }
    end

    # Wait for element to be enabled
    def wait_enabled(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) { enabled? }
    end

    # Wait for element to be invisible
    def wait_invisible(timeout : Time::Span = 5.seconds) : Nil
      wait_for(timeout) { !visible? }
    end

    # Release the remote object
    def release : Nil
      if @object.object_id
        # TODO: Call Runtime.releaseObject
      end
    end

    # Remove element from DOM
    def remove : Nil
      evaluate("() => this.remove()")
    end

    # Evaluate JavaScript with this element as context
    def evaluate(js : String, *params) : ::Cdp::Runtime::RemoteObject
      # TODO: Implement proper evaluation with element as context
      # For now, use page.evaluate
      @page.evaluate(js, params.to_a)
    end

    # Find element using JavaScript function with this element as context.
    def element_by_js(opts : EvalOptions) : Element
      opts_with_this = opts.this(@object)
      @page.element_by_js(opts_with_this)
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
      result.value.as_bool
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
      result.value.as_bool
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
      result = req.call(self)
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
      result = req.call(self)
      Element.new(result.object, @page)
    end

    # Frame creates a page instance that represents the iframe.
    def frame : Page?
      node = describe(1, false)
      frame_id = node.frame_id
      return nil unless frame_id

      # Clone page with new frame ID
      clone = Page.new(@page.browser, @page.target_id, @page.session_id, frame_id, @page.ctx, @sleeper, self)
      clone
    end

    # Find single child element by CSS selector.
    # Raises NotFoundError if element not found.
    def element(selector : String) : Element
      opts = EvalOptions.new(js: "function(selector) { return this.querySelector(selector) }", js_args: [selector])
      element_by_js(opts)
    end

    # Find single child element by XPath selector.
    # Raises NotFoundError if element not found.
    def element_x(xpath : String) : Element
      opts = EvalOptions.new(js: "function(xpath) { return document.evaluate(xpath, this, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue }", js_args: [xpath])
      element_by_js(opts)
    end

    # Find single child element by CSS selector with text matching regex.
    # Raises NotFoundError if element not found.
    def element_r(selector : String, regex : String) : Element
      opts = EvalOptions.new(js: "function(selector, regex) { const els = this.querySelectorAll(selector); const re = new RegExp(regex); for (const el of els) { if (re.test(el.textContent || el.innerText || '')) return el; } return null; }", js_args: [selector, regex])
      element_by_js(opts)
    end

    # Find all child elements matching CSS selector.
    # Returns empty Elements if none found.
    def elements(selector : String) : Elements
      opts = EvalOptions.new(js: "function(selector) { return Array.from(this.querySelectorAll(selector)) }", js_args: [selector])
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
      opts = EvalOptions.new(js: js, js_args: selector ? [selector] : [] of String)
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
        raise @ctx.err if @ctx.err
        raise ContextCanceledError.new("context cancelled")
      end

      # Calculate effective timeout considering context deadline
      effective_timeout = @ctx.timeout_remaining(timeout)
      if effective_timeout <= Time::Span::ZERO
        raise TimeoutError.new("Timeout waiting for condition (context deadline exceeded)")
      end

      start_time = Time.monotonic
      until block.call
        # Check context cancellation each iteration
        if @ctx.cancelled?
          raise @ctx.err if @ctx.err
          raise ContextCanceledError.new("context cancelled")
        end

        elapsed = Time.monotonic - start_time
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
