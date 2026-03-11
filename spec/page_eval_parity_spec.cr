require "spec"
require "../src/rod"

private class EvalDocStubPage < Rod::Page
  getter methods = [] of String
  getter params = {} of String => JSON::Any
  @responses = {} of String => String
  @errors = {} of String => Exception

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def set_response(method : String, payload : String) : Nil
    @responses[method] = payload
  end

  def set_error(method : String, error : Exception) : Nil
    @errors[method] = error
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @methods << method
    @params[method] = params

    if error = @errors[method]?
      raise error
    end

    (@responses[method]? || %({})).to_slice
  end
end

describe Rod::Page do
  it "#eval_on_new_document adds script and removes it by identifier" do
    page = EvalDocStubPage.new
    page.set_response("Page.addScriptToEvaluateOnNewDocument", %({"identifier":"script-1"}))
    page.set_response("Page.removeScriptToEvaluateOnNewDocument", %({}))

    remove = page.eval_on_new_document("window.rod = 'ok'")
    page.methods.should contain("Page.addScriptToEvaluateOnNewDocument")

    remove.call
    page.methods.should contain("Page.removeScriptToEvaluateOnNewDocument")
    page.params["Page.removeScriptToEvaluateOnNewDocument"]["identifier"].as_s.should eq("script-1")
  end

  it "#eval_on_new_document surfaces CDP add-script errors" do
    page = EvalDocStubPage.new
    page.set_error("Page.addScriptToEvaluateOnNewDocument", Exception.new("add script failed"))

    expect_raises(Exception, /add script failed/) do
      page.eval_on_new_document("1")
    end
  end
end

private class ObjectJSONStubPage < Rod::Page
  getter methods = [] of String
  property call_function_error : Exception?

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @methods << method
    case method
    when "Runtime.callFunctionOn"
      if error = @call_function_error
        raise error
      end
      %({"result":{"type":"object","value":{"k":"v"}}}).to_slice
    when "Runtime.releaseObject"
      %({}).to_slice
    else
      raise "unexpected method: #{method}"
    end
  end
end

private class ElementFromNodeErrorPage < Rod::Page
  property resolve_error : Exception? = nil
  property call_function_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    if method == "DOM.resolveNode"
      if err = @resolve_error
        raise err
      end
      return %({"object":{"type":"object","subtype":"node","objectId":"obj-1"}}).to_slice
    end

    if method == "Runtime.evaluate"
      return %({"result":{"type":"object","objectId":"window-1"}}).to_slice
    end

    if method == "Runtime.callFunctionOn"
      if err = @call_function_error
        raise err
      end
      return %({"result":{"type":"object","objectId":"ctx-1"}}).to_slice
    end

    raise "unexpected method: #{method}"
  end
end

