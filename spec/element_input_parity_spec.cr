require "./spec_helper"

# go's `Element.Input` dispatches the synthetic change events with the shared
# `js.InputEvent` helper **as a user gesture**:
# `_, _ = el.Evaluate(evalHelper(js.InputEvent).ByUser())` (`element.go:261-280`).
# The port hand-wrote the same JavaScript without `.by_user`, so the events were
# dispatched outside a user gesture and the helper was never reused.
private class InputRecorderPage < Rod::Page
  getter eval_options = [] of Rod::EvalOptions

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : ::Cdp::Runtime::RemoteObject
    @eval_options << opts
    ::Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":true}))
  end

  def insert_text(text : String) : Nil
  end
end

private class InputStubElement < Rod::Element
  def initialize(page : Rod::Page)
    object = ::Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-input","description":"input"}))
    super(object, page)
  end

  def scroll_into_view : Nil
  end

  def wait_enabled : Nil
  end

  def wait_writable : Nil
  end
end

describe "element input parity" do
  it "dispatches the change events as a user gesture like go's Element#Input" do
    page = InputRecorderPage.new
    element = InputStubElement.new(page)

    element.input("hi")

    dispatch = page.eval_options.last
    dispatch.user_gesture?.should be_true
    dispatch.js_args.first.as(Rod::JS::Function).name.should eq("inputEvent")
  end
end
