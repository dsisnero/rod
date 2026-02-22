# Query System Porting Plan

**Issue**: rod-42c  
**Priority**: P0  
**Status**: In Progress  
**Source**: `vendor/rod/query.go` (543 lines)

## Overview

The query system provides methods to find, select, and navigate DOM elements using CSS selectors, XPath, JavaScript, and regex patterns. This is foundational for all element interaction in Rod.

## Implementation Strategy

We'll implement the query system in **5 phases**:

1. **Collection Types** (Elements, Pages)
2. **Basic Page Queries** (Has, Element, Elements)
3. **Advanced Page Queries** (XPath, Regex, JS)
4. **Search & Race** (SearchResult, RaceContext)
5. **Element Queries** (scoped queries on elements)

---

## Phase 1: Collection Types

**File**: `src/rod/query.cr`  
**Estimated Effort**: 2 hours  
**Dependencies**: Element type (rod-6o3) ✅

### Types to Implement

```crystal
# Alias for array of elements with helper methods
alias Elements = Array(Element)

# Alias for array of pages with helper methods  
alias Pages = Array(Page)
```

### Methods

#### Elements Collection (on `Array(Element)`)

1. **`first : Element?`**
   - Returns first element or nil if empty
   - Go: `Elements.First()`
   - Test: Empty array returns nil, non-empty returns first

2. **`last : Element?`**
   - Returns last element or nil if empty
   - Go: `Elements.Last()`
   - Test: Empty array returns nil, non-empty returns last

3. **`empty? : Bool`**
   - Returns true if array has no elements
   - Go: `Elements.Empty()`
   - Test: Verify empty check works

#### Pages Collection (on `Array(Page)`)

4. **`first : Page?`**
   - Returns first page or nil
   - Go: `Pages.First()`

5. **`last : Page?`**
   - Returns last page or nil
   - Go: `Pages.Last()`

6. **`empty? : Bool`**
   - Returns true if no pages
   - Go: `Pages.Empty()`

7. **`find(selector : String) : Page?`**
   - Find page containing element matching selector
   - Go: `Pages.Find(selector)`
   - Implementation: Iterate pages, check Has(selector)
   - Returns nil if not found (Crystal style vs Go error)

8. **`find_by_url(js_regex : String) : Page?`**
   - Find page with URL matching regex
   - Go: `Pages.FindByURL(jsRegex)`
   - Implementation: Eval `location.href`, match regex
   - Returns nil if not found

### Testing Phase 1

```crystal
describe "Elements Collection" do
  it "returns first element" do
    # Create mock elements
    elements = [element1, element2]
    elements.first.should eq(element1)
  end
  
  it "returns nil for empty" do
    ([] of Element).first.should be_nil
  end
  
  it "checks empty" do
    ([] of Element).empty?.should be_true
    [element].empty?.should be_false
  end
end
```

---

## Phase 2: Basic Page Queries

**File**: `src/rod/page.cr` (add methods)  
**Estimated Effort**: 4 hours  
**Dependencies**: Phase 1 ✅, CDP DOM domain

### Methods on Page

#### Existence Checks

9. **`has(selector : String) : Tuple(Bool, Element?)`**
   - Check if element exists, return (found, element)
   - Go: `Page.Has(selector) (bool, *Element, error)`
   - Implementation: Try to find element, catch NotFoundError
   - Returns: `{true, element}` or `{false, nil}`

10. **`has_element?(selector : String) : Bool`**
    - Convenience method, just check existence
    - Implementation: `has(selector)[0]`

#### Single Element Queries

11. **`element(selector : String, opts : QueryOptions? = nil) : Element`**
    - Find single element by CSS selector
    - Go: `Page.Element(selector)`
    - Raises: NotFoundError if not found
    - Supports: Timeout, retry options via QueryOptions
    - Implementation: 
      - Query DOM with selector
      - Retry until found or timeout
      - Wrap result in Element type

12. **`element_optional(selector : String) : Element?`**
    - Find element or return nil (Crystal idiom)
    - Implementation: begin/rescue NotFoundError

#### Multiple Element Queries

13. **`elements(selector : String) : Elements`**
    - Find all elements matching CSS selector
    - Go: `Page.Elements(selector)`
    - Returns: Array of Element (empty if none found)
    - Implementation: Query DOM, map results to Elements

### QueryOptions Struct

```crystal
struct QueryOptions
  property timeout : Time::Span = 5.seconds
  property retry_interval : Time::Span = 100.milliseconds
  property visible_only : Bool = false
  property enabled_only : Bool = false
end
```