describe Rod::Page do
  it "#object_to_json returns value directly for by-value remote objects" do
    page = ObjectJSONStubPage.new
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","value":{"a":1}}))

    result = page.object_to_json(obj)
    result["a"].as_i.should eq(1)
    page.methods.should_not contain("Runtime.callFunctionOn")
  end

  it "#object_to_json resolves object IDs through Runtime.callFunctionOn" do
    page = ObjectJSONStubPage.new
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1"}))

    result = page.object_to_json(obj)
    result["k"].as_s.should eq("v")
    page.methods.should contain("Runtime.callFunctionOn")
  end

  it "#object_to_json surfaces runtime errors for invalid object IDs" do
    page = ObjectJSONStubPage.new
    page.call_function_error = Exception.new("Could not find object with given id")
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"not-exists"}))

    expect_raises(Exception, /Could not find object/) do
      page.object_to_json(obj)
    end
  end

  it "#release sends Runtime.releaseObject only for object-id backed objects" do
    page = ObjectJSONStubPage.new
    with_id = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1"}))
    by_value = Cdp::Runtime::RemoteObject.from_json(%({"type":"number","value":1}))

    page.release(with_id)
    page.release(by_value)

    page.methods.count("Runtime.releaseObject").should eq(1)
  end

  it "#element_from_node(node_id) surfaces resolve-node errors" do
    page = ElementFromNodeErrorPage.new
    page.resolve_error = Exception.new("resolve node failed")

    expect_raises(Exception, /resolve node failed/) do
      page.element_from_node(-1_i64)
    end
  end

  it "#element_from_node(node) surfaces resolve-node errors" do
    page = ElementFromNodeErrorPage.new
    page.resolve_error = Exception.new("resolve node failed")
    node = Cdp::DOM::Node.from_json(
      {
        "nodeId"         => 1,
        "backendNodeId"  => 10,
        "nodeType"       => 1,
        "nodeName"       => "BODY",
        "localName"      => "body",
        "nodeValue"      => "",
        "childNodeCount" => 0,
      }.to_json
    )

    expect_raises(Exception, /resolve node failed/) do
      page.element_from_node(node)
    end
  end

  it "#element_from_node(node) surfaces runtime call-function errors (go TestElementFromNodeErr parity)" do
    page = ElementFromNodeErrorPage.new
    page.call_function_error = Exception.new("Runtime.callFunctionOn failed")
    node = Cdp::DOM::Node.from_json(
      {
        "nodeId"         => 1,
        "backendNodeId"  => 10,
        "nodeType"       => 1,
        "nodeName"       => "BUTTON",
        "localName"      => "button",
        "nodeValue"      => "",
        "childNodeCount" => 0,
      }.to_json
    )

    expect_raises(Exception, /Runtime.callFunctionOn failed/) do
      page.element_from_node(node)
    end
  end
end

private class ExposeStubBrowser < Rod::Browser
  getter methods = [] of String
  @errors = {} of String => Exception

  def set_error(method : String, error : Exception) : Nil
    @errors[method] = error
  end

  def each_event(session_id : Rod::SessionID?, callbacks : Hash(String, Rod::Browser::CallbackInfo)) : Proc(Nil)
    -> { }
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @methods << method
    if error = @errors[method]?
      raise error
    end

    case method
    when "Page.addScriptToEvaluateOnNewDocument"
      %({"identifier":"script-1"}).to_slice
    else
      %({}).to_slice
    end
  end
end

private class ExposeStubPage < Rod::Page
  property evaluate_error : Exception?

  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    if error = @evaluate_error
      raise error
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

describe Rod::Page do
  it "#expose surfaces add-binding errors" do
    browser = ExposeStubBrowser.new
    page = ExposeStubPage.new(browser)
    browser.set_error("Runtime.addBinding", Exception.new("add binding failed"))

    expect_raises(Exception, /add binding failed/) do
      page.expose("exposedFunc", ->(_payload : JSON::Any) { {nil, nil} })
    end
  end

  it "#expose removes binding when expose function evaluation fails" do
    browser = ExposeStubBrowser.new
    page = ExposeStubPage.new(browser)
    page.evaluate_error = Exception.new("expose eval failed")

    expect_raises(Exception, /expose eval failed/) do
      page.expose("exposedFunc", ->(_payload : JSON::Any) { {nil, nil} })
    end

    browser.methods.should contain("Runtime.addBinding")
    browser.methods.should contain("Runtime.removeBinding")
  end

  it "#expose returns a stop function that cleans up script and binding" do
    browser = ExposeStubBrowser.new
    page = ExposeStubPage.new(browser)

    stop = page.expose("exposedFunc", ->(_payload : JSON::Any) { {nil, nil} })
    browser.methods.should contain("Runtime.addBinding")
    browser.methods.should contain("Page.addScriptToEvaluateOnNewDocument")

    stop.call
    browser.methods.should contain("Page.removeScriptToEvaluateOnNewDocument")
    browser.methods.should contain("Runtime.removeBinding")
  end
end
