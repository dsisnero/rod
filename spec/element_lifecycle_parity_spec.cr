require "spec"
require "../src/rod"

private class ElementLifecycleStubPage < Rod::Page
  getter evaluated = [] of String
  getter released = [] of String

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def evaluate(js : String, args : Array(JSON::Any)? = nil) : Cdp::Runtime::RemoteObject
    _ = args
    @evaluated << js
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @evaluated << opts.js
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end

  def release(obj : Cdp::Runtime::RemoteObject) : Nil
    if id = obj.object_id
      @released << id
    end
  end
end

describe Rod::Element do
  it "#release delegates to page.release with current element object" do
    page = ElementLifecycleStubPage.new
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"obj-1"}))
    element = Rod::Element.new(obj, page)

    element.release
    page.released.should eq(["obj-1"])
  end

  it "#remove evaluates DOM removal and then releases object" do
    page = ElementLifecycleStubPage.new
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"obj-2"}))
    element = Rod::Element.new(obj, page)

    element.remove
    page.evaluated.should contain("() => this.remove()")
    page.released.should eq(["obj-2"])
  end
end
