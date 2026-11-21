require "spec"
require "../src/rod"

# go-rod re-contexts the page for element operations: `el.page.Context(el.ctx)`
# for `Mouse.MoveTo`/`Mouse.Click`, `Touch.Tap`, `Keyboard.Type`, `KeyActions`,
# `InsertText`, `Screenshot` and `Evaluate` (`element.go:88-734`). An element
# cloned by `Element#timeout`/`Element#context` must bound those calls with its
# own context, otherwise the clone's deadline is ignored.
private class CtxSpyMouse < Rod::Mouse
  def initialize(page : Rod::Page, @sink : Array(Rod::Context))
    super(page)
  end

  def move_to(p : Rod::Point) : Nil
    @sink << @page.get_context
  end

  def click(button : String, click_count : Int32 = 1) : Nil
    @sink << @page.get_context
  end
end

private class CtxSpyKeyboard < Rod::Keyboard
  def initialize(page : Rod::Page, @sink : Array(Rod::Context))
    super(page)
  end

  def type(*keys : Rod::Input::Key) : Nil
    @sink << @page.get_context
  end

  def key_actions : Rod::Keyboard::KeyActions
    @sink << @page.get_context
    super
  end
end

private class CtxSpyTouch < Rod::Touch
  def initialize(page : Rod::Page, @sink : Array(Rod::Context))
    super(page)
  end

  def tap(x : Float64, y : Float64) : Nil
    @sink << @page.get_context
  end
end

private class CtxRecorderPage < Rod::Page
  getter contexts = [] of Rod::Context

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def mouse : Rod::Mouse
    CtxSpyMouse.new(self, @contexts)
  end

  def keyboard : Rod::Keyboard
    CtxSpyKeyboard.new(self, @contexts)
  end

  def touch : Rod::Touch
    CtxSpyTouch.new(self, @contexts)
  end

  def evaluate(opts : Rod::EvalOptions) : ::Cdp::Runtime::RemoteObject
    @contexts << get_context
    ::Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":true}))
  end

  def screenshot(full_page : Bool = false, req : ::Cdp::Page::CaptureScreenshot? = nil) : Bytes
    ctx = get_context
    @contexts << ctx
    if ctx.cancelled?
      raise(ctx.err || Rod::ContextCanceledError.new("context cancelled"))
    end
    Bytes.new(0)
  end

  def insert_text(text : String) : Nil
    @contexts << get_context
  end
end

private class CtxStubElement < Rod::Element
  def initialize(page : Rod::Page, ctx : Rod::Context)
    object = ::Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","description":"button"}))
    super(object, page, ctx)
  end

  def scroll_into_view : Nil
  end

  def wait_enabled : Nil
  end

  def wait_writable : Nil
  end

  def wait_interactable : Rod::Point
    Rod::Point.new(1.0, 2.0)
  end

  def shape : ::Cdp::DOM::GetContentQuadsResult
    ::Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[0,0,4,0,4,4,0,4]")] of ::Cdp::DOM::Quad)
  end
end

describe "element context propagation parity" do
  it "evaluates with the element's context like go's Element#Evaluate" do
    page = CtxRecorderPage.new
    ctx = Rod::Context.new
    element = CtxStubElement.new(page, ctx)

    element.evaluate("() => 1")

    page.contexts.last.should eq(ctx)
  end

  it "clicks and hovers with the element's context like go's Element#Click" do
    page = CtxRecorderPage.new
    ctx = Rod::Context.new
    element = CtxStubElement.new(page, ctx)

    element.click

    page.contexts.should_not be_empty
    page.contexts.each { |seen| seen.should eq(ctx) }
  end

  it "types and opens key actions with the element's context like go's Element#Type" do
    page = CtxRecorderPage.new
    ctx = Rod::Context.new
    element = CtxStubElement.new(page, ctx)

    element.type(Rod::Input::KEY_A)
    element.key_actions

    # `focus` evaluates through the same page, so every recorded call must
    # carry the element's context.
    page.contexts.size.should be >= 2
    page.contexts.each { |seen| seen.should eq(ctx) }
  end

  it "taps with the element's context like go's Element#Tap" do
    page = CtxRecorderPage.new
    ctx = Rod::Context.new
    element = CtxStubElement.new(page, ctx)

    element.tap

    page.contexts.last.should eq(ctx)
  end

  it "inserts text with the element's context like go's Element#Input" do
    page = CtxRecorderPage.new
    ctx = Rod::Context.new
    element = CtxStubElement.new(page, ctx)

    element.input("hi")

    page.contexts.size.should be >= 1
    page.contexts.each { |seen| seen.should eq(ctx) }
  end

  it "captures the screenshot with the element's context like go's Element#Screenshot" do
    page = CtxRecorderPage.new
    ctx = Rod::Context.new
    ctx.cancel
    element = CtxStubElement.new(page, ctx)

    expect_raises(Rod::ContextCanceledError) { element.screenshot }
  end
end
