require "./spec_helper"

private class SlowRenderStubBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    %({}).to_slice
  end
end

private class SlowRenderStubPage < Rod::Page
  property query_selector_calls = 0

  def initialize
    super(SlowRenderStubBrowser.new, Rod::TargetID.new("target-id"))
  end

  def element_from_node(node_id : Cdp::DOM::NodeId) : Rod::Element
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"node-#{node_id}"}))
    Rod::Element.new(obj, self)
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    case method
    when "DOM.getDocument"
      %({"root":{"nodeId":1,"backendNodeId":2,"nodeType":9,"nodeName":"#document","localName":"","nodeValue":""}}).to_slice
    when "DOM.querySelector"
      @query_selector_calls += 1
      node_id = @query_selector_calls >= 3 ? 42 : 0
      %({"nodeId":#{node_id}}).to_slice
    else
      raise "unexpected method: #{method}"
    end
  end
end

describe "page slow render parity" do
  it "retries css query until element appears within timeout" do
    page = SlowRenderStubPage.new
    opts = Rod::QueryOptions.new(timeout: 120.milliseconds, retry_interval: 10.milliseconds)

    element = page.element("div", opts)
    element.object.object_id.should eq("node-42")
    page.query_selector_calls.should be >= 3
  end
end
