# Query system implementation
module Rod
  # SelectorType constants.
  module SelectorType
    # SelectorTypeRegex type.
    Regex      = "regex"
    # SelectorTypeCSSSector type.
    CSSSelector = "css-selector"
    # SelectorTypeText type.
    Text       = "text"
  end

  # SearchResult represents the result of a DOM text search.
  class SearchResult
    # Search ID from CDP
    property search_id : String

    # Number of results found
    property result_count : Int64

    # Parent page
    property page : Page

    # First element found (cached)
    property first : Element?

    # Restore function to disable DOM domain (placeholder)
    property restore : Proc(Nil)

    # Create SearchResult from PerformSearchResult
    def initialize(search_result : ::Cdp::Dom::PerformSearchResult, @page : Page, @restore = -> { })
      @search_id = search_result.search_id
      @result_count = search_result.result_count
      @first = nil
    end

    # Get a range of elements from the search result.
    def get(from_index : Int32, length : Int32) : Elements
      req = ::Cdp::Dom::GetSearchResults.new(
        search_id: @search_id,
        from_index: from_index,
        to_index: from_index + length
      )
      result = req.call(@page)
      elements = Elements.new
      result.node_ids.each do |node_id|
        element = @page.element_from_node(node_id)
        elements << element
      end
      elements
    end

    # Get all elements from the search result.
    def all : Elements
      get(0, result_count.to_i)
    end

    # Release the search results and cleanup.
    def release : Nil
      req = ::Cdp::Dom::DiscardSearchResults.new(search_id: @search_id)
      req.call(@page)
      @restore.call
    end
  end

  # RaceContext allows racing multiple element queries and returning the first successful result.
  class RaceContext
    property page : Page
    @branches : Array(Proc(Page, Element))

    def initialize(@page : Page)
      @branches = [] of Proc(Page, Element)
    end

    # Add a CSS selector branch
    def element(selector : String) : self
      @branches << ->(page : Page) { page.element(selector) }
      self
    end

    # Add an XPath selector branch
    def element_x(xpath : String) : self
      @branches << ->(page : Page) { page.element_x(xpath) }
      self
    end

    # Add a CSS selector + regex branch
    def element_r(selector : String, regex : String) : self
      @branches << ->(page : Page) { page.element_r(selector, regex) }
      self
    end

    # Add a JavaScript function branch
    def element_by_js(opts : EvalOptions) : self
      @branches << ->(page : Page) { page.element_by_js(opts) }
      self
    end

    # Add a search branch
    def search(query : String) : self
      @branches << ->(page : Page) { page.search(query).first.not_nil! } # ameba:disable Lint/NotNil
      self
    end

    # Add a custom function branch
    def element_func(&block : Page -> Element) : self
      @branches << block
      self
    end

    # Set a callback to handle the found element (placeholder)
    def handle(&_callback : Element -> Nil) : self
      # TODO: Implement callback handling
      self
    end

    # Execute the race and return the first successfully found element.
    # Raises NotFoundError if no branches succeed.
    def do : Element
      # TODO: Implement concurrent racing
      # For now, try branches sequentially
      @branches.each do |branch|
        begin
          return branch.call(@page)
        rescue NotFoundError
          next
        end
      end
      raise NotFoundError.new("No element found in race")
    end
  end
end