### Testing Phase 2

```crystal
describe "Page Queries" do
  describe "#has" do
    it "finds existing element" do
      found, el = page.has("#exists")
      found.should be_true
      el.should_not be_nil
    end
    
    it "returns false for missing element" do
      found, el = page.has("#missing")
      found.should be_false
      el.should be_nil
    end
  end
  
  describe "#element" do
    it "finds element by CSS selector" do
      el = page.element("h1")
      el.should be_a(Element)
    end
    
    it "raises NotFoundError for missing" do
      expect_raises(Rod::NotFoundError) do
        page.element("#nonexistent")
      end
    end
  end
  
  describe "#elements" do
    it "finds multiple elements" do
      els = page.elements("p")
      els.size.should be >= 1
      els.each { |e| e.should be_a(Element) }
    end
    
    it "returns empty for no matches" do
      page.elements(".nonexistent").should be_empty
    end
  end
end
```

---

## Phase 3: Advanced Page Queries

**File**: `src/rod/page.cr`  
**Estimated Effort**: 6 hours  
**Dependencies**: Phase 2 ✅

### XPath Queries

14. **`has_x(xpath : String) : Tuple(Bool, Element?)`**
    - Check existence using XPath
    - Go: `Page.HasX(xpath)`

15. **`element_x(xpath : String, opts : QueryOptions? = nil) : Element`**
    - Find element by XPath
    - Go: `Page.ElementX(xpath)`
    - Implementation: Use Document.evaluate() JS function

16. **`elements_x(xpath : String) : Elements`**
    - Find all elements by XPath
    - Go: `Page.ElementsX(xpath)`

### Regex/Text Queries

17. **`has_r(selector : String, js_regex : String) : Tuple(Bool, Element?)`**
    - Check if element matching selector has text matching regex
    - Go: `Page.HasR(selector, jsRegex)`
    - Implementation: Find element, check textContent against regex

18. **`element_r(selector : String, js_regex : String, opts : QueryOptions? = nil) : Element`**
    - Find element where text matches regex
    - Go: `Page.ElementR(selector, jsRegex)`
    - Implementation: Query elements, filter by regex match

### JavaScript Queries

19. **`element_by_js(js_function : String, opts : QueryOptions? = nil) : Element`**
    - Find element using JavaScript function
    - Go: `Page.ElementByJS(opts *EvalOptions)`
    - Implementation:
      - Execute JS that returns DOM node
      - Convert to RemoteObject
      - Wrap in Element
    - JS Function signature: `function() { return document.querySelector(...); }`

20. **`elements_by_js(js_function : String) : Elements`**
    - Find elements using JavaScript
    - Go: `Page.ElementsByJS(opts)`
    - JS Function signature: `function() { return document.querySelectorAll(...); }`

### Testing Phase 3

```crystal
describe "Advanced Queries" do
  describe "XPath" do
    it "finds by xpath" do
      el = page.element_x("//h1")
      el.should be_a(Element)
    end
    
    it "finds multiple by xpath" do
      els = page.elements_x("//p")
      els.should_not be_empty
    end
  end
  
  describe "Regex" do
    it "finds element by text regex" do
      el = page.element_r("p", "Hello.*")
      el.text.should match(/Hello.*/)
    end
  end
  
  describe "JavaScript" do
    it "finds by JS function" do
      el = page.element_by_js("() => document.querySelector('h1')")
      el.should be_a(Element)
    end
    
    it "finds multiple by JS" do
      els = page.elements_by_js("() => document.querySelectorAll('p')")
      els.should_not be_empty
    end
  end
end
```

---

## Phase 4: Search & Race

**File**: `src/rod/query.cr`  
**Estimated Effort**: 6 hours  
**Dependencies**: Phase 3 ✅

### Search Functionality

21. **`search(query : String) : SearchResult`**
    - Perform text search across page
    - Go: `Page.Search(query)`
    - CDP Method: `DOM.performSearch`
    - Returns: SearchResult handle

22. **`SearchResult` Class**
    ```crystal
    class SearchResult
      property search_id : String
      property result_count : Int32
      property page : Page
      
      def get(start : Int32, length : Int32) : Elements
        # Get range of results
        # Go: SearchResult.Get(i, l)
        # CDP: DOM.getSearchResults
      end
      
      def all : Elements
        # Get all results
        # Go: SearchResult.All()
        # Implementation: get(0, result_count)
      end
      
      def release : Nil
        # Clean up search
        # Go: SearchResult.Release()
        # CDP: DOM.discardSearchResults
      end
    end
    ```

### Race Functionality

