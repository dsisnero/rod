require "spec"
require "../src/rod"

private class MonitorStubBrowser < Rod::Browser
  getter calls = [] of Tuple(String, String?)

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @calls << {method, session_id}

    case method
    when "Target.getTargets"
      %({
        "targetInfos": [
          {
            "targetId": "target-1",
            "type": "page",
            "title": "stub",
            "url": "about:blank",
            "attached": false,
            "canAccessOpener": false
          }
        ]
      }).to_slice
    when "Target.attachToTarget"
      %({"sessionId":"session-1"}).to_slice
    when "Page.enable"
      %({}).to_slice
    when "Page.captureScreenshot"
      %({"data":"cG5n"}).to_slice
    else
      raise "unexpected method: #{method}"
    end
  end
end

private class TraceOverlayStubElement < Rod::Element
  property overlay_calls = 0
  property overlay_messages = [] of String

  def initialize(page : Rod::Page)
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"obj-1","description":"div"}))
    super(obj, page)
  end

  def overlay(msg : String) : Proc(Nil)
    @overlay_calls += 1
    @overlay_messages << msg
    -> { }
  end
end

private class ExposeHelpersStubPage < Rod::Page
  getter captured_eval : Rod::EvalOptions?

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @captured_eval = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private class TraceOverlayStubPage < Rod::Page
  property overlay_calls = 0
  property overlay_messages = [] of String

  def overlay(left : Float64, top : Float64, width : Float64, height : Float64, msg : String) : Proc(Nil)
    @overlay_calls += 1
    @overlay_messages << msg
    -> { }
  end
end

private class WaitTraceStubBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    %({}).to_slice
  end

  def context(ctx : Rod::Context) : Rod::Browser
    _ = ctx
    self
  end

  def each_event(session_id : Rod::SessionID?, callbacks : Hash(String, Rod::Browser::CallbackInfo)) : Proc(Nil)
    _ = session_id
    _ = callbacks
    -> { }
  end
end

# The wait spans are logged by the page helpers themselves, so the delegated work
# is stubbed out. `wait_dom_stable` and `wait_request_idle` stay real here (one
# example per helper, since a stub of either would shadow the traced method).
private class WaitTraceBasePage < TraceOverlayStubPage
  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target-id"))
  end

  def capture_dom_snapshot : Cdp::DOMSnapshot::CaptureSnapshotResult
    Cdp::DOMSnapshot::CaptureSnapshotResult.new(
      [] of Cdp::DOMSnapshot::DocumentSnapshot,
      ["stable"] of String
    )
  end

  # `Element#wait` polls through `Page#wait`; answer `true` without touching CDP.
  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    _ = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":true}))
  end
end

private class WaitTraceStablePage < WaitTraceBasePage
  def wait_load : Nil
  end

  def wait_request_idle(
    d : Time::Span,
    includes : Array(String)? = nil,
    excludes : Array(String)? = nil,
    exclude_types : Array(Cdp::Network::ResourceType)? = nil,
  ) : Proc(Nil)
    _ = d
    _ = includes
    _ = excludes
    _ = exclude_types
    -> { }
  end

  def wait_dom_stable(d : Time::Span, diff : Float64) : Nil
    _ = d
    _ = diff
  end
end

