require "./spec_helper"

private class SearchRetryBrowser < Rod::Browser
  getter method_calls = [] of String

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    %({}).to_slice
  end
end

private class SearchRetryPage < Rod::Page
  alias QueueItem = String | Exception

  getter method_calls = [] of String
  property element_error : Exception? = nil
  @queues = Hash(String, Array(QueueItem)).new { |h, k| h[k] = [] of QueueItem }

  def initialize(browser : SearchRetryBrowser)
    super(browser, Rod::TargetID.new("search-target"))
  end

  def enqueue(method : String, payload : String) : Nil
    @queues[method] << payload
  end

  def enqueue_error(method : String, ex : Exception) : Nil
    @queues[method] << ex
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method

    if @queues[method].empty?
      return %({}).to_slice
    end

    item = @queues[method].shift
    case item
    when Exception
      raise item
    else
      item.to_slice
    end
  end

  def element_from_node(node_id : Cdp::DOM::NodeId) : Rod::Element
    if ex = @element_error
      raise ex
    end

    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"node-#{node_id}"}))
    Rod::Element.new(obj, self)
  end
end

describe "page search parity" do
  it "retries when CDP reports context-not-found during search" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.sleeper = -> { Rod::Util::Utils.count_sleeper(1) }

    page.enqueue_error("DOM.performSearch", Exception.new("Cannot find context with specified id (-32000)"))
    page.enqueue_error("DOM.performSearch", Exception.new("Cannot find context with specified id (-32000)"))

    expect_raises(Rod::Util::Utils::MaxSleepCountError) { page.search("button") }
    page.method_calls.count("DOM.performSearch").should be >= 2
  end

  it "retries when CDP reports search-session-not-found during getSearchResults" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.sleeper = -> { Rod::Util::Utils.count_sleeper(1) }

    2.times do |i|
      page.enqueue("DOM.performSearch", %({"searchId":"sid-#{i}","resultCount":1}))
      page.enqueue_error("DOM.getSearchResults", Exception.new("No search session with given id found (-32000)"))
    end

    expect_raises(Rod::Util::Utils::MaxSleepCountError) { page.search("button") }
    page.method_calls.count("DOM.getSearchResults").should be >= 2
  end

  it "handles node id zero by refreshing document and retrying until non-zero node appears" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)

    page.enqueue("DOM.performSearch", %({"searchId":"sid-1","resultCount":1}))
    page.enqueue("DOM.getSearchResults", %({"nodeIds":[0]}))
    page.enqueue("DOM.getDocument", %({"root":{"nodeId":1,"backendNodeId":2,"nodeType":9,"nodeName":"#document","localName":"","nodeValue":""}}))

    page.enqueue("DOM.performSearch", %({"searchId":"sid-2","resultCount":1}))
    page.enqueue("DOM.getSearchResults", %({"nodeIds":[7]}))

    sr = page.search("button")

    sr.first.should_not be_nil
    sr.first.not_nil!.object.object_id.should eq("node-7")
    page.method_calls.should contain("DOM.getDocument")
    page.method_calls.should contain("DOM.discardSearchResults")
  end

  it "retries when performSearch returns zero result count" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.sleeper = -> { Rod::Util::Utils.count_sleeper(1) }

    page.enqueue("DOM.performSearch", %({"searchId":"sid-0","resultCount":0}))
    page.enqueue("DOM.performSearch", %({"searchId":"sid-1","resultCount":0}))

    expect_raises(Rod::Util::Utils::MaxSleepCountError) { page.search("missing") }
    page.method_calls.count("DOM.performSearch").should be >= 2
  end

  it "returns ElementNotFoundError when search uses not_found_sleeper" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.sleeper = -> { Rod::Util::Utils::Sleeper.new { |_ctx| Rod::ElementNotFoundError.new.as(Exception) } }
    page.enqueue("DOM.performSearch", %({"searchId":"sid-0","resultCount":0}))

    expect_raises(Rod::ElementNotFoundError) { page.search("missing") }
  end

  it "propagates non-retry errors from performSearch" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.enqueue_error("DOM.performSearch", Exception.new("perform search failed"))

    expect_raises(Exception, /perform search failed/) { page.search("button") }
  end

  it "propagates non-retry errors from getSearchResults" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.enqueue("DOM.performSearch", %({"searchId":"sid-1","resultCount":1}))
    page.enqueue_error("DOM.getSearchResults", Exception.new("get search results failed"))

    expect_raises(Exception, /get search results failed/) { page.search("button") }
  end

  it "propagates element resolution errors after getSearchResults" do
    browser = SearchRetryBrowser.new
    page = SearchRetryPage.new(browser)
    page.enqueue("DOM.performSearch", %({"searchId":"sid-1","resultCount":1}))
    page.enqueue("DOM.getSearchResults", %({"nodeIds":[7]}))
    page.element_error = Exception.new("resolve node failed")

    expect_raises(Exception, /resolve node failed/) { page.search("button") }
  end
end