23. **`race : RaceContext`**
    - Start race condition for finding elements
    - Go: `Page.Race()`
    - Returns: RaceContext for chaining

24. **`RaceContext` Class**
    ```crystal
    class RaceContext
      @page : Page
      @branches : Array(RaceBranch)
      @handler : Proc(Element, Nil)?
      
      def element(selector : String) : self
        # Add CSS selector branch
        # Go: RaceContext.Element(selector)
      end
      
      def element_x(xpath : String) : self
        # Add XPath branch
        # Go: RaceContext.ElementX(xpath)
      end
      
      def element_r(selector : String, regex : String) : self
        # Add regex branch
        # Go: RaceContext.ElementR(selector, regex)
      end
      
      def element_by_js(js : String) : self
        # Add JS branch
        # Go: RaceContext.ElementByJS(opts)
      end
      
      def search(query : String) : self
        # Add search branch
        # Go: RaceContext.Search(query)
      end
      
      def element_func(fn : Proc(Page, Element)) : self
        # Add custom function branch
        # Go: RaceContext.ElementFunc(fn)
      end
      
      def handle(&callback : Element -> Nil) : self
        # Set callback for when element found
        # Go: RaceContext.Handle(callback)
      end
      
      def do : Element
        # Execute race, return first matching element
        # Go: RaceContext.Do()
        # Implementation: Try all branches concurrently, return first success
      end
    end
    ```

25. **`RaceBranch` Struct**
    ```crystal
    struct RaceBranch
      property name : String
      property find_func : Proc(Page, Element)
      property priority : Int32
    end
    ```

### Testing Phase 4

```crystal
describe "Search" do
  it "searches for text" do
    result = page.search("Hello")
    result.result_count.should be > 0
    
    els = result.all
    els.should_not be_empty
    
    result.release
  end
end

describe "Race" do
  it "finds first matching element" do
    el = page.race
      .element("#first")
      .element("#second")
      .do
    
    el.should be_a(Element)
  end
  
  it "handles callback" do
    found = nil
    el = page.race
      .element("button")
      .handle { |e| found = e }
      .do
    
    found.should eq(el)
  end
end
```

---

## Phase 5: Element Queries

**File**: `src/rod/element.cr` (add methods)  
**Estimated Effort**: 4 hours  
**Dependencies**: Phase 2 ✅, Element type ✅

### Scoped Queries on Element

#### Existence Checks

26. **`Element#has(selector : String) : Tuple(Bool, Element?)`**
    - Check if child element exists
    - Go: `Element.Has(selector)`
    - Implementation: Scoped to this element's subtree

27. **`Element#has_x(xpath : String) : Tuple(Bool, Element?)`**
    - Check existence by XPath within element
    - Go: `Element.HasX(xpath)`

28. **`Element#has_r(selector : String, js_regex : String) : Tuple(Bool, Element?)`**
    - Check existence with regex match
    - Go: `Element.HasR(selector, jsRegex)`

#### Single Element Queries

29. **`Element#element(selector : String, opts : QueryOptions? = nil) : Element`**
    - Find child element by CSS selector
    - Go: `Element.Element(selector)`
    - Implementation: Use `element.querySelector()`

30. **`Element#element_r(selector : String, js_regex : String, opts : QueryOptions? = nil) : Element`**
    - Find child by selector + text regex
    - Go: `Element.ElementR(selector, jsRegex)`

31. **`Element#element_x(xpath : String, opts : QueryOptions? = nil) : Element`**
    - Find child by XPath
    - Go: `Element.ElementX(xpath)`
    - Implementation: Use `document.evaluate()` with context node

32. **`Element#element_by_js(js_function : String, opts : QueryOptions? = nil) : Element`**
    - Find child using JS
    - Go: `Element.ElementByJS(opts)`
    - JS Function: receives element as `this`

#### Multiple Element Queries

33. **`Element#elements(selector : String) : Elements`**
    - Find all child elements by CSS
    - Go: `Element.Elements(selector)`
    - Implementation: Use `element.querySelectorAll()`

#### Navigation Methods

34. **`Element#parent : Element?`**
    - Get parent element
    - Go: `Element.Parent()`
    - Implementation: `element.parentElement`
    - Returns nil if no parent (root element)

35. **`Element#parents(selector : String? = nil) : Elements`**
    - Get ancestor elements, optionally filtered by selector
    - Go: `Element.Parents(selector)`
    - Implementation: Walk up parent chain

36. **`Element#next : Element?`**
    - Get next sibling element
    - Go: `Element.Next()`
    - Implementation: `element.nextElementSibling`

