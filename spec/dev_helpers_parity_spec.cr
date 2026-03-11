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
      .client(Rod::Lib::Cdp::Client.new)
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
end
