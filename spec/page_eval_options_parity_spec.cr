require "spec"
require "../src/rod"

describe Rod::EvalOptions do
  it "#format_to_js_func wraps and trims function declarations" do
    opts = Rod::EvalOptions.new(js: " ; () => 1; \n")
    opts.format_to_js_func.should eq("function() { return (() => 1).apply(this, arguments) }")
  end

  it "#to_s matches Go EvalOptions.String style with this object description" do
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","description":"button","objectId":"obj-1"}))
    opts = Rod::EvalOptions.new(js: "() => this.parentElement", this_obj: obj)

    opts.to_s.should eq("() => this.parentElement() button")
  end

  it "#to_s prints helper function calls as rod.<name>(...)" do
    opts = Rod::EvalOptions.new(
      js: "() => 0",
      js_args: [Rod::JS::ELEMENT.as(Rod::EvalOptions::JsArg), JSON::Any.new("button").as(Rod::EvalOptions::JsArg)]
    )

    opts.to_s.should eq(%(rod.element("button") ))
  end

  it "builder helpers toggle flags to match Go semantics" do
    opts = Rod::EvalOptions.new.by_object.by_user.by_promise

    opts.by_value?.should be_false
    opts.user_gesture?.should be_true
    opts.await_promise?.should be_true
  end
end
