require "./spec_helper"

# go-rod keeps the JavaScript execution-context id behind a pointer so page
# clones share it (`page.go:70`: "use pointer so that page clones can share the
# change"), and `Page.Navigate` clears it on `p.root`, not on the page that was
# navigated (`page.go:188`). Both details are observable: after a navigation the
# root context must be re-resolved even when the navigation happened through an
# iframe page or a cloned page.
private class JsCtxStubBrowser < Rod::Browser
  getter calls = [] of String

  # Counts `Runtime.evaluate` calls, the command that resolves `window` for a
  # page's context cache.
  getter evaluate_calls = 0

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def record_evaluate : Int32
    @evaluate_calls += 1
  end
end

private class JsCtxStubPage < Rod::Page
  getter stub_browser : JsCtxStubBrowser

  def initialize(@stub_browser : JsCtxStubBrowser, frame_id : String = "frame-1", element : Rod::Element? = nil)
    super(
      @stub_browser,
      Rod::TargetID.new("target-1"),
      Rod::SessionID.new("sid-1"),
      Rod::FrameID.new(frame_id),
      Rod::Context.background,
      -> { Rod::Utils::Sleeper.new },
      element
    )
  end

  # Answers the CDP commands used here without a browser.
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @stub_browser.calls << method
    payload = case method
              when "Runtime.evaluate"
                %({"result":{"type":"object","objectId":"win-#{@stub_browser.record_evaluate}"}})
              when "Runtime.callFunctionOn"
                %({"result":{"type":"number","value":1}})
              when "Page.navigate"
                %({"frameId":"frame-1"})
              else
                "{}"
              end
    payload.to_slice
  end
end

private def js_ctx_iframe_element(page : Rod::Page) : Rod::Element
  obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"iframe-doc"}))
  Rod::Element.new(obj, page)
end

describe "page js context cache parity" do
  it "clears the root page's cached context when an iframe page navigates" do
    browser = JsCtxStubBrowser.new
    root = JsCtxStubPage.new(browser)
    frame = JsCtxStubPage.new(browser, frame_id: "frame-2", element: js_ctx_iframe_element(root))

    frame.iframe?.should be_true

    # Resolve the root context once, then prove it is reused from cache.
    root.eval("() => 1")
    browser.evaluate_calls.should eq(1)
    root.eval("() => 1")
    browser.evaluate_calls.should eq(1)

    frame.navigate("about:blank")

    # go-rod unsets `p.root`'s context, so the next root eval re-resolves it.
    root.eval("() => 1")
    browser.evaluate_calls.should eq(2)
  end

  it "shares the cached context with page clones" do
    browser = JsCtxStubBrowser.new
    root = JsCtxStubPage.new(browser)
    clone = root.timeout(5.seconds)

    clone.eval("() => 1")
    browser.evaluate_calls.should eq(1)

    root.navigate("about:blank")

    # The clone shares the pointer, so the root's navigation invalidates it too.
    clone.eval("() => 1")
    browser.evaluate_calls.should eq(2)
  end
end
