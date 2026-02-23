# Query system implementation
module Rod
  # SelectorType constants.
  module SelectorType
    # SelectorTypeRegex type.
    Regex = "regex"
    # SelectorTypeCSSSector type.
    CSSSelector = "css-selector"
    # SelectorTypeText type.
    Text = "text"
  end

  # SearchResult represents the result of a DOM text search.
  class SearchResult
    # CDP search result
    property cdp_result : ::Cdp::DOM::PerformSearchResult

    # Parent page
    property page : Page

    # Restore function to disable DOM domain
    property restore : Proc(Nil)

    # First element found (cached)
    property first : Element?

    # Create SearchResult
    def initialize(@cdp_result : ::Cdp::DOM::PerformSearchResult, @page : Page, @restore : Proc(Nil))
      @first = nil
    end

    # Get search ID from CDP result
    def search_id : String
      @cdp_result.search_id
    end

    # Get result count from CDP result
    def result_count : Int64
      @cdp_result.result_count
    end

    # Get a range of elements from the remote search result.
    def get(from_index : Int32, length : Int32) : Elements
      req = ::Cdp::DOM::GetSearchResults.new(
        search_id: search_id,
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

    # Release the remote search result.
    def release : Nil
      @restore.call
      req = ::Cdp::DOM::DiscardSearchResults.new(search_id: search_id)
      req.call(@page)
    end
  end

  # RaceContext allows racing multiple element queries and returning the first successful result.
  class RaceContext
    # RaceBranch represents a single branch in the race.
    class RaceBranch
      property condition : Proc(Page, Element)
      property callback : Proc(Element, Nil)?

      def initialize(@condition : Proc(Page, Element), @callback : Proc(Element, Nil)? = nil)
      end
    end

    property page : Page
    @branches : Array(RaceBranch)

    def initialize(@page : Page)
      @branches = [] of RaceBranch
    end

    # Add a CSS selector branch
    def element(selector : String) : self
      @branches << RaceBranch.new(->(page : Page) { page.element(selector) })
      self
    end

    # Add an XPath selector branch
    def element_x(xpath : String) : self
      @branches << RaceBranch.new(->(page : Page) { page.element_x(xpath) })
      self
    end

    # Add a CSS selector + regex branch
    def element_r(selector : String, regex : String) : self
      @branches << RaceBranch.new(->(page : Page) { page.element_r(selector, regex) })
      self
    end

    # Add a JavaScript function branch
    def element_by_js(opts : EvalOptions) : self
      @branches << RaceBranch.new(->(page : Page) { page.element_by_js(opts) })
      self
    end

    # Add a search branch
    def search(query : String) : self
      @branches << RaceBranch.new(->(page : Page) do
        res = page.search(query)
        element = res.first
        res.release
        raise NotFoundError.new("Search found no elements") unless element
        element
      end)
      self
    end

    # Add a custom function branch
    def element_func(&block : Page -> Element) : self
      @branches << RaceBranch.new(block)
      self
    end

    # Set a callback to handle the found element.
    # The callback is run if the corresponding selector is present first in the race.
    def handle(&callback : Element -> Nil) : self
      if @branches.empty?
        raise "No branch to handle"
      end
      @branches.last.callback = callback
      self
    end

    # Execute the race and return the first successfully found element.
    # Raises NotFoundError if no branches succeed.
    def do : Element
      element : Element? = nil

      err = ::Rod::Lib::Utils.retry(@page.ctx, @page.sleeper.call) do
        @branches.each do |branch|
          begin
            element = branch.condition.call(@page)

            # Run callback if exists
            if callback = branch.callback
              callback.call(element)
            end

            # Found element, stop retrying
            return {true, nil}
          rescue ex : NotFoundError
            # Element not found, try next branch
            next
          rescue ex : Exception
            # Other error, stop retrying
            return {true, ex}
          end
        end

        # All branches failed with NotFoundError
        {false, nil}
      end

      if err
        raise err
      end

      element.not_nil!
    end
  end
end
