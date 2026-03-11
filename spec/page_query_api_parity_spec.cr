require "./spec_helper"

private class QueryCapturePage < Rod::Page
  property last_element_opts : Rod::EvalOptions? = nil
  property last_elements_opts : Rod::EvalOptions? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def element_by_js(opts : Rod::EvalOptions) : Rod::Element
    @last_element_opts = opts
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","subtype":"node","description":"div"}))
    Rod::Element.new(obj, self)
  end

  def elements_by_js(opts : Rod::EvalOptions) : Rod::Elements
    @last_elements_opts = opts
    Rod::Elements.new([] of Rod::Element)
  end
end

describe "page query api parity" do
  it "element_x delegates through eval helper wiring" do
    page = QueryCapturePage.new
    _ = page.element_x("//div[@id='x']")

    opts = page.last_element_opts.not_nil!
    opts.js.should contain("f.apply(this, args)")
    opts.by_value?.should be_true
    opts.js_args.size.should eq(2)
    opts.js_args[1].should eq(JSON.parse(%("//div[@id='x']")))
  end

  it "elements_x delegates through eval helper wiring" do
    page = QueryCapturePage.new
    result = page.elements_x("//li")

    result.size.should eq(0)
    opts = page.last_elements_opts.not_nil!
    opts.js.should contain("f.apply(this, args)")
    opts.by_value?.should be_true
    opts.js_args.size.should eq(2)
    opts.js_args[1].should eq(JSON.parse(%("//li")))
  end
end