private class OverlayRecordPage < Rod::Page
  getter evals = [] of Rod::EvalOptions

  def initialize(browser : Rod::Browser = Rod::Browser.new)
    super(browser, Rod::TargetID.new("overlay-target"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @evals << opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private def helper_name(opts : Rod::EvalOptions) : String?
  opts.js_args.first.as?(Rod::JS::Function).try(&.name)
end

# `eval_helper` keeps String/Float args as Crystal values and JSON-encodes the
# rest, so a helper argument can be either shape.
private def arg_string(arg : Rod::EvalOptions::JsArg?) : String?
  case arg
  when String    then arg
  when JSON::Any then arg.as_s?
  end
end

private def eval_id(opts : Rod::EvalOptions) : String?
  arg_string(opts.js_args[1]?)
end

private def wait_for_overlay_removal(page : OverlayRecordPage) : Nil
  deadline = Time.instant + 2.seconds
  while Time.instant < deadline
    return if page.evals.any? { |opts| helper_name(opts) == "removeOverlay" }

    sleep 5.milliseconds
  end
end

describe "Dev helpers parity" do
  it "formats trace type labels as [type]" do
    Rod.trace_type_label(Rod::TraceTypeInput).should eq("[input]")
  end

  it "serve_monitor exposes pages endpoint and returns -32602 for unknown page id" do
    browser = MonitorStubBrowser.new
    browser.no_default_device
    scoped, cancel = browser.with_cancel

    begin
      host = scoped.serve_monitor("")

      pages = HTTP::Client.get("#{host}/api/pages")
      pages.status_code.should eq(200)
      JSON.parse(pages.body)[0]["targetId"].as_s.should eq("target-1")

      missing = HTTP::Client.get("#{host}/api/page/not-found")
      missing.status_code.should eq(400)
      body = JSON.parse(missing.body)
      body["code"].as_i.should eq(-32602)
      body["message"].as_s.should eq("target not found")
    ensure
      cancel.call
    end
  end

  it "serve_monitor screenshot endpoints render image bytes for target id and default page target" do
    browser = MonitorStubBrowser.new
    browser.no_default_device
    scoped, cancel = browser.with_cancel

    begin
      host = scoped.serve_monitor("")

      by_id = HTTP::Client.get("#{host}/screenshot/target-1")
      by_id.status_code.should eq(200)
      by_id.headers["Content-Type"].should contain("image/png")
      by_id.body.should eq("png")

      default_target = HTTP::Client.get("#{host}/screenshot")
      default_target.status_code.should eq(200)
      default_target.body.should eq("png")

      browser.calls.map(&.[0]).should contain("Target.attachToTarget")
      browser.calls.map(&.[0]).should contain("Page.captureScreenshot")
    ensure
      cancel.call
    end
  end

  it "serve_monitor rejects invalid host format" do
    browser = MonitorStubBrowser.new
    expect_raises(ArgumentError, "invalid host format: abc") do
      browser.serve_monitor("abc")
    end
  end

  it "monitor invalid host bubbles through must_connect" do
    browser = Rod::Browser.new
      .client(Rod::Util::Cdp::Client.new)
      .control_url("")
      .monitor("abc")

    expect_raises(ArgumentError, "invalid host format: abc") do
      browser.must_connect
    end
  end

  it "element try_trace overlays only when browser trace is enabled" do
    browser = Rod::Browser.new
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"))
    element = TraceOverlayStubElement.new(page)

    element.try_trace(Rod::TraceTypeQuery, %(rod.element("code"))).call
    element.overlay_calls.should eq(0)

    browser.trace(true)
    element.try_trace(Rod::TraceTypeQuery, %(rod.element("code"))).call
    element.overlay_calls.should eq(1)
    element.overlay_messages.last.should contain("[query]")
    element.overlay_messages.last.should contain(%(rod.element("code")))
  end

  it "expose_helpers wires helper dependencies into window.rod" do
    browser = Rod::Browser.new
    page = ExposeHelpersStubPage.new(browser, Rod::TargetID.new("target-id"))

    page.expose_helpers(Rod::JS::ELEMENT_R)

    captured = page.captured_eval
    captured.should_not be_nil
    opts = captured.not_nil!
    opts.js.should contain("return f.apply(this, args)")
    opts.by_value?.should be_true
    opts.js_args.size.should eq(1)

    fn = opts.js_args[0].as(Rod::JS::Function)
    fn.definition.should eq("() => { window.rod = functions }")
    fn.dependencies.size.should eq(1)
    fn.dependencies[0].name.should eq("elementR")
  end

  it "page try_trace is no-op when trace is disabled" do
    browser = Rod::Browser.new
    page = TraceOverlayStubPage.new(browser, Rod::TargetID.new("target-id"))

    page.try_trace(Rod::TraceTypeWait, "load").call

    page.overlay_calls.should eq(0)
  end

  it "page try_trace overlays rendered trace text when trace is enabled" do
    browser = Rod::Browser.new
    browser.trace(true)
    page = TraceOverlayStubPage.new(browser, Rod::TargetID.new("target-id"))

    page.try_trace(Rod::TraceTypeInput, "left click").call

    page.overlay_calls.should eq(1)
    page.overlay_messages.last.should contain("[input]")
    page.overlay_messages.last.should contain("left click")
  end

  # go draws with `js.Overlay` on `p.root` and returns a remove func that runs
  # `js.RemoveOverlay` with the same id (`dev_helpers.go:114-131`); the port used
  # to leave the overlay in the DOM forever.
  it "page overlay draws on the root page and remove deletes it" do
    page = OverlayRecordPage.new

    remove = page.overlay(1.0, 2.0, 3.0, 4.0, "msg")

    page.evals.size.should eq(1)
    draw = page.evals[0]
    helper_name(draw).should eq("overlay")
    draw.await_promise?.should be_true
    id = eval_id(draw).not_nil!

    remove.call

    page.evals.size.should eq(2)
    removal = page.evals[1]
    helper_name(removal).should eq("removeOverlay")
    eval_id(removal).should eq(id)
  end

  it "element overlay draws on the element and remove deletes it" do
    page = OverlayRecordPage.new
    element = Rod::Element.new(
      Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"el-1","description":"div"})),
      page
    )

    remove = element.overlay("msg")

    page.evals.size.should eq(1)
    draw = page.evals[0]
    helper_name(draw).should eq("elementOverlay")
    draw.this_obj.not_nil!.object_id.should eq("el-1")
    id = eval_id(draw).not_nil!

    remove.call

    page.evals.size.should eq(2)
    removal = page.evals[1]
    helper_name(removal).should eq("removeOverlay")
    eval_id(removal).should eq(id)
    removal.this_obj.not_nil!.object_id.should eq("el-1")
  end

  # go logs the request trace and draws its overlay, then removes it when the
  # page context ends (`dev_helpers.go:157-195`).
  it "wait-requests trace draws an overlay and removes it on page cancel" do
    browser = Rod::Browser.new
    browser.trace(true)
    page = OverlayRecordPage.new(browser)
    ctx, cancel = page.get_context.with_cancel
    page = page.context(ctx)

    update = page.try_trace_req(["*.js"], [] of String)
    update.call({"a" => "b"})

    drawn = page.evals.select { |opts| helper_name(opts) == "overlay" }
    drawn.size.should eq(1)
    arg_string(drawn.first.js_args[6]?).to_s.should contain("*.js")

    cancel.call
    wait_for_overlay_removal(page)

    page.evals.any? { |opts| helper_name(opts) == "removeOverlay" }.should be_true
  end
