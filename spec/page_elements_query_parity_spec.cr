require "./spec_helper"

private class QueryElementsStubBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    %({}).to_slice
  end
end

private class PageElementsStub < Rod::Page
  property method_calls = [] of String
  property get_properties_payload = %({"result":[]})
  property get_properties_error : Exception? = nil
  property release_calls = 0

  def initialize(browser : Rod::Browser = QueryElementsStubBrowser.new)
    super(browser, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    _ = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"array","objectId":"arr-1"}))
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
    when "DOM.querySelectorAll"
      %({"nodeIds":[3,0,4]}).to_slice
    when "Runtime.getProperties"
      if ex = @get_properties_error
        raise ex
      end
      @get_properties_payload.to_slice
    when "Runtime.releaseObject"
      @release_calls += 1
      %({}).to_slice
    else
      raise "unexpected method: #{method}"
    end
  end
end

private class PageElementsByJSValueStub < PageElementsStub
  property eval_result = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"array","objectId":"arr-1"}))

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    _ = opts
    @eval_result
  end
end

describe "page elements query parity" do
  it "page.elements maps querySelectorAll node ids to elements and skips zero ids" do
    page = PageElementsStub.new

    result = page.elements("button")
    result.size.should eq(2)
    result.first.not_nil!.object.object_id.should eq("node-3")
    result.last.not_nil!.object.object_id.should eq("node-4")
    page.method_calls.should contain("DOM.querySelectorAll")
  end

  it "elements_by_js maps Runtime.getProperties array entries to elements" do
    page = PageElementsByJSValueStub.new
    page.get_properties_payload = %({
      "result":[
        {"name":"0","value":{"type":"object","subtype":"node","objectId":"node-1"},"configurable":true,"enumerable":true},
        {"name":"1","value":{"type":"object","subtype":"node","objectId":"node-2"},"configurable":true,"enumerable":true},
        {"name":"length","value":{"type":"number","value":2},"configurable":true,"enumerable":true}
      ]
    })

    els = page.elements_by_js(Rod::EvalOptions.new(js: "() => []"))
    els.size.should eq(2)
    page.release_calls.should eq(1)
  end

  it "elements_by_js raises when js does not return an array object" do
    page = PageElementsByJSValueStub.new
    page.eval_result = Cdp::Runtime::RemoteObject.from_json(%({"type":"number","value":1}))

    expect_raises(Exception, /did not return an array/) do
      page.elements_by_js(Rod::EvalOptions.new(js: "() => 1"))
    end
    page.release_calls.should eq(0)
  end

  it "elements_by_js raises when array item is not a DOM node and still releases array" do
    page = PageElementsByJSValueStub.new
    page.get_properties_payload = %({
      "result":[
        {"name":"0","value":{"type":"number","value":1},"configurable":true,"enumerable":true},
        {"name":"length","value":{"type":"number","value":1},"configurable":true,"enumerable":true}
      ]
    })

    expect_raises(Exception, /Expected DOM node/) do
      page.elements_by_js(Rod::EvalOptions.new(js: "() => [1]"))
    end
    page.release_calls.should eq(1)
  end

  it "elements_by_js propagates getProperties errors and still releases array" do
    page = PageElementsByJSValueStub.new
    page.get_properties_error = Exception.new("get properties failed")

    expect_raises(Exception, /get properties failed/) do
      page.elements_by_js(Rod::EvalOptions.new(js: "() => [document.body]"))
    end
    page.release_calls.should eq(1)
  end
end
