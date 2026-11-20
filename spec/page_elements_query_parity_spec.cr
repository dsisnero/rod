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
    when "Runtime.evaluate"
      %({"result":{"type":"object","objectId":"window-1"}}).to_slice
    when "Runtime.callFunctionOn"
      # `element_from_object` resolves each element's JS context first
      # (go `jsCtxIDByObjectID`, `page.go:900-916`).
      %({"result":{"type":"object","objectId":"window-1"}}).to_slice
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

  it "elements_by_js raises go's ExpectElementsError when js does not return an array" do
    page = PageElementsByJSValueStub.new
    page.eval_result = Cdp::Runtime::RemoteObject.from_json(%({"type":"number","value":1}))

    # go: `if res.Subtype != array { return nil, &ExpectElementsError{res} }`
    # (`query.go:212-214`).
    err = expect_raises(Rod::ExpectElementsError) do
      page.elements_by_js(Rod::EvalOptions.new(js: "() => 1"))
    end
    err.message.as(String).should contain("expect js to return an array of elements")
    err.remote_object.not_nil!.type.should eq("number")
    page.release_calls.should eq(0)
  end

  it "elements_by_js raises go's ExpectElementsError when an array item is not a DOM node" do
    page = PageElementsByJSValueStub.new
    page.get_properties_payload = %({
      "result":[
        {"name":"0","value":{"type":"number","value":1},"configurable":true,"enumerable":true},
        {"name":"length","value":{"type":"number","value":1},"configurable":true,"enumerable":true}
      ]
    })

    err = expect_raises(Rod::ExpectElementsError) do
      page.elements_by_js(Rod::EvalOptions.new(js: "() => [1]"))
    end
    # go carries the offending value (`&ExpectElementsError{val}`, `query.go:233-235`)
    # and the array is still released by the defer.
    err.remote_object.not_nil!.value.not_nil!.raw.should eq(1)
    page.release_calls.should eq(1)
  end

  it "elements_by_js raises go's ExpectElementsError for a property without a value" do
    page = PageElementsByJSValueStub.new
    # An accessor descriptor has no `value`; go compares `val.Subtype` and fails.
    page.get_properties_payload = %({
      "result":[
        {"name":"0","get":{"type":"function","objectId":"getter-1"},"configurable":true,"enumerable":true},
        {"name":"length","value":{"type":"number","value":1},"configurable":true,"enumerable":true}
      ]
    })

    err = expect_raises(Rod::ExpectElementsError) do
      page.elements_by_js(Rod::EvalOptions.new(js: "() => [1]"))
    end
    err.message.as(String).should contain("but got: null")
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
