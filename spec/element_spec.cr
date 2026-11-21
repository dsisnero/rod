require "./spec_helper"

# Element queries must run go-rod's shared `lib/js` helpers (`query.go:487-499`)
# rather than ad-hoc scripts, so a stub captures the helper function as the first
# JS argument, with the query arguments after it.
private def assert_js_helper(opts : Rod::EvalOptions, name : String, args : Array(JSON::Any)) : Nil
  fn = opts.js_args.first
  fn.should be_a(Rod::JS::Function)
  fn.as(Rod::JS::Function).name.should eq(name)
  opts.js_args[1..].should eq(args.map { |arg| arg.as(Rod::EvalOptions::JsArg) })
end

private class StubElement < Rod::Element
  property? eval_result : Bool = false
  property eval_error : Exception? = nil
  property last_js : String? = nil
  property last_args : Array(Rod::EvalOptions::JsArg) = [] of Rod::EvalOptions::JsArg
  property last_eval_opts : Rod::EvalOptions? = nil
  property next_element : Rod::Element? = nil
  property next_eval_values = [] of JSON::Any

  def initialize(page : Rod::Page)
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","description":"div"}))
    super(object, page)
  end

  def evaluate(js : String, *params) : Cdp::Runtime::RemoteObject
    @last_js = js
    converted = [] of Rod::EvalOptions::JsArg
    params.each do |param|
      case param
      when Rod::EvalOptions::JsArg
        converted << param
      else
        converted << JSON.parse(param.to_json)
      end
    end
    @last_args = converted

    if ex = @eval_error
      raise ex
    end

    if value = @next_eval_values.shift?
      json = if value.raw.nil?
               %({"type":"undefined"})
             elsif value.raw.is_a?(Bool)
               %({"type":"boolean","value":#{value.to_json}})
             elsif value.raw.is_a?(Int64) || value.raw.is_a?(Int32) || value.raw.is_a?(Float64)
               %({"type":"number","value":#{value.to_json}})
             else
               %({"type":"string","value":#{value.to_json}})
             end
      return Cdp::Runtime::RemoteObject.from_json(json)
    end

    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":#{@eval_result}}))
  end

  def element_by_js(opts : Rod::EvalOptions) : Rod::Element
    @last_eval_opts = opts
    @next_element || raise Rod::NotFoundError.new
  end
end

private class ElementsPage < Rod::Page
  property next_elements : Rod::Elements = Rod::Elements.new([] of Rod::Element)
  property last_eval_opts : Rod::EvalOptions? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def elements_by_js(opts : Rod::EvalOptions) : Rod::Elements
    @last_eval_opts = opts
    @next_elements
  end
end

private class CdpStubPage < Rod::Page
  @responses = {} of String => String
  property method_calls : Array(String) = [] of String
  property method_params : Hash(String, JSON::Any) = {} of String => JSON::Any

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def set_response(method : String, payload : String) : Nil
    @responses[method] = payload
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    @method_params[method] = params
    payload = @responses[method]?
    raise "missing stub for method #{method}" unless payload
    payload.to_slice
  end
end

private class InputPage < Rod::Page
  property inserted_texts : Array(String) = [] of String
  property insert_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def insert_text(text : String) : Nil
    @inserted_texts << text
    if ex = @insert_error
      raise ex
    end
  end
end

private class InputStubElement < StubElement
  property focus_called = false
  property wait_enabled_calls = 0
  property wait_writable_calls = 0
  property dispatch_opts : Rod::EvalOptions? = nil

  def focus : Nil
    @focus_called = true
  end

  # The dispatch goes through the `EvalOptions` overload, which records the
  # helper and the user-gesture flag.
  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @dispatch_opts = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":true}))
  end

  def wait_enabled : Nil
    @wait_enabled_calls += 1
  end

  def wait_writable : Nil
    @wait_writable_calls += 1
  end
end

private class MustSelectElement < StubElement
  property selected_args : Tuple(Array(String), Bool, String)? = nil

  def select(selectors : Array(String), selected : Bool = true, t : String = Rod::SelectorType::Text) : Nil
    @selected_args = {selectors, selected, t}
  end
end

private class InteractableStubElement < StubElement
  property pointer_blocked = false
  property contains_target = true
  property shape_error : Exception? = nil
  property quad_payload = Cdp::DOM::GetContentQuadsResult.new(
    [JSON.parse("[0,0,10,0,10,10,0,10]")] of Cdp::DOM::Quad
  )

  def evaluate(js : String, *params) : Cdp::Runtime::RemoteObject
    _ = params
    if js.includes?("pointerEvents")
      return Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":#{@pointer_blocked}}))
    end
    super
  end

  def shape : Cdp::DOM::GetContentQuadsResult
    if ex = @shape_error
      raise ex
    end
    @quad_payload
  end

  # The real `scroll_into_view` waits for a stable repaint through CDP
  # (`element.go:68-78`); these screenshot examples only care about what
  # `Element#screenshot` does after scrolling, and `#scroll_into_view` has its
  # own CDP-level example.
  def scroll_into_view : Nil
    if ex = @eval_error
      raise ex
    end
  end

  def contains_element(target : Rod::Element) : Bool
    _ = target
    @contains_target
  end
end

private class InteractableResultElement < StubElement
  def initialize(page : Rod::Page, @err : Exception?)
    super(page)
  end

  def interactable : Rod::Point
    if err = @err
      raise err
    end
    Rod::Point.new(1.0, 2.0)
  end
end

private class InteractableStubPage < Rod::Page
  property next_element_from_point : Rod::Element? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def eval(js : String, args : Array(JSON::Any) = [] of JSON::Any) : Cdp::Runtime::RemoteObject
    _ = js
    _ = args
    Cdp::Runtime::RemoteObject.from_json(%({"type":"object","value":{"x":0,"y":0}}))
  end

  def element_from_point(x : Int32, y : Int32) : Rod::Element
    _ = x
    _ = y
    @next_element_from_point || StubElement.new(self)
  end
end

private class ClickSpyMouse < Rod::Mouse
  property click_calls = [] of Tuple(String, Int32)

  def click(button : String, click_count : Int32 = 1) : Nil
    @click_calls << {button, click_count}
  end
end

private class MoveSpyMouse < Rod::Mouse
  property move_calls = [] of Rod::Point

  def move_to(p : Rod::Point) : Nil
    @move_calls << p
  end
end

private class TypeSpyKeyboard < Rod::Keyboard
  property typed_calls = [] of Array(Rod::Input::Key)

  def type(*keys : Rod::Input::Key) : Nil
    @typed_calls << keys.to_a
  end
end

private class TapSpyTouch < Rod::Touch
  property tap_calls = [] of Rod::Point

  def tap(x : Float64, y : Float64) : Nil
    @tap_calls << Rod::Point.new(x, y)
  end
end

private class ClickFlowStubElement < StubElement
  property hover_calls = 0
  property wait_enabled_calls = 0
  property hover_error : Exception? = nil
  property wait_enabled_error : Exception? = nil

  def hover : Nil
    @hover_calls += 1
    if ex = @hover_error
      raise ex
    end
  end

  def wait_enabled : Nil
    @wait_enabled_calls += 1
    if ex = @wait_enabled_error
      raise ex
    end
  end
end

private class HoverFlowStubElement < StubElement
  property wait_interactable_calls = 0
  property wait_interactable_error : Exception? = nil
  property hover_point = Rod::Point.new(11.0, 22.0)

  def wait_interactable : Rod::Point
    @wait_interactable_calls += 1
    if ex = @wait_interactable_error
      raise ex
    end
    @hover_point
  end
end

private class TypeFlowStubElement < StubElement
  property focus_calls = 0
  property focus_error : Exception? = nil

  def focus : Nil
    @focus_calls += 1
    if ex = @focus_error
      raise ex
    end
  end
end

private class FocusFlowElement < StubElement
  property scroll_calls = 0

  def scroll_into_view : Nil
    @scroll_calls += 1
  end
end

# Records the `EvalOptions` of a shared-helper call (`evaluate(opts)`), which is
# how go-rod runs every `evalHelper(js.X)` site, and answers `helper_result`.
private class HelperEvalStubElement < StubElement
  property helper_opts : Rod::EvalOptions? = nil
  property? helper_result : Bool = false

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @helper_opts = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":#{@helper_result}}))
  end
end

private class TapFlowStubElement < StubElement
  property scroll_calls = 0
  property wait_enabled_calls = 0
  property wait_interactable_calls = 0
  property scroll_error : Exception? = nil
  property wait_enabled_error : Exception? = nil
  property wait_interactable_error : Exception? = nil
  property tap_point = Rod::Point.new(7.0, 9.0)

  def scroll_into_view : Nil
    @scroll_calls += 1
    if ex = @scroll_error
      raise ex
    end
  end

  def wait_enabled : Nil
    @wait_enabled_calls += 1
    if ex = @wait_enabled_error
      raise ex
    end
  end

  def wait_interactable : Rod::Point
    @wait_interactable_calls += 1
    if ex = @wait_interactable_error
      raise ex
    end
    @tap_point
  end
end

private class SelectStubPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil
  property eval_result : Bool = true
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    if ex = @eval_error
      raise ex
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":#{@eval_result}}))
  end
end

private class SelectFlowElement < StubElement
  property focus_calls = 0
  property focus_error : Exception? = nil

  def focus : Nil
    @focus_calls += 1
    if ex = @focus_error
      raise ex
    end
  end
end

private class WaitInteractableStubElement < StubElement
  property failures_left = 0
  property interactable_calls = 0
  property interactable_error : Exception? = nil
  property resolved_point = Rod::Point.new(9.0, 11.0)
  property cover_element : Rod::Element?

  def interactable : Rod::Point
    @interactable_calls += 1
    if ex = @interactable_error
      raise ex
    end
    if @failures_left > 0
      @failures_left -= 1
      raise Rod::CoveredError.new(@cover_element || self)
    end
    @resolved_point
  end

  def scroll_into_view : Nil
  end
end

private class EvalRecordingPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private class WaitElementPage < Rod::Page
  property waited_opts : Rod::EvalOptions? = nil
  property wait_calls = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def sleeper(sleeper : Proc(Rod::Utils::Sleeper)) : Rod::Page
    self
  end

  def wait(opts : Rod::EvalOptions) : Nil
    @wait_calls += 1
    @waited_opts = opts
  end
end

private class ResourceStubPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil
  property eval_result_url = ""
  property eval_error : Exception? = nil
  property last_resource_url : String? = nil
  property resource_bytes = Bytes.empty

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    if ex = @eval_error
      raise ex
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"string","value":#{@eval_result_url.to_json}}))
  end

  def get_resource(url : String) : Bytes
    @last_resource_url = url
    @resource_bytes
  end
end

private class EvalCapturePage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    if ex = @eval_error
      raise ex
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private class ScreenshotStubPage < Rod::Page
  # `Element#screenshot` re-contexts the page like go (`el.page.Context(el.ctx)`),
  # which dups this stub, so the call log has to be a shared object.
  getter screenshot_contexts = [] of Rod::Context
  property screenshot_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def screenshot_calls : Int32
    @screenshot_contexts.size
  end

  def screenshot(full_page : Bool = false, req : Cdp::Page::CaptureScreenshot? = nil) : Bytes
    _ = full_page
    _ = req
    @screenshot_contexts << get_context
    if ex = @screenshot_error
      raise ex
    end
    "png".to_slice
  end
end

private class FnErrStubPage < Rod::Page
  property eval_error : Exception = Rod::EvalError.new(
    Cdp::Runtime::ExceptionDetails.from_json(%({
      "exceptionId": 1,
      "text": "Uncaught",
      "lineNumber": 0,
      "columnNumber": 0,
      "exception": {
        "type": "object",
        "subtype": "error",
        "description": "ReferenceError: foo is not defined"
      }
    }))
  )

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    _ = opts
    raise @eval_error
  end

  def element_by_js(opts : Rod::EvalOptions) : Rod::Element
    _ = opts
    raise @eval_error
  end
end

private class StableStubPage < Rod::Page
  property repaint_calls = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def wait_repaint : Nil
    @repaint_calls += 1
  end
end

private class StableStubElement < StubElement
  property wait_visible_calls = 0
  property shapes = [] of Cdp::DOM::GetContentQuadsResult
  property shape_error : Exception? = nil
  @last_shape = Cdp::DOM::GetContentQuadsResult.new([] of Cdp::DOM::Quad)

  def wait_visible : Nil
    @wait_visible_calls += 1
  end

  def shape : Cdp::DOM::GetContentQuadsResult
    if ex = @shape_error
      raise ex
    end

    if next_shape = @shapes.shift?
      @last_shape = next_shape
    end
    @last_shape
  end
end

private class MultipleTimesPage < Rod::Page
  property call_count = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def element_by_js(opts : Rod::EvalOptions) : Rod::Element
    _ = opts
    @call_count += 1
    object = Cdp::Runtime::RemoteObject.from_json(%({
      "type":"object",
      "subtype":"node",
      "objectId":"obj-#{@call_count}",
      "description":"button"
    }))
    Rod::Element.new(object, self)
  end
end

private class GetXPathPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    self
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    if ex = @eval_error
      raise ex
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"string","value":"/html/body/form/textarea"}))
  end
end

private def node_json(extra : String = "") : String
  %({"nodeId":1,"backendNodeId":2,"nodeType":1,"nodeName":"DIV","localName":"div","nodeValue":""#{extra}})
end

describe Rod::Element do
  # TODO: Add proper mocking for Page and CDP calls
  # For now, mark specs as deferred

  describe "#matches" do
    it "checks if element matches CSS selector" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      element.eval_result = true

      element.matches(".btn").should be_true
      element.last_js.should eq("(s) => this.matches(s)")
      element.last_args.should eq([".btn"] of Rod::EvalOptions::JsArg)
    end
  end

  describe "#click" do
    it "uses left button and single click by default" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = ClickSpyMouse.new(page)
      page.mouse = spy_mouse
      element = ClickFlowStubElement.new(page)

      element.click

      spy_mouse.click_calls.should eq([{"left", 1}] of Tuple(String, Int32))
    end

    it "hovers, waits enabled, then delegates to page mouse click" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = ClickSpyMouse.new(page)
      page.mouse = spy_mouse
      element = ClickFlowStubElement.new(page)

      element.click("right", 2)

      element.hover_calls.should eq(1)
      element.wait_enabled_calls.should eq(1)
      spy_mouse.click_calls.should eq([{"right", 2}] of Tuple(String, Int32))
    end

    it "propagates hover errors before waiting or clicking" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = ClickSpyMouse.new(page)
      page.mouse = spy_mouse
      element = ClickFlowStubElement.new(page)
      element.hover_error = Exception.new("hover failed")

      expect_raises(Exception, "hover failed") do
        element.click
      end

      element.hover_calls.should eq(1)
      element.wait_enabled_calls.should eq(0)
      spy_mouse.click_calls.should be_empty
    end

    it "propagates wait_enabled errors before clicking" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = ClickSpyMouse.new(page)
      page.mouse = spy_mouse
      element = ClickFlowStubElement.new(page)
      element.wait_enabled_error = Exception.new("wait failed")

      expect_raises(Exception, "wait failed") do
        element.click
      end

      element.hover_calls.should eq(1)
      element.wait_enabled_calls.should eq(1)
      spy_mouse.click_calls.should be_empty
    end
  end

  describe "#move_mouse_out" do
    it "moves mouse to right edge of element bounding box" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = MoveSpyMouse.new(page)
      page.mouse = spy_mouse
      element = InteractableStubElement.new(page)
      element.quad_payload = Cdp::DOM::GetContentQuadsResult.new([
        JSON.parse("[1,2,5,2,5,6,1,6]"),
      ] of Cdp::DOM::Quad)

      element.move_mouse_out

      spy_mouse.move_calls.size.should eq(1)
      spy_mouse.move_calls[0].should eq(Rod::Point.new(5.0, 2.0))
    end

    it "raises InvisibleShapeError when shape has no quads" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = MoveSpyMouse.new(page)
      page.mouse = spy_mouse
      element = InteractableStubElement.new(page)
      element.quad_payload = Cdp::DOM::GetContentQuadsResult.new([] of Cdp::DOM::Quad)

      expect_raises(Rod::InvisibleShapeError) { element.move_mouse_out }
      spy_mouse.move_calls.should be_empty
    end
  end

  describe "#type" do
    it "focuses first then delegates keys to keyboard.type" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_keyboard = TypeSpyKeyboard.new(page)
      page.keyboard = spy_keyboard
      element = TypeFlowStubElement.new(page)

      element.type(Rod::Input::ENTER)

      element.focus_calls.should eq(1)
      spy_keyboard.typed_calls.should eq([[Rod::Input::ENTER]] of Array(Rod::Input::Key))
    end

    it "propagates focus errors before typing" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_keyboard = TypeSpyKeyboard.new(page)
      page.keyboard = spy_keyboard
      element = TypeFlowStubElement.new(page)
      element.focus_error = Exception.new("focus failed")

      expect_raises(Exception, "focus failed") { element.type(Rod::Input::ENTER) }
      spy_keyboard.typed_calls.should be_empty
    end
  end

  describe "#hover" do
    it "waits for interactable point then moves mouse to that point" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = MoveSpyMouse.new(page)
      page.mouse = spy_mouse
      element = HoverFlowStubElement.new(page)
      element.hover_point = Rod::Point.new(3.0, 4.0)

      element.hover

      element.wait_interactable_calls.should eq(1)
      spy_mouse.move_calls.should eq([Rod::Point.new(3.0, 4.0)])
    end

    it "propagates wait_interactable errors before moving mouse" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_mouse = MoveSpyMouse.new(page)
      page.mouse = spy_mouse
      element = HoverFlowStubElement.new(page)
      element.wait_interactable_error = Exception.new("not interactable")

      expect_raises(Exception, "not interactable") { element.hover }
      spy_mouse.move_calls.should be_empty
    end
  end

  describe "#tap" do
    it "scrolls, waits enabled/interactable, then taps resolved point" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_touch = TapSpyTouch.new(page)
      page.touch = spy_touch
      element = TapFlowStubElement.new(page)
      element.tap_point = Rod::Point.new(10.0, 12.0)

      element.tap

      element.scroll_calls.should eq(1)
      element.wait_enabled_calls.should eq(1)
      element.wait_interactable_calls.should eq(1)
      spy_touch.tap_calls.should eq([Rod::Point.new(10.0, 12.0)])
    end

    it "propagates scroll errors before wait/tap" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      spy_touch = TapSpyTouch.new(page)
      page.touch = spy_touch
      element = TapFlowStubElement.new(page)
      element.scroll_error = Exception.new("scroll failed")

      expect_raises(Exception, "scroll failed") { element.tap }
      element.wait_enabled_calls.should eq(0)
      element.wait_interactable_calls.should eq(0)
      spy_touch.tap_calls.should be_empty
    end
  end

  describe "#select" do
    it "focuses then selects options via js helper with user gesture" do
      page = SelectStubPage.new
      element = SelectFlowElement.new(page)

      element.select(["B", "C"], true, Rod::SelectorType::Text)

      element.focus_calls.should eq(1)
      opts = page.last_eval_opts.not_nil!
      opts.user_gesture?.should be_true
      opts.js.should contain("return f.apply(this, args)")
      opts.js_args[0].as(Rod::JS::Function).name.should eq("select")
      opts.js_args[1].as(JSON::Any).as_a.map(&.as_s).should eq(["B", "C"])
      opts.js_args[2].should eq(true)
      opts.js_args[3].should eq(Rod::SelectorType::Text)
    end

    it "raises NotFoundError when helper returns false" do
      page = SelectStubPage.new
      page.eval_result = false
      element = SelectFlowElement.new(page)

      expect_raises(Rod::NotFoundError) do
        element.select(["not-exists"], true, Rod::SelectorType::CSSSelector)
      end
    end

    it "propagates evaluation errors" do
      page = SelectStubPage.new
      page.eval_error = Exception.new("select failed")
      element = SelectFlowElement.new(page)

      expect_raises(Exception, "select failed") do
        element.select(["B"], true, Rod::SelectorType::Text)
      end
    end
  end

  describe "#attribute/#property/#disabled?/#blur/#equal" do
    it "reads attributes and properties with go-style nil behavior" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      element.next_eval_values = [JSON.parse(%("v1")), JSON.parse("null"), JSON.parse("true")]

      element.attribute("data-x").should eq("v1")
      element.attribute("missing").should be_nil
      element.property("disabled").as_bool.should be_true
    end

    it "disabled? uses property(\"disabled\")" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      element.next_eval_values = [JSON.parse("true"), JSON.parse("false")]

      element.disabled?.should be_true
      element.disabled?.should be_false
    end

    it "equal evaluates expected javascript" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      target = StubElement.new(page)

      element.eval_result = true
      element.equal(target).should be_true
      element.last_js.should eq("(elm) => this === elm")
      element.last_args.should eq([target.object] of Rod::EvalOptions::JsArg)
    end
  end

  describe "#focus/#blur" do
    # go runs both as user gestures: `Eval(`() => this.focus()`).ByUser()`
    # (`element.go:56-64`) and `Eval("() => this.blur()").ByUser()`
    # (`element.go:332-335`).
    it "focuses after scrolling into view, as a user gesture" do
      page = EvalRecordingPage.new
      element = FocusFlowElement.new(page)

      element.focus

      element.scroll_calls.should eq(1)
      opts = page.last_eval_opts.not_nil!
      opts.js.should eq("() => this.focus()")
      opts.user_gesture?.should be_true
      opts.by_value?.should be_true
    end

    it "blurs as a user gesture" do
      page = EvalRecordingPage.new
      element = FocusFlowElement.new(page)

      element.blur

      opts = page.last_eval_opts.not_nil!
      opts.js.should eq("() => this.blur()")
      opts.user_gesture?.should be_true
    end
  end

  describe "context/page helpers" do
    it "returns owning page reference" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)

      element.page.should eq(page)
    end

    it "supports timeout/cancel_timeout and with_cancel context chaining" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)

      timed = element.timeout(1.second)
      timed.get_context.should_not eq(element.get_context)

      restored = timed.cancel_timeout
      restored.get_context.should eq(element.get_context)

      cancelled, cancel = element.with_cancel
      cancelled.get_context.cancelled?.should be_false
      cancel.call
      cancelled.get_context.cancelled?.should be_true

      expect_raises(Exception, /no timeout context to cancel/) { element.cancel_timeout }
    end
  end

  describe "#contains_element" do
    it "checks if target is equal or inside element with go's containsElement helper" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      root = HelperEvalStubElement.new(page)
      target = StubElement.new(page)
      root.helper_result = true

      root.contains_element(target).should be_true

      opts = root.helper_opts.not_nil!
      # go: `el.Evaluate(evalHelper(js.ContainsElement, target.Object))`
      # (`element.go:474-479`).
      opts.js_args.first.as(Rod::JS::Function).name.should eq("containsElement")
      opts.js_args[1].as(Cdp::Runtime::RemoteObject).object_id.should eq("obj-1")
      opts.user_gesture?.should be_false
    end
  end

  describe "#scroll_into_view" do
    # go waits for a stable repaint and then scrolls through the DOM domain
    # (`element.go:68-78` + `WaitStableRAF` at `element.go:556-583`). A plain
    # `this.scrollIntoView(...)` eval skips both, so assert the CDP traffic.
    it "waits for a stable RAF then scrolls with DOM.scrollIntoViewIfNeeded" do
      page = CdpStubPage.new
      page.set_response("Runtime.evaluate", %({"result":{"type":"object","objectId":"window-1"}}))
      page.set_response("Runtime.callFunctionOn", %({"result":{"type":"object","objectId":"fn-1","value":true}}))
      page.set_response("DOM.getContentQuads", %({"quads":[]}))
      page.set_response("DOM.scrollIntoViewIfNeeded", %({}))
      element = Rod::Element.new(
        Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","description":"div"})),
        page
      )

      element.scroll_into_view

      page.method_calls.should contain("DOM.getContentQuads")
      page.method_calls.should contain("DOM.scrollIntoViewIfNeeded")
      page.method_params["DOM.scrollIntoViewIfNeeded"]["objectId"].as_s.should eq("obj-1")
    end
  end

  describe "#describe" do
    it "returns DOM node description" do
      page = CdpStubPage.new
      page.set_response("DOM.describeNode", %({"node":#{node_json(%(,"frameId":"frame-1"))}}))
      element = StubElement.new(page)

      node = element.describe
      node.node_name.should eq("DIV")
      node.frame_id.should eq("frame-1")
    end
  end

  describe "#shadow_root" do
    it "returns shadow root element" do
      page = CdpStubPage.new
      page.set_response(
        "DOM.describeNode",
        %({"node":#{node_json(%(,"shadowRoots":[#{node_json(%(,"backendNodeId":9))}]))}})
      )
      page.set_response(
        "DOM.resolveNode",
        %({"object":{"type":"object","objectId":"shadow-1","description":"#shadow-root"}})
      )
      # go returns `el.page.Context(el.ctx).ElementFromObject(shadowNode.Object)`
      # (`element.go:456`), so the shadow root resolves its JS context the same
      # way every other object-based element does.
      page.set_response("Runtime.callFunctionOn", %({"result":{"type":"object","objectId":"window-obj"}}))
      page.set_response("Runtime.evaluate", %({"result":{"type":"object","objectId":"window-obj"}}))
      element = StubElement.new(page)

      ctx, cancel = element.ctx.with_cancel
      shadow = element.context(ctx).shadow_root

      shadow.object.object_id.should eq("shadow-1")
      # The receiver's context travels with the shadow root.
      shadow.ctx.should be(ctx)
      page.method_calls.should contain("Runtime.callFunctionOn")
      cancel.call
    end

    it "raises NoShadowRootError when no shadow root" do
      page = CdpStubPage.new
      page.set_response("DOM.describeNode", %({"node":#{node_json}}))
      element = StubElement.new(page)

      expect_raises(Rod::NoShadowRootError) { element.shadow_root }
    end
  end

  describe "#frame" do
    it "returns Page for iframe element" do
      page = CdpStubPage.new
      page.set_response("DOM.describeNode", %({"node":#{node_json(%(,"frameId":"frame-42"))}}))
      element = StubElement.new(page)

      frame = element.frame
      frame.frame_id.should eq(Rod::FrameID.new("frame-42"))
    end

    it "returns cloned page with empty frame id for non-iframe element" do
      page = CdpStubPage.new
      page.set_response("DOM.describeNode", %({"node":#{node_json}}))
      element = StubElement.new(page)

      element.frame.frame_id.should eq(Rod::FrameID.new(""))
    end
  end

  describe "#get_xpath" do
    it "returns xpath for optimized and non-optimized modes (go parity)" do
      page = GetXPathPage.new
      element = StubElement.new(page)

      element.get_xpath(true).should eq("/html/body/form/textarea")
      opts = page.last_eval_opts.not_nil!
      opts.js_args[1].should eq(true)
      # go runs the helper on the element (`el.Evaluate(...)`, `element.go:747-754`),
      # so the element's remote object must be `this`.
      opts.this_obj.should eq(element.object)

      element.get_xpath(false).should eq("/html/body/form/textarea")
      page.last_eval_opts.not_nil!.js_args[1].should eq(false)
    end

    it "surfaces Runtime.callFunctionOn failures" do
      page = GetXPathPage.new
      page.eval_error = Exception.new("Runtime.callFunctionOn failed")
      element = StubElement.new(page)

      expect_raises(Exception, /Runtime.callFunctionOn failed/) do
        element.get_xpath(true)
      end
    end
  end

  describe "#element" do
    it "finds single child element by CSS selector" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      child = StubElement.new(page)
      element.next_element = child

      element.element(".item").should eq(child)
      opts = element.last_eval_opts.not_nil!
      opts.js.should contain("querySelector")
      assert_js_helper(opts, "element", [JSON.parse(%(".item"))])
    end

    it "raises NotFoundError when element not found" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      expect_raises(Rod::NotFoundError) { element.element(".missing") }
    end
  end

  describe "#select_text/#select_all_text" do
    it "evaluates go's js.SelectText helper as a user gesture" do
      page = EvalRecordingPage.new
      # `select_text` focuses first (`element.go:225-236`), so keep the scroll
      # probe out of the CDP stub and leave the eval to the page recorder.
      element = FocusFlowElement.new(page)

      element.select_text("foo")

      opts = page.last_eval_opts.not_nil!
      opts.js.should contain("/* selectText:")
      opts.js_args.last.should eq("foo")
      opts.user_gesture?.should be_true
    end

    it "evaluates go's js.SelectAllText helper as a user gesture" do
      page = EvalRecordingPage.new
      element = FocusFlowElement.new(page)

      element.select_all_text

      opts = page.last_eval_opts.not_nil!
      # go: `el.Evaluate(evalHelper(js.SelectAllText).ByUser())` (`element.go:252`).
      opts.js.should contain("/* selectAllText:")
      opts.user_gesture?.should be_true
    end
  end

  describe "#elements" do
    it "finds all child elements matching CSS selector" do
      page = ElementsPage.new
      element = StubElement.new(page)
      page.next_elements = Rod::Elements.new([StubElement.new(page)] of Rod::Element)

      result = element.elements(".row")
      result.size.should eq(1)
      opts = page.last_eval_opts.not_nil!
      opts.js.should contain("querySelectorAll")
      assert_js_helper(opts, "elements", [JSON.parse(%(".row"))])
    end

    it "returns empty Elements when none found" do
      page = ElementsPage.new
      element = StubElement.new(page)

      element.elements(".missing").size.should eq(0)
    end
  end

  describe "#elements_x" do
    it "finds all child elements matching XPath selector" do
      page = ElementsPage.new
      element = StubElement.new(page)
      page.next_elements = Rod::Elements.new([StubElement.new(page), StubElement.new(page)] of Rod::Element)

      result = element.elements_x("./button")
      result.size.should eq(2)
      opts = page.last_eval_opts.not_nil!
      opts.js.should contain("document.evaluate")
      assert_js_helper(opts, "elementsX", [JSON.parse(%("./button"))])
    end
  end

  describe "#parent/#parents/#next/#previous" do
    it "returns parent element or nil when not found" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      parent = StubElement.new(page)
      element.next_element = parent

      element.parent.should eq(parent)
      element.last_eval_opts.not_nil!.js.should contain("parentElement")

      element.next_element = nil
      element.parent.should be_nil
    end

    it "runs go's js.Parents helper with the required selector" do
      page = ElementsPage.new
      page.next_elements = Rod::Elements.new([StubElement.new(page)] of Rod::Element)
      element = StubElement.new(page)

      element.parents(".row").size.should eq(1)
      opts = page.last_eval_opts.not_nil!
      # go: `el.ElementsByJS(evalHelper(js.Parents, selector))` (`query.go:516-518`).
      opts.js.should contain("this.parentElement")
      assert_js_helper(opts, "parents", [JSON.parse(%(".row"))])
    end

    it "returns next/previous sibling or nil when not found" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      sibling = StubElement.new(page)
      element.next_element = sibling

      element.next.should eq(sibling)
      element.last_eval_opts.not_nil!.js.should contain("nextElementSibling")

      element.previous.should eq(sibling)
      element.last_eval_opts.not_nil!.js.should contain("previousElementSibling")

      element.next_element = nil
      element.next.should be_nil
      element.previous.should be_nil
    end
  end

  describe "#element_x" do
    it "finds single child element by XPath selector" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      child = StubElement.new(page)
      element.next_element = child

      element.element_x("//div").should eq(child)
      opts = element.last_eval_opts.not_nil!
      opts.js.should contain("document.evaluate")
      assert_js_helper(opts, "elementX", [JSON.parse(%("//div"))])
    end

    it "raises NotFoundError when element not found" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      expect_raises(Rod::NotFoundError) { element.element_x("//missing") }
    end
  end

  describe "#element_r" do
    it "finds single child element by CSS selector with regex text" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      child = StubElement.new(page)
      element.next_element = child

      element.element_r("div", "foo").should eq(child)
      opts = element.last_eval_opts.not_nil!
      opts.js.should contain("new RegExp")
      assert_js_helper(opts, "elementR", [JSON.parse(%("div")), JSON.parse(%("foo"))])
    end

    it "raises NotFoundError when element not found" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = StubElement.new(page)
      expect_raises(Rod::NotFoundError) { element.element_r("div", "missing") }
    end
  end

  describe "#interactable/#wait_interactable" do
    it "returns a clickable point for visible shape" do
      page = InteractableStubPage.new
      element = InteractableStubElement.new(page)
      page.next_element_from_point = element

      point = element.interactable
      point.x.should eq(5.0)
      point.y.should eq(5.0)
    end

    it "raises NoPointerEventsError when pointer-events is none" do
      page = InteractableStubPage.new
      element = InteractableStubElement.new(page)
      element.pointer_blocked = true

      expect_raises(Rod::NoPointerEventsError) { element.interactable }
    end

    it "raises InvisibleShapeError when no interior point exists" do
      page = InteractableStubPage.new
      element = InteractableStubElement.new(page)
      element.quad_payload = Cdp::DOM::GetContentQuadsResult.new([] of Cdp::DOM::Quad)

      expect_raises(Rod::InvisibleShapeError) { element.interactable }
    end

    it "supports wrapped elements represented by multiple quads" do
      page = InteractableStubPage.new
      element = InteractableStubElement.new(page)
      page.next_element_from_point = element
      element.quad_payload = Cdp::DOM::GetContentQuadsResult.new([
        JSON.parse("[0,0,12,0,12,8,0,8]"),
        JSON.parse("[0,10,8,10,8,16,0,16]"),
      ] of Cdp::DOM::Quad)

      element.shape.quads.size.should eq(2)
      point = element.interactable
      point.x.should eq(6.0)
      point.y.should eq(4.0)
    end

    it "wait_interactable retries CoveredError until success" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = WaitInteractableStubElement.new(page)
      element.failures_left = 1
      element.cover_element = StubElement.new(page)

      point = element.wait_interactable
      point.should eq(Rod::Point.new(9.0, 11.0))
      element.interactable_calls.should eq(2)
    end

    it "wait_interactable stops on a non-covered error like go's Retry" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = WaitInteractableStubElement.new(page)
      element.interactable_error = Rod::InvisibleShapeError.new(element)

      expect_raises(Rod::InvisibleShapeError) { element.wait_interactable }
      # go returns `true, err` for anything but a CoveredError, so no retry.
      element.interactable_calls.should eq(1)
    end
  end

  describe "#wait_visible/#wait_invisible" do
    it "wait_visible waits through the page with go's js.Visible helper" do
      page = WaitElementPage.new
      element = StubElement.new(page)

      element.wait_visible

      page.wait_calls.should eq(1)
      waited = page.waited_opts.not_nil!
      waited.this_obj.should eq(element.object)
      waited.js.should contain("/* visible:")
    end

    it "wait_invisible waits through the page with go's js.Invisible helper" do
      page = WaitElementPage.new
      element = StubElement.new(page)

      element.wait_invisible

      page.wait_calls.should eq(1)
      waited = page.waited_opts.not_nil!
      waited.this_obj.should eq(element.object)
      waited.js.should contain("/* invisible:")
    end
  end

  describe "#resource/#background_image" do
    it "resolves element resource URL and delegates to page get_resource" do
      page = ResourceStubPage.new
      page.eval_result_url = "https://example.test/a.png"
      page.resource_bytes = "img".to_slice
      element = StubElement.new(page)

      element.resource.should eq("img".to_slice)
      page.last_resource_url.should eq("https://example.test/a.png")
      page.last_eval_opts.not_nil!.js.should contain("return f.apply(this, args)")
    end

    it "resolves computed background image URL and delegates to page get_resource" do
      page = ResourceStubPage.new
      page.eval_result_url = "https://example.test/bg.png"
      page.resource_bytes = "bg".to_slice
      element = StubElement.new(page)

      element.background_image.should eq("bg".to_slice)
      page.last_resource_url.should eq("https://example.test/bg.png")
      page.last_eval_opts.not_nil!.js.should contain("window.getComputedStyle(this).backgroundImage")
    end

    it "propagates evaluate errors for resource/background image retrieval" do
      page = ResourceStubPage.new
      page.eval_error = Exception.new("eval failed")
      element = StubElement.new(page)

      expect_raises(Exception, "eval failed") { element.resource }
      expect_raises(Exception, "eval failed") { element.background_image }
    end
  end

  describe "#canvas_to_image" do
    it "decodes base64 payload from canvas data URI" do
      page = ResourceStubPage.new
      page.eval_result_url = "data:image/png;base64,SGVsbG8="
      element = StubElement.new(page)

      element.canvas_to_image.should eq("Hello".to_slice)
    end

    it "returns empty bytes when data URI payload is invalid" do
      page = ResourceStubPage.new
      page.eval_result_url = "data:image/png;base64,***not-valid***"
      element = StubElement.new(page)

      element.canvas_to_image.should eq(Bytes.new(0))
    end
  end

  describe "#wait_load" do
    it "evaluates js.waitLoad helper by promise with element as this object" do
      page = EvalCapturePage.new
      element = StubElement.new(page)

      element.wait_load

      opts = page.last_eval_opts.not_nil!
      opts.await_promise?.should be_true
      opts.this_obj.should eq(element.object)
      opts.js.should contain("return f.apply(this, args)")
      opts.js_args.size.should eq(1)
      opts.js_args[0].as(Rod::JS::Function).name.should eq("waitLoad")
    end
  end

  describe "#screenshot" do
    it "raises when no bounding box can be computed from element shape" do
      page = ScreenshotStubPage.new
      element = InteractableStubElement.new(page)
      element.quad_payload = Cdp::DOM::GetContentQuadsResult.new([] of Cdp::DOM::Quad)

      expect_raises(Exception, "Failed to compute bounding box for element") do
        element.screenshot
      end
      page.screenshot_calls.should eq(1)
    end

    it "propagates scroll-into-view failures (go TestElementScreenshot parity)" do
      page = ScreenshotStubPage.new
      element = InteractableStubElement.new(page)
      element.eval_error = Exception.new("scroll failed")

      expect_raises(Exception, "scroll failed") { element.screenshot }
      page.screenshot_calls.should eq(0)
    end

    it "propagates page capture screenshot failures (go TestElementScreenshot parity)" do
      page = ScreenshotStubPage.new
      page.screenshot_error = Exception.new("capture failed")
      element = InteractableStubElement.new(page)

      expect_raises(Exception, "capture failed") { element.screenshot }
      page.screenshot_calls.should eq(1)
    end

    it "propagates shape retrieval failures after capture (go TestElementScreenshot parity)" do
      page = ScreenshotStubPage.new
      element = InteractableStubElement.new(page)
      element.shape_error = Exception.new("shape failed")

      expect_raises(Exception, "shape failed") { element.screenshot }
      page.screenshot_calls.should eq(1)
    end
  end

  describe "#eval/#element_by_js error propagation" do
    it "surfaces EvalError when eval javascript fails" do
      page = FnErrStubPage.new
      object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","description":"div"}))
      element = Rod::Element.new(object, page)

      err = expect_raises(Rod::EvalError) { element.eval("foo()") }
      err.to_s.should contain("ReferenceError: foo is not defined")
    end

    it "surfaces EvalError when element_by_js evaluation fails" do
      page = FnErrStubPage.new
      object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-2","description":"div"}))
      element = Rod::Element.new(object, page)

      err = expect_raises(Rod::EvalError) do
        element.element_by_js(Rod::EvalOptions.new(js: "() => foo()"))
      end
      err.to_s.should contain("ReferenceError: foo is not defined")
    end
  end

  describe "multiple queries" do
    it "can return distinct element remote object ids for repeated selector lookups" do
      page = MultipleTimesPage.new
      opts = Rod::EvalOptions.new(js: "() => this")

      first = page.element_by_js(opts)
      second = page.element_by_js(opts)

      first.object.object_id.should_not eq(second.object.object_id)
      first.object.description.should eq(second.object.description)
    end
  end

  describe "context cancellation errors" do
    it "propagates canceled context errors across element operations (go TestElementErrors parity)" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-cancel","description":"form"}))
      element = Rod::Element.new(object, page)
      ctx, cancel = Rod::Context.background.with_cancel
      cancel.call
      cancelled = element.context(ctx)

      expect_raises(Exception) { cancelled.describe(-1, true) }
      expect_raises(Exception) { cancelled.frame }
      expect_raises(Exception) { cancelled.focus }
      expect_raises(Exception) { cancelled.key_actions }
      expect_raises(Exception) { cancelled.input("a") }
      expect_raises(Exception) { cancelled.select(["a"], true, Rod::SelectorType::Text) }
      expect_raises(Exception) { cancelled.wait_stable(Time::Span::ZERO) }
      expect_raises(Exception) { cancelled.eval("() => 1") }
      expect_raises(Exception) { cancelled.resource }
      expect_raises(Exception) { cancelled.background_image }
      expect_raises(Exception) { cancelled.html }
      expect_raises(Exception) { cancelled.visible? }
      expect_raises(Exception) { cancelled.canvas_to_image("", 0.0) }
      expect_raises(Exception) { cancelled.release }
    end
  end

  describe "#wait_stable/#wait_stable_raf" do
    it "wait_stable waits until successive shapes are equal" do
      page = StableStubPage.new
      element = StableStubElement.new(page)
      element.shapes = [
        Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,10,0,10,10,0,10]")] of Cdp::DOM::Quad),
        Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,20,0,20,20,0,20]")] of Cdp::DOM::Quad),
        Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,20,0,20,20,0,20]")] of Cdp::DOM::Quad),
      ]

      element.wait_stable(Time::Span::ZERO)

      element.wait_visible_calls.should eq(1)
    end

    it "wait_stable_raf waits repaint cycles until successive shapes are equal" do
      page = StableStubPage.new
      element = StableStubElement.new(page)
      element.shapes = [
        Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,10,0,10,10,0,10]")] of Cdp::DOM::Quad),
        Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,20,0,20,20,0,20]")] of Cdp::DOM::Quad),
        Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,20,0,20,20,0,20]")] of Cdp::DOM::Quad),
      ]

      element.wait_stable_raf

      element.wait_visible_calls.should eq(1)
      page.repaint_calls.should eq(3)
    end

    it "wait_stable_raf propagates shape retrieval errors" do
      page = StableStubPage.new
      element = StableStubElement.new(page)
      element.shape_error = Exception.new("shape failed")

      expect_raises(Exception, "shape failed") { element.wait_stable_raf }
    end
  end

  describe "#wait_enabled/#wait_writable" do
    it "wait_enabled waits through the page with go's disabled check" do
      page = WaitElementPage.new
      element = StubElement.new(page)

      element.wait_enabled

      page.wait_calls.should eq(1)
      waited = page.waited_opts.not_nil!
      waited.this_obj.should eq(element.object)
      waited.js.should eq("() => !this.disabled")
      waited.await_promise?.should be_true
    end

    it "wait_writable waits through the page with go's readonly check" do
      page = WaitElementPage.new
      element = StubElement.new(page)

      element.wait_writable

      page.wait_calls.should eq(1)
      waited = page.waited_opts.not_nil!
      waited.this_obj.should eq(element.object)
      waited.js.should eq("() => !this.readonly")
      waited.await_promise?.should be_true
    end
  end

  describe "#set_files" do
    it "sends absolute file paths via DOM.setFileInputFiles" do
      page = CdpStubPage.new
      page.set_response("DOM.setFileInputFiles", %({}))
      element = StubElement.new(page)

      element.set_files(["spec/spec_helper.cr"])

      page.method_calls.should contain("DOM.setFileInputFiles")
      files = page.method_params["DOM.setFileInputFiles"].as_h["files"].as_a
      files.size.should eq(1)
      files[0].as_s.should eq(File.expand_path("spec/spec_helper.cr"))
    end
  end

  describe "#wait" do
    it "binds the element object as this before delegating to page wait" do
      page = WaitElementPage.new
      element = StubElement.new(page)
      opts = Rod::EvalOptions.new(js: "() => true")

      element.wait(opts)

      waited = page.waited_opts.not_nil!
      waited.this_obj.should eq(element.object)
    end
  end

  describe "#input" do
    it "focuses, waits enabled/writable, inserts text and dispatches input events" do
      page = InputPage.new
      element = InputStubElement.new(page)

      element.input("abc")

      element.focus_called.should be_true
      element.wait_enabled_calls.should eq(1)
      element.wait_writable_calls.should eq(1)
      page.inserted_texts.should eq(["abc"])
      dispatch = element.dispatch_opts.not_nil!
      dispatch.user_gesture?.should be_true
      dispatch.js_args.first.as(Rod::JS::Function).name.should eq("inputEvent")
    end

    it "still dispatches events when insert_text fails and re-raises insert error" do
      page = InputPage.new
      page.insert_error = Exception.new("insert failed")
      element = InputStubElement.new(page)

      expect_raises(Exception, "insert failed") { element.input("abc") }
      element.dispatch_opts.should_not be_nil
    end
  end

  describe "#input_time" do
    it "waits writable and inputs go's js.InputTime helper as a user gesture" do
      page = InputPage.new
      element = InputStubElement.new(page)
      t = Time.utc(2024, 1, 2, 3, 4, 5)

      element.input_time(t)

      element.wait_enabled_calls.should eq(1)
      element.wait_writable_calls.should eq(1)
      dispatch = element.dispatch_opts.not_nil!
      # go: `el.Evaluate(evalHelper(js.InputTime, t.UnixNano()/1e6).ByUser())`
      # (`element.go:303`).
      dispatch.js_args.first.as(Rod::JS::Function).name.should eq("inputTime")
      dispatch.js_args[1].should eq(t.to_unix_ms)
      dispatch.user_gesture?.should be_true
    end
  end

  describe "#input_color" do
    it "waits writable and inputs go's js.InputColor helper" do
      page = InputPage.new
      element = InputStubElement.new(page)

      element.input_color("#abcdef")

      element.wait_enabled_calls.should eq(1)
      element.wait_writable_calls.should eq(1)
      dispatch = element.dispatch_opts.not_nil!
      # go: `el.Evaluate(evalHelper(js.InputColor, color))` (`element.go:325`).
      dispatch.js_args.first.as(Rod::JS::Function).name.should eq("inputColor")
      dispatch.js_args[1].should eq("#abcdef")
      dispatch.user_gesture?.should be_false
    end
  end

  describe "#must_interactable" do
    # go-rod's `MustInteractable` classifies with
    # `errors.Is(err, &NotInteractableError{})`, which matches the three
    # subtypes through `Unwrap`.
    it "returns false for every not-interactable error like go-rod" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      reference = StubElement.new(page)

      [
        Rod::NotInteractableError.new,
        Rod::CoveredError.new(reference),
        Rod::InvisibleShapeError.new(reference),
        Rod::NoPointerEventsError.new(reference),
      ].each do |err|
        element = InteractableResultElement.new(page, err)
        element.must_interactable.should be_false
      end
    end

    it "returns true when the element is interactable" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = InteractableResultElement.new(page, nil)

      element.must_interactable.should be_true
    end

    it "raises other errors" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = InteractableResultElement.new(page, Rod::NavigationError.new("boom"))

      expect_raises(Rod::NavigationError) { element.must_interactable }
    end
  end

  describe "#must_select" do
    it "passes selectors with Go default selected/text selector type" do
      page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
      element = MustSelectElement.new(page)

      element.must_select("one", "two").should eq(element)
      selectors, selected, selector_type = element.selected_args.not_nil!
      selectors.should eq(["one", "two"])
      selected.should be_true
      selector_type.should eq(Rod::SelectorType::Text)
    end
  end
end

describe Rod::Elements do
  it "returns nil first/last for empty list" do
    list = Rod::Elements.new
    list.first.should be_nil
    list.last.should be_nil
  end

  it "returns first/last for non-empty list" do
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
    a = StubElement.new(page)
    b = StubElement.new(page)
    list = Rod::Elements.new([a, b] of Rod::Element)

    list.first.should eq(a)
    list.last.should eq(b)
  end
end
