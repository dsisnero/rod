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

  it "inputs a time with go's inputTime helper as a user gesture" do
    page = InputRecorderPage.new
    element = InputStubElement.new(page)
    t = Time.utc(2026, 11, 21, 8, 45)

    element.input_time(t)

    dispatch = page.eval_options.last
    dispatch.user_gesture?.should be_true
    dispatch.js_args.first.as(Rod::JS::Function).name.should eq("inputTime")
    dispatch.js_args[1].should eq(t.to_unix_ms)
  end

  it "inputs a color with go's inputColor helper" do
    page = InputRecorderPage.new
    element = InputStubElement.new(page)

    element.input_color("#ff0000")

    dispatch = page.eval_options.last
    dispatch.user_gesture?.should be_false
    dispatch.js_args.first.as(Rod::JS::Function).name.should eq("inputColor")
    dispatch.js_args[1].should eq("#ff0000")
  end
end

describe "element contains parity" do
  it "uses go's containsElement helper with the target remote object" do
    page = InputRecorderPage.new
    element = InputStubElement.new(page)
    target = InputStubElement.new(page)

    element.contains_element(target).should be_true

    call = page.eval_options.last
    call.js_args.first.as(Rod::JS::Function).name.should eq("containsElement")
    call.js_args[1].as(::Cdp::Runtime::RemoteObject).object_id.should eq("obj-input")
  end
end

# The shared `js.InputTime` helper formats the value from `this.type` and
# dispatches through `functions.inputEvent`, so the helper path needs a real
# input to prove the dependency graph and the `this` binding still work.
private INPUT_HELPER_HTML = <<-HTML
  <input type="date" id="date">
  <input type="color" id="color">
  <div id="root"><span id="kid"></span></div>
  HTML

describe "element input helpers with a live page" do
  it "inputs dates and colors through go's helpers" do
    RodSpec.with_live_browser do |browser|
      # go-rod's `Element.InputTime`/`InputColor` tests run against a fixture;
      # swapping the document in place keeps this example off the file system.
      page = browser.must_page("about:blank")
      begin
        page.set_document_content(INPUT_HELPER_HTML)

        with_date = page.element("#date", Rod::QueryOptions.new(timeout: 1.second))
        with_date.input_time(Time.utc(2024, 1, 2, 12, 30))
        with_date.property("value").as_s.should eq("2024-01-02")

        with_color = page.element("#color", Rod::QueryOptions.new(timeout: 1.second))
        with_color.input_color("#ff0000")
        with_color.property("value").as_s.should eq("#ff0000")

        root = page.element("#root", Rod::QueryOptions.new(timeout: 1.second))
        kid = page.element("#kid", Rod::QueryOptions.new(timeout: 1.second))
        root.contains_element(kid).should be_true
        root.contains_element(root).should be_true
        kid.contains_element(root).should be_false
      ensure
        page.must_close
      end
    end
  end
end
