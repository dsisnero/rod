require "./spec_helper"

private class PageHTMLStubPage < Rod::Page
  property html_value : String = "<html></html>"
  property html_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def element(selector : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    _ = selector
    _ = opts
    raise html_error.not_nil! if html_error

    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-html","description":"html"}))
    HtmlElement.new(obj, self, @html_value)
  end
end

private class HtmlElement < Rod::Element
  def initialize(object : Cdp::Runtime::RemoteObject, page : Rod::Page, @value : String)
    super(object, page)
  end

  def html : String
    @value
  end
end

private class WaitLoadErrorPage < Rod::Page
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    _ = opts
    if ex = @eval_error
      raise ex
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private class EvalRecordPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("record-target"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private class SessionErrorBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    raise Exception.new(Cdp::ErrSessionNotFound.message)
  end
end

describe "page misc parity" do
  it "html returns html element outer html and surfaces element errors" do
    page = PageHTMLStubPage.new
    page.html.should eq("<html></html>")

    page.html_error = Exception.new("html failed")
    expect_raises(Exception, /html failed/) { page.html }
  end

  it "wait_load propagates evaluate errors" do
    page = WaitLoadErrorPage.new
    page.eval_error = Exception.new("runtime call failed")

    expect_raises(Exception, /runtime call failed/) { page.wait_load }
  end

  # go evaluates the repaint promise on the root page because an iframe does not
  # trigger `requestAnimationFrame` (`page.go:849-853`); the frame's own context
  # answers after a long throttle delay, which used to hang `WaitStableRAF`.
  it "wait_repaint evaluates on the root page, not the iframe" do
    root = EvalRecordPage.new
    frame_el = Rod::Element.new(
      Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"frame-1","description":"iframe"})),
      root
    )
    frame = Rod::Page.new(root.browser, Rod::TargetID.new("frame-target"))
    frame.element = frame_el
    # `Element#frame` copies the page's root onto the frame clone.
    frame.root = root

    frame.wait_repaint

    opts = root.last_eval_opts.not_nil!
    opts.js.should contain("requestAnimationFrame")
    opts.await_promise?.should be_true
  end

  it "keeps the root page across context and JS-context clones" do
    root = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("root-target"))
    root.root = root

    root.context(root.get_context).root_page.should be(root)
    root.dup.root_page.should be(root)
  end

  it "page_from_session returns page that propagates session-not-found errors" do
    browser = SessionErrorBrowser.new
    page = browser.page_from_session(Rod::SessionID.new("not-exist"))

    expect_raises(Exception, /Session with given id not found/) do
      Cdp::Page::Close.new.call(page)
    end
  end
end
