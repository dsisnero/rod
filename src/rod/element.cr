require "./page"
require "./types"

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
    property ctx : Nil

    # Sleeper for retry logic
    @sleeper : Proc(Rod::Utils::Sleeper)

    def initialize(@object : ::Cdp::Runtime::RemoteObject, @page : Page, @ctx = nil, @sleeper = -> { Rod::Utils::Sleeper.new })
    end

    # Get session ID from parent page
    def session_id : SessionID?
      @page.session_id
    end

    # Context implementation
    def context : Nil
      @ctx
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

    # Click the element
    def click(button : String = "left", click_count : Int32 = 1) : Nil
      # TODO: Implement proper mouse click with position
      # For now, use JS click
      evaluate("() => this.click()")
    end

    # Hover over the element
    def hover : Nil
      # TODO: Implement proper mouse hover
      # For now, this is a placeholder
      scroll_into_view
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

    # Type text into element (for input fields)
    def input(text : String) : Nil
      focus
      # Clear existing value
      evaluate("() => this.value = ''")
      # Use page.insert_text to simulate text input
      @page.insert_text(text)
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

    # Wait for element to be stable (no layout changes for a period)
    def wait_stable(duration : Time::Span = 100.milliseconds) : Nil
      # TODO: Implement proper stability check
      sleep(duration)
    end

    # Wait for element to be visible
    def wait_visible(timeout : Time::Span = 5.seconds) : Nil
      wait_for { visible? }
    end

    # Wait for element to be enabled
    def wait_enabled(timeout : Time::Span = 5.seconds) : Nil
      wait_for { enabled? }
    end

    # Wait for element to be invisible
    def wait_invisible(timeout : Time::Span = 5.seconds) : Nil
      wait_for { !visible? }
    end

    # Release the remote object
    def release : Nil
      if object_id = @object.object_id
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

    # Call CDP method
    def call(context : Nil, session_id : SessionID?, method : String, params : JSON::Any) : Bytes
      @page.call(context, session_id, method, params)
    end

    private def wait_for(timeout : Time::Span = 5.seconds, &block : -> Bool) : Nil
      start_time = Time.monotonic
      until block.call
        if Time.monotonic - start_time > timeout
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
