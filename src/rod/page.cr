require "./browser"
require "./types"
require "./query"
require "./keyboard"
require "./mouse"
require "./touch"

module Rod
  # QueryOptions provides configuration for element queries.
  # Controls timeout, retry behavior, and element visibility requirements.
  struct QueryOptions
    # Maximum time to wait for element
    property timeout : Time::Span

    # Interval between retries
    property retry_interval : Time::Span

    # Wait for element to be visible
    property visible : Bool

    # Wait for element to be enabled
    property enabled : Bool

    def initialize(
      @timeout : Time::Span = 5.seconds,
      @retry_interval : Time::Span = 100.milliseconds,
      @visible : Bool = false,
      @enabled : Bool = false,
    )
    end
  end

  class Page < ::Cdp::Client
    include ::Cdp::Contextable
    include ::Cdp::Sessionable

    property browser : Browser
    property target_id : TargetID
    property session_id : SessionID?
    property frame_id : FrameID?
    property ctx : Nil
    property keyboard : Keyboard?
    property mouse : Mouse?
    property touch : Touch?

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

    def initialize(@browser, @target_id, @session_id = nil, @frame_id = nil, @ctx = nil, @sleeper = -> { Rod::Utils::Sleeper.new })
    end

    # Call implements Cdp::Client.
    def call(context : Nil, session_id : SessionID?, method : String, params : JSON::Any) : Bytes
      browser.call(context, session_id, method, params)
    end

    # Context implements Cdp::Contextable.
    def context : Nil
      @ctx
    end

    # Sessionable implementation
    def session_id : SessionID?
      @session_id
    end

    # Navigate to URL.
    def navigate(url : String) : Nil
      # TODO: implement in rod-r6m
    end

    # Evaluate JavaScript.
    def evaluate(js : String, args : Array(JSON::Any)? = nil) : ::Cdp::Runtime::RemoteObject
      # TODO: Full implementation in rod-e1s
      # For now, return a mock object
      ::Cdp::Runtime::RemoteObject.new(
        type: "object",
        description: "mock"
      )
    end

    # Check if element exists matching the CSS selector.
    # Returns tuple of {found, element} where element is nil if not found.
    def has(selector : String) : Tuple(Bool, Element?)
      begin
        el = element(selector)
        {true, el}
      rescue NotFoundError
        {false, nil}
      end
    end

    # Convenience method - just check existence without returning element.
    def has_element?(selector : String) : Bool
      has(selector)[0]
    end

    # Find single element by CSS selector.
    # Raises NotFoundError if element not found within timeout.
    def element(selector : String, opts : QueryOptions? = nil) : Element
      opts ||= QueryOptions.new
      element_by_css(selector, opts)
    end

    # Find single element by CSS selector, returns nil if not found.
    def element_optional(selector : String, opts : QueryOptions? = nil) : Element?
      begin
        element(selector, opts)
      rescue NotFoundError
        nil
      end
    end

    # Find all elements matching CSS selector.
    # Returns empty Elements if none found.
    def elements(selector : String, opts : QueryOptions? = nil) : Elements
      opts ||= QueryOptions.new
      elements_by_css(selector, opts)
    end

    private def element_by_css(selector : String, opts : QueryOptions) : Element
      # TODO: Implement proper CDP DOM.querySelector call with retry logic
      # For now, throw NotFoundError as placeholder
      raise NotFoundError.new("Element not found: #{selector}")
    end

    private def elements_by_css(selector : String, opts : QueryOptions) : Elements
      # TODO: Implement proper CDP DOM.querySelectorAll call
      # For now, return empty collection
      Elements.new
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
        # TODO: Implement Page#has_element? in Phase 2
        # For now, return first page as placeholder
        return page
      end
      nil
    end

    # Find the page that has the url that matches the js_regex.
    # Returns nil if no page matches.
    def find_by_url(js_regex : String) : Page?
      regex = Regex.new(js_regex)
      @pages.each do |page|
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
