require "./spec_helper"

private class SearchResultStubPage < Rod::Page
  property method_calls : Array(String) = [] of String
  property responses : Hash(String, String) = {} of String => String
  property element_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    payload = @responses[method]?
    raise "missing stub for method #{method}" unless payload
    payload.to_slice
  end

  def element_from_node(node_id : Cdp::DOM::NodeId) : Rod::Element
    if ex = @element_error
      raise ex
    end

    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"node-#{node_id}","description":"div"}))
    Rod::Element.new(obj, self)
  end
end

describe Rod::SearchResult do
  it "get maps node ids to elements" do
    page = SearchResultStubPage.new
    page.responses["DOM.getSearchResults"] = %({"nodeIds":[1,2]})

    sr = Rod::SearchResult.new(Cdp::DOM::PerformSearchResult.new("sid", 2), page, -> { })
    all = sr.get(0, 2)

    all.size.should eq(2)
    all.first.not_nil!.object.object_id.should eq("node-1")
    all.last.not_nil!.object.object_id.should eq("node-2")
    page.method_calls.should contain("DOM.getSearchResults")
  end

  it "all delegates to get with total result count" do
    page = SearchResultStubPage.new
    page.responses["DOM.getSearchResults"] = %({"nodeIds":[7,8,9]})

    sr = Rod::SearchResult.new(Cdp::DOM::PerformSearchResult.new("sid", 3), page, -> { })
    all = sr.all

    all.size.should eq(3)
  end

  it "release runs restore and discards search results" do
    page = SearchResultStubPage.new
    page.responses["DOM.discardSearchResults"] = %({})
    restored = false

    sr = Rod::SearchResult.new(Cdp::DOM::PerformSearchResult.new("sid", 1), page, -> { restored = true })
    sr.release

    restored.should be_true
    page.method_calls.should contain("DOM.discardSearchResults")
  end

  it "propagates element resolution errors from get" do
    page = SearchResultStubPage.new
    page.responses["DOM.getSearchResults"] = %({"nodeIds":[1]})
    page.element_error = Exception.new("resolve failed")

    sr = Rod::SearchResult.new(Cdp::DOM::PerformSearchResult.new("sid", 1), page, -> { })
    expect_raises(Exception, "resolve failed") { sr.get(0, 1) }
  end
end