37. **`Element#previous : Element?`**
    - Get previous sibling element
    - Go: `Element.Previous()`
    - Implementation: `element.previousElementSibling`

### Testing Phase 5

```crystal
describe "Element Queries" do
  let(:container) { page.element("#container") }
  
  describe "#element" do
    it "finds child element" do
      child = container.element(".child")
      child.should be_a(Element)
    end
    
    it "raises for non-existent child" do
      expect_raises(Rod::NotFoundError) do
        container.element(".nonexistent")
      end
    end
  end
  
  describe "#elements" do
    it "finds all child elements" do
      children = container.elements(".item")
      children.size.should eq(3)
    end
  end
  
  describe "navigation" do
    let(:child) { container.element(".child") }
    
    it "gets parent" do
      parent = child.parent
      parent.should eq(container)
    end
    
    it "gets next sibling" do
      next_sib = child.next
      next_sib.should_not be_nil
    end
    
    it "gets previous sibling" do
      prev = child.previous
      prev.should be_nil # First child
    end
  end
end
```

---

## Integration Testing

### Full Query Test Suite

```crystal
describe "Query Integration" do
  it "handles complex query workflow" do
    # Navigate to test page
    browser = Rod::Browser.new
    browser.connect("ws://...")
    page = browser.page
    
    # Use various query methods
    header = page.element("header")
    nav = header.element("nav")
    links = nav.elements("a")
    
    # XPath
    main = page.element_x("//main")
    
    # Regex
    button = page.element_r("button", "Submit.*")
    
    # Navigation
    first_link = links.first
    parent = first_link.parent
    
    # Cleanup
    browser.close
  end
  
  it "handles race conditions" do
    page = browser.page
    
    # Race multiple selectors
    winner = page.race
      .element("#option1")
      .element_x("//div[@id='option2']")
      .element_r("span", "Option 3")
      .do
    
    winner.should be_a(Element)
  end
  
  it "handles search across page" do
    result = page.search("important text")
    matches = result.all
    matches.each { |el| el.should be_a(Element) }
    result.release
  end
end
```

---

## Implementation Order

1. **Week 1**: Phases 1-2 (Collection types + Basic queries)
   - Create `src/rod/query.cr`
   - Add Elements/Pages aliases
   - Implement Has, Element, Elements on Page
   - Write tests

2. **Week 2**: Phase 3 (Advanced queries)
   - XPath queries
   - Regex queries
   - JavaScript queries
   - Write tests

3. **Week 3**: Phase 4 (Search & Race)
   - SearchResult class
   - RaceContext class
   - Write tests

4. **Week 4**: Phase 5 (Element queries)
   - Add scoped queries to Element
   - Add navigation methods
   - Write tests
   - Integration testing

---

## Notes

### Crystal vs Go Differences

1. **Error Handling**: Go returns `(T, error)`, Crystal raises exceptions
   - Go: `el, err := page.Element("#id")`
   - Crystal: `el = page.element("#id")` (raises NotFoundError)

2. **Optional Returns**: Go uses nil, Crystal uses union types
   - Go: `func (els Elements) First() *Element` (nil if empty)
   - Crystal: `def first : Element?` (nilable type)

3. **Method Naming**: Go uses PascalCase, Crystal uses snake_case
   - Go: `ElementByJS`
   - Crystal: `element_by_js`

4. **Type Aliases**: 
   - Go: `type Elements []*Element`
   - Crystal: `alias Elements = Array(Element)`

### Performance Considerations

1. **Query Caching**: Consider caching query results within a tick
2. **Lazy Evaluation**: Don't resolve elements until needed
3. **Concurrent Queries**: Race uses concurrent evaluation
4. **Memory Management**: Release SearchResult when done

### Testing Requirements

1. **Mock Browser**: Create test doubles for Browser/Page
2. **HTML Fixtures**: Standard test pages for consistent queries
3. **Async Testing**: Test timeout and retry behavior
4. **Error Cases**: Test all failure modes

---

## Success Criteria

- [ ] All 37 methods implemented
- [ ] 90%+ test coverage
- [ ] Integration tests pass
- [ ] Documentation complete
- [ ] Performance benchmarks acceptable
- [ ] Close rod-42c

## Related Issues

- rod-6o3 (Element type) - ✅ Complete
- rod-e1s (JavaScript Evaluation) - Required for ElementByJS
- rod-4z0 (Element query methods) - Related, may overlap

---

*Last Updated*: 2025-02-21  
*Assigned To*: Development Team  
*Review Required*: Yes, before Phase 3
