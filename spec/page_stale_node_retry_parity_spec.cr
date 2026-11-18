require "./spec_helper"

# After a navigation, Chrome can answer `DOM.querySelector` with
# `-32000 No node with given id found` because the cached document root belongs
# to the previous document. go-rod retries the query after resetting its DOM
# tracker, so an element lookup that races a navigation still resolves. The port
# retried only for the two other stale-node phrasings Chrome uses
# ("Could not find node with given id" / "Node with given id does not belong to
# the document"), so this one escaped as `Element not found` — which is what made
# `spec/page_iframe_reload_parity_spec.cr` flake once it ran on the pooled
# browser.
private STALE_NODE_MESSAGES = [
  "No node with given id found",
  "Could not find node with given id",
  "Node with given id does not belong to the document",
]

private class StaleNodeStubBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    %({}).to_slice
  end
end

private class StaleNodeStubPage < Rod::Page
  property method_calls = [] of String
  property query_failures : Int32
  property stale_message : String

  def initialize(@stale_message : String = STALE_NODE_MESSAGES.first, @query_failures : Int32 = 1)
    super(StaleNodeStubBrowser.new, Rod::TargetID.new("target-id"))
  end

  def element_from_node(node_id : Cdp::DOM::NodeId) : Rod::Element
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"node-#{node_id}"}))
    Rod::Element.new(obj, self)
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    @method_calls << method

    case method
    when "DOM.getDocument"
      %({"root":{"nodeId":1,"backendNodeId":2,"nodeType":9,"nodeName":"#document","localName":"","nodeValue":""}}).to_slice
    when "DOM.querySelector"
      if @query_failures > 0
        @query_failures -= 1
        # The CDP client raises the error's `to_s`, not a typed exception.
        raise Exception.new("{-32000 #{@stale_message} }")
      end
      %({"nodeId":3}).to_slice
    else
      %({}).to_slice
    end
  end
end

describe "page stale node retry parity" do
  STALE_NODE_MESSAGES.each do |message|
    it "retries the element query for '#{message}'" do
      page = StaleNodeStubPage.new(stale_message: message)

      element = page.element("iframe")

      element.object.object_id.should eq("node-3")
      page.method_calls.count("DOM.querySelector").should eq(2)
      page.method_calls.count("DOM.getDocument").should eq(2)
    end
  end

  it "keeps retrying past the two inline attempts until the query deadline" do
    # go-rod retries the lookup until the page deadline, so a document that is
    # replaced more than once during navigation still resolves.
    page = StaleNodeStubPage.new(stale_message: STALE_NODE_MESSAGES.first, query_failures: 3)

    element = page.element("iframe")

    element.object.object_id.should eq("node-3")
    page.method_calls.count("DOM.querySelector").should eq(4)
  end
end