end

private class WaitTraceStubElement < Rod::Element
  def initialize(page : Rod::Page)
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-wait","description":"div"}))
    super(object, page)
  end

  def scroll_into_view : Nil
  end
end

describe "page wait trace spans parity" do
  # `try_trace` prefers the trace logger, so a recording `Utils::Log` captures the
  # span lines without touching a page.
  it "logs go's wait spans for the waits that trace on creation" do
    lines = [] of String
    browser = WaitTraceStubBrowser.new
    browser.logger(Rod::Util::Utils::Log.new { |vs| lines << vs.join(" ") })
    browser.trace(true)

    page = WaitTraceBasePage.new(browser)
    page.wait_event(Cdp::Page::LoadEventFiredEvent.new(1.5))
    page.wait_dom_stable(0.milliseconds, 0.0)

    # Each helper runs on the page stub that leaves it real, so the traced method
    # is never shadowed (the returned waits are not called, so nothing blocks).
    plain = TraceOverlayStubPage.new(browser, Rod::TargetID.new("target-id"))
    plain.wait_request_idle(10.milliseconds)
    stable = WaitTraceStablePage.new(browser)
    stable.wait_stable(0.milliseconds)

    # go defers `p.tryTrace(TraceTypeWait, ...)()` at the top of each helper
    # (`page.go:688-691`, `718`, `784`, `822`), so the span is logged when the
    # helper runs.
    lines.any? { |l| l.includes?("[wait]") && l.includes?(" event ") && l.includes?("Page.loadEventFired") }.should be_true
    lines.any? { |l| l.includes?("[wait]") && l.includes?("request-idle") }.should be_true
    lines.any? { |l| l.includes?("[wait]") && l.includes?("dom-stable") }.should be_true
    lines.any? { |l| l.includes?("[wait]") && l.includes?(" stable ") }.should be_true
  end

  it "logs go's wait spans when the returned wait runs" do
    lines = [] of String
    browser = WaitTraceStubBrowser.new
    browser.logger(Rod::Util::Utils::Log.new { |vs| lines << vs.join(" ") })
    browser.trace(true)
    page = WaitTraceBasePage.new(browser)

    # go defers the span inside the returned closures (`page.go:661-665`,
    # `702-705`), so it is logged when the wait is called. This stub never
    # captures a target, so `wait_open`'s wait raises after logging.
    expect_raises(Exception, "target ID not captured") { page.wait_open.call }
    lines.last.should contain("[wait]")
    lines.last.should contain("wait open")

    page.wait_navigation("networkAlmostIdle").call
    lines.last.should contain("[wait]")
    lines.last.should contain("navigation networkAlmostIdle")
  end

  it "traces only go's Wait* wrappers, not Element#wait" do
    lines = [] of String
    browser = WaitTraceStubBrowser.new
    browser.logger(Rod::Util::Utils::Log.new { |vs| lines << vs.join(" ") })
    browser.trace(true)
    page = WaitTraceBasePage.new(browser)
    element = WaitTraceStubElement.new(page)

    # go's `Element.Wait` has no span (`element.go:608-610`): only the Wait*
    # wrappers add one, so a bare wait stays out of the trace log.
    element.wait(Rod::EvalOptions.new(js: "() => true"))
    lines.should be_empty

    element.wait_visible
    lines.size.should eq(1)
    lines.last.should contain("[wait]")
    lines.last.should contain("visible")
  end
end
