require "./spec_helper"
require "digest/md5"

private class SettingsStubBrowser < Rod::Browser
  property method_calls : Array(String) = [] of String
  property method_params : Hash(String, JSON::Any) = {} of String => JSON::Any
  property responses : Hash(String, String) = {} of String => String
  property failures : Hash(String, Array(Exception)) = {} of String => Array(Exception)
  property product = "HeadlessChrome/123"

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    @method_params[method] = params
    if failures = @failures[method]?
      if ex = failures.shift?
        raise ex
      end
    end
    sid = session_id ? Rod::SessionID.new(session_id) : nil
    set_state(sid, method, params)
    (@responses[method]? || %({})).to_slice
  end

  def version : Cdp::Browser::GetVersionResult
    Cdp::Browser::GetVersionResult.new("1.3", @product, "r", "ua", "js")
  end
end

private class CloseStubBrowser < Rod::Browser
  property event_channel : Channel(Rod::Message)
  property close_failures : Array(Exception?) = [] of Exception?
  property page_close_calls = 0
  property method_calls : Array(String) = [] of String

  def initialize
    super
    @event_channel = Channel(Rod::Message).new(8)
  end

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def event : Channel(Rod::Message)
    @event_channel
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    if method == "Page.close"
      @page_close_calls += 1
      unless @close_failures.empty?
        if ex = @close_failures.shift
          raise ex
        end
      end
    end
    %({}).to_slice
  end
end

private class SettingsStubPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil

  def initialize(browser : Rod::Browser, frame_id : Rod::FrameID? = Rod::FrameID.new("frame-1"))
    super(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("session-1"), frame_id)
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":true}))
  end
end

private class TriggerFaviconErrorPage < Rod::Page
  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("session-1"), Rod::FrameID.new("frame-1"))
  end
end

private class TimeoutSnapshotBrowser < SettingsStubBrowser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    if method == "DOMSnapshot.captureSnapshot"
      if ctx = context.as?(Rod::Context)
        until ctx.cancelled?
          sleep 1.millisecond
        end
        raise(ctx.err || Rod::ContextCanceledError.new("context cancelled"))
      end
    end

    super
  end
end

private class WindowTrackingBrowser < SettingsStubBrowser
  getter set_window_bounds_calls = [] of JSON::Any

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    if method == "Browser.setWindowBounds"
      @set_window_bounds_calls << params
    end
    super
  end
end

private def js_arg_string(arg : Rod::EvalOptions::JsArg) : String
  case arg
  when String
    arg
  when JSON::Any
    arg.as_s
  else
    raise "expected string js arg, got #{arg.class}"
  end
end

private def js_arg_function(arg : Rod::EvalOptions::JsArg) : Rod::JS::Function
  case arg
  when Rod::JS::Function
    arg
  else
    raise "expected function js arg, got #{arg.class}"
  end
end

describe Rod::Page do
  describe "settings/navigation parity" do
    it "set_blocked_urls is no-op for empty and calls Network.setBlockedURLs for values" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.set_blocked_urls([] of String)
      browser.method_calls.should be_empty

      page.set_blocked_urls(["*://x.test/*"])
      browser.method_calls.should contain("Network.setBlockedURLs")
    end

    it "returns the owning browser reference" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.browser.should eq(browser)
    end

    it "supports timeout/cancel_timeout and with_cancel context chaining" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      timed = page.timeout(1.second)
      timed.get_context.should_not eq(page.get_context)

      restored = timed.cancel_timeout
      restored.get_context.should eq(page.get_context)

      cancelled, cancel = page.with_cancel
      cancelled.get_context.cancelled?.should be_false
      cancel.call
      cancelled.get_context.cancelled?.should be_true

      expect_raises(Exception, /no timeout context to cancel/) { page.cancel_timeout }
    end

    it "set_extra_headers enables network, sets headers, and cleanup disables network" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      cleanup = page.set_extra_headers(["X-A", "1", "X-B", "2"])
      browser.method_calls.should contain("Network.enable")
      browser.method_calls.should contain("Network.setExtraHTTPHeaders")

      cleanup.call
      browser.method_calls.should contain("Network.disable")
    end

    it "reads target info url and uses it as default cookies url" do
      browser = SettingsStubBrowser.new
      browser.responses["Target.getTargetInfo"] = %({
        "targetInfo": {
          "targetId": "target-id",
          "type": "page",
          "title": "t",
          "url": "https://example.test/path",
          "attached": true,
          "openerId": null,
          "canAccessOpener": false,
          "openerFrameId": null,
          "parentFrameId": null,
          "browserContextId": null,
          "subtype": null
        }
      })
      browser.responses["Network.getCookies"] = %({"cookies":[]})
      page = SettingsStubPage.new(browser)

      page.info.url.should eq("https://example.test/path")
      page.cookies.should eq([] of Cdp::Network::Cookie)
      browser.method_calls.should contain("Target.getTargetInfo")
      browser.method_calls.should contain("Network.getCookies")
      browser.method_params["Network.getCookies"].as_h["urls"].as_a[0].as_s.should eq("https://example.test/path")
    end

    it "navigate + wait_load + info returns current page url" do
      browser = SettingsStubBrowser.new
      browser.responses["Page.navigate"] = %({"frameId":"frame-1"})
      browser.responses["Target.getTargetInfo"] = %({
        "targetInfo": {
          "targetId": "target-id",
          "type": "page",
          "title": "t",
          "url": "https://example.test/fixtures/click-iframe.html",
          "attached": true,
          "openerId": null,
          "canAccessOpener": false,
          "openerFrameId": null,
          "parentFrameId": null,
          "browserContextId": null,
          "subtype": null
        }
      })
      page = SettingsStubPage.new(browser)

      page.navigate("https://example.test/fixtures/click-iframe.html")
      page.wait_load

      page.info.url.should match(/\/fixtures\/click-iframe\.html$/)
      browser.method_calls.should contain("Page.navigate")
      browser.method_calls.should contain("Target.getTargetInfo")
    end

    it "set_cookies calls set/clear cookie CDP methods" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)
      cookie = Cdp::Network::CookieParam.from_json(%({
        "name":"a",
        "value":"1",
        "url":"https://example.test"
      }))

      page.set_cookies([cookie])
      browser.method_calls.should contain("Network.setCookies")

      page.set_cookies(nil)
      browser.method_calls.should contain("Network.clearBrowserCookies")
    end

    it "set_user_agent default emits Emulation.setUserAgentOverride" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.set_user_agent(nil)
      browser.method_calls.should contain("Emulation.setUserAgentOverride")
    end

    it "stop_loading emits Page.stopLoading" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.stop_loading

      browser.method_calls.should contain("Page.stopLoading")
    end

    it "load_state/enable_domain/disable_domain follows browser domain state" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)
      req = Cdp::Page::Enable.new(nil)

      page.load_state(req).should be_false
      restore_enable = page.enable_domain(req)
      page.load_state(req).should be_true

      restore_disable = page.disable_domain(req)
      page.load_state(req).should be_false

      restore_disable.call
      page.load_state(req).should be_true
      restore_enable.call
      page.load_state(req).should be_false
    end

    it "navigate_back and navigate_forward evaluate history scripts with user gesture" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.navigate_back
      page.last_eval_opts.not_nil!.js.should eq("() => history.back()")
      page.last_eval_opts.not_nil!.user_gesture?.should be_true

      page.navigate_forward
      page.last_eval_opts.not_nil!.js.should eq("() => history.forward()")
      page.last_eval_opts.not_nil!.user_gesture?.should be_true
    end

    it "activate calls Target.activateTarget" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.activate

      browser.method_calls.should contain("Target.activateTarget")
    end

    it "get_window and set_window use Browser window APIs" do
      browser = SettingsStubBrowser.new
      browser.responses["Browser.getWindowForTarget"] = %({"windowId":7,"bounds":{"left":1,"top":2,"width":3,"height":4,"windowState":"normal"}})
      browser.responses["Browser.getWindowBounds"] = %({"bounds":{"left":10,"top":11,"width":12,"height":13,"windowState":"normal"}})
      page = SettingsStubPage.new(browser)

      bounds = page.get_window
      bounds.left.should eq(10)
      bounds.width.should eq(12)

      new_bounds = Cdp::Browser::Bounds.new(left: 20, top: 21, width: 22, height: 23, window_state: Cdp::Browser::WindowStateNormal)
      page.set_window(new_bounds)

      browser.method_calls.should contain("Browser.getWindowForTarget")
      browser.method_calls.should contain("Browser.getWindowBounds")
      browser.method_calls.should contain("Browser.setWindowBounds")
    end

    it "must_window_* helpers map to expected Browser window states" do
      browser = WindowTrackingBrowser.new
      browser.responses["Browser.getWindowForTarget"] = %({"windowId":7,"bounds":{"left":1,"top":2,"width":3,"height":4,"windowState":"normal"}})
      page = SettingsStubPage.new(browser)

      page.must_window_maximize
      page.must_window_normal
      page.must_window_fullscreen
      page.must_window_normal
      page.must_window_minimize
      page.must_window_normal
      page.must_set_window(0, 0, 1211, 611)

      states = browser.set_window_bounds_calls.map(&.as_h.["bounds"].as_h.["windowState"].as_s)
      states.should eq(["maximized", "normal", "fullscreen", "normal", "minimized", "normal", "normal"])

      final_bounds = browser.set_window_bounds_calls.last.as_h["bounds"].as_h
      final_bounds["width"].as_i.should eq(1211)
      final_bounds["height"].as_i.should eq(611)
    end

    it "window helpers propagate get/set window errors" do
      browser = SettingsStubBrowser.new
      browser.failures["Browser.getWindowForTarget"] = [Exception.new("window target failed")]
      page = SettingsStubPage.new(browser)

      expect_raises(Exception, /window target failed/) { page.get_window }

      browser2 = SettingsStubBrowser.new
      browser2.responses["Browser.getWindowForTarget"] = %({"windowId":7,"bounds":{"left":1,"top":2,"width":3,"height":4,"windowState":"normal"}})
      browser2.failures["Browser.getWindowBounds"] = [Exception.new("window bounds failed")]
      page2 = SettingsStubPage.new(browser2)

      expect_raises(Exception, /window bounds failed/) { page2.get_window }

      browser3 = SettingsStubBrowser.new
      browser3.failures["Browser.getWindowForTarget"] = [Exception.new("window set target failed")]
      page3 = SettingsStubPage.new(browser3)
      bounds = Cdp::Browser::Bounds.new(left: 1, top: 2, width: 3, height: 4, window_state: Cdp::Browser::WindowStateNormal)

      expect_raises(Exception, /window set target failed/) { page3.set_window(bounds) }
    end

    it "set_viewport clears or sets metrics and emulate applies device settings" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.set_viewport(nil)
      browser.method_calls.should contain("Emulation.clearDeviceMetricsOverride")

      page.set_viewport(Rod::Util::Devices::IPhone6or7or8.metrics_emulation)
      browser.method_calls.should contain("Emulation.setDeviceMetricsOverride")

      page.emulate(Rod::Util::Devices::IPhone6or7or8)
      browser.method_calls.should contain("Emulation.setDeviceMetricsOverride")
      browser.method_calls.should contain("Emulation.setTouchEmulationEnabled")
      browser.method_calls.should contain("Emulation.setUserAgentOverride")

      metrics = browser.method_params["Emulation.setDeviceMetricsOverride"].as_h
      metrics["width"].as_i.should eq(375)
      metrics["height"].as_i.should eq(667)
      metrics["mobile"].as_bool.should be_true

      ua = browser.method_params["Emulation.setUserAgentOverride"].as_h["userAgent"].as_s
      ua.should contain("iPhone")
      ua.should contain("Mobile")
    end

    it "emulate propagates metrics and touch setup errors" do
      browser = SettingsStubBrowser.new
      browser.failures["Emulation.setDeviceMetricsOverride"] = [Exception.new("metrics failed")]
      page = SettingsStubPage.new(browser)

      expect_raises(Exception, /metrics failed/) { page.emulate(Rod::Util::Devices::IPhone6or7or8) }

      browser2 = SettingsStubBrowser.new
      browser2.failures["Emulation.setTouchEmulationEnabled"] = [Exception.new("touch failed")]
      page2 = SettingsStubPage.new(browser2)

      expect_raises(Exception, /touch failed/) { page2.emulate(Rod::Util::Devices::IPhone6or7or8) }
    end

    it "trigger_favicon enforces headless and evaluates helper" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.trigger_favicon
      page.last_eval_opts.should_not be_nil

      browser.product = "Chrome/123"
      expect_raises(Exception, "browser is no-headless") { page.trigger_favicon }
    end

    it "trigger_favicon propagates runtime call errors (Go TestPageTriggerFavicon parity)" do
      browser = SettingsStubBrowser.new
      browser.responses["Runtime.evaluate"] = %({"result":{"type":"object","objectId":"ctx-1"}})
      browser.failures["Runtime.callFunctionOn"] = [Exception.new("runtime call failed")]
      page = TriggerFaviconErrorPage.new(browser)

      expect_raises(Exception, "runtime call failed") do
        page.trigger_favicon
      end
    end

    it "supports go-style session/string/event aliases" do
      browser = CloseStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.get_session_id.should eq(Rod::SessionID.new("session-1"))
      page.is_iframe.should be_false
      page.string.should contain("target-id")

      ch = page.event
      browser.event_channel.send(Rod::Message.new(Rod::SessionID.new("other"), "x", JSON.parse(%({}))))
      browser.event_channel.send(Rod::Message.new(Rod::SessionID.new("session-1"), "y", JSON.parse(%({}))))
      ch.receive.method.should eq("y")
    end

    it "event channel closes on target detach/destroy and context cancel" do
      browser = CloseStubBrowser.new
      page = SettingsStubPage.new(browser)

      detached = page.event
      browser.event_channel.send(
        Rod::Message.new(
          Rod::SessionID.new("session-1"),
          Cdp::Target::DetachedFromTargetEvent.proto_event,
          JSON.parse(%({"sessionId":"session-1","targetId":"target-id"}))
        )
      )
      if msg = detached.receive?
        msg.method.should eq(Cdp::Target::DetachedFromTargetEvent.proto_event)
        detached.receive?.should be_nil
      end

      destroyed = page.event
      browser.event_channel.send(
        Rod::Message.new(
          nil,
          Cdp::Target::TargetDestroyedEvent.proto_event,
          JSON.parse(%({"targetId":"target-id"}))
        )
      )
      if msg = destroyed.receive?
        msg.method.should eq(Cdp::Target::TargetDestroyedEvent.proto_event)
        destroyed.receive?.should be_nil
      end

      canceled_page, cancel = page.with_cancel
      canceled = canceled_page.event
      cancel.call
      canceled.receive?.should be_nil
    end

    it "supports navigation/snapshot/wait alias wrappers" do
      browser = SettingsStubBrowser.new
      browser.responses["Page.getNavigationHistory"] = %({
        "currentIndex": 0,
        "entries": []
      })
      browser.responses["DOMSnapshot.captureSnapshot"] = %({
        "documents": [],
        "strings": []
      })
      page = SettingsStubPage.new(browser)

      hist = page.get_navigation_history
      hist.current_index.should eq(0)

      snap = page.capture_domsnapshot
      snap.strings.should eq([] of String)

      page.wait_domstable(0.milliseconds, 0.0)

      browser.method_calls.should contain("Page.getNavigationHistory")
      browser.method_calls.should contain("DOMSnapshot.captureSnapshot")
    end

    it "capture_domsnapshot propagates capture errors" do
      browser = SettingsStubBrowser.new
      browser.failures["DOMSnapshot.captureSnapshot"] = [Exception.new("capture domsnapshot failed")]
      page = SettingsStubPage.new(browser)

      expect_raises(Exception, /capture domsnapshot failed/) { page.capture_domsnapshot }
    end

    it "capture_domsnapshot respects timeout context" do
      browser = TimeoutSnapshotBrowser.new
      browser.responses["DOMSnapshot.captureSnapshot"] = %({"documents":[],"strings":[]})
      page = SettingsStubPage.new(browser)
      timed = page.timeout(10.milliseconds)

      expect_raises(Rod::ContextTimeoutError) { timed.capture_domsnapshot }
    end

    it "navigate uses about:blank for empty url and reset_navigation_history calls CDP" do
      browser = SettingsStubBrowser.new
      browser.responses["Page.navigate"] = %({"frameId":"frame-1"})
      page = SettingsStubPage.new(browser)

      page.navigate("")
      page.reset_navigation_history

      browser.method_calls.should contain("Page.navigate")
      browser.method_calls.should contain("Page.resetNavigationHistory")
      browser.method_params["Page.navigate"].as_h["url"].as_s.should eq("about:blank")
    end

    it "add_script_tag/add_style_tag and wait_idle evaluate helper promises" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.add_script_tag("https://cdn.test/a.js")
      page.last_eval_opts.not_nil!.await_promise?.should be_true
      page.last_eval_opts.not_nil!.js_args.size.should eq(4)

      page.add_style_tag("https://cdn.test/a.css")
      page.last_eval_opts.not_nil!.await_promise?.should be_true
      page.last_eval_opts.not_nil!.js_args.size.should eq(4)

      page.wait_idle(250.milliseconds)
      page.last_eval_opts.not_nil!.await_promise?.should be_true
      page.last_eval_opts.not_nil!.js_args.size.should eq(2)
    end

    it "add_script_tag/add_style_tag use stable ids for dedupe semantics" do
      browser = SettingsStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.add_script_tag("https://cdn.test/a.js")
      first_script_args = page.last_eval_opts.not_nil!.js_args
      first_script_id = js_arg_string(first_script_args[1])
      first_script_id.should eq(Digest::MD5.hexdigest("https://cdn.test/a.js"))
      js_arg_function(first_script_args[0]).definition.should contain("document.getElementById")

      page.add_script_tag("https://cdn.test/a.js")
      second_script_id = js_arg_string(page.last_eval_opts.not_nil!.js_args[1])
      second_script_id.should eq(first_script_id)

      page.add_script_tag("", "let ok = 'yes'")
      inline_script_id = js_arg_string(page.last_eval_opts.not_nil!.js_args[1])
      inline_script_id.should eq(Digest::MD5.hexdigest("let ok = 'yes'"))

      page.add_style_tag("https://cdn.test/a.css")
      style_args = page.last_eval_opts.not_nil!.js_args
      first_style_id = js_arg_string(style_args[1])
      first_style_id.should eq(Digest::MD5.hexdigest("https://cdn.test/a.css"))
      js_arg_function(style_args[0]).definition.should contain("document.getElementById")

      page.add_style_tag("https://cdn.test/a.css")
      second_style_id = js_arg_string(page.last_eval_opts.not_nil!.js_args[1])
      second_style_id.should eq(first_style_id)

      page.add_style_tag("", "h4 { color: green; }")
      inline_style_id = js_arg_string(page.last_eval_opts.not_nil!.js_args[1])
      inline_style_id.should eq(Digest::MD5.hexdigest("h4 { color: green; }"))
    end

    it "set_document_content and close call page CDP methods" do
      browser = CloseStubBrowser.new
      page = SettingsStubPage.new(browser)

      page.set_document_content("<html></html>")
      browser.event_channel.send(
        Rod::Message.new(
          nil,
          Cdp::Target::TargetDestroyedEvent.proto_event,
          JSON.parse(%({"targetId":"target-id"}))
        )
      )
      page.close

      browser.method_calls.should contain("Page.setDocumentContent")
      browser.method_calls.should contain("Page.close")
    end

    it "close cancels page context so follow-up actions can fail fast (Go TestPageActionAfterClose parity)" do
      browser = CloseStubBrowser.new
      page = SettingsStubPage.new(browser)

      browser.event_channel.send(
        Rod::Message.new(
          nil,
          Cdp::Target::TargetDestroyedEvent.proto_event,
          JSON.parse(%({"targetId":"target-id"}))
        )
      )
      page.close

      page.get_context.cancelled?.should be_true
    end

    it "element_from_point resolves backend node to element object" do
      browser = SettingsStubBrowser.new
      browser.responses["DOM.getNodeForLocation"] = %({"backendNodeId":123,"frameId":"frame-1","nodeId":0})
      browser.responses["DOM.resolveNode"] = %({"object":{"type":"object","objectId":"obj-pt","description":"div"}})
      browser.responses["DOM.describeNode"] = %({"node":{"nodeId":1,"backendNodeId":123,"nodeType":1,"nodeName":"DIV","localName":"div","nodeValue":""}})
      browser.responses["Runtime.callFunctionOn"] = %({"result":{"type":"object","objectId":"ctx-1"}})
      browser.responses["Runtime.evaluate"] = %({"result":{"type":"object","objectId":"ctx-1"}})
      page = SettingsStubPage.new(browser)

      el = page.element_from_point(10, 20)
      el.object.object_id.should eq("obj-pt")
      browser.method_calls.should contain("DOM.getNodeForLocation")
      browser.method_calls.should contain("DOM.resolveNode")
    end

    it "element_from_point propagates get_node_for_location errors" do
      browser = SettingsStubBrowser.new
      browser.failures["DOM.getNodeForLocation"] = [Exception.new("point lookup failed")]
      page = SettingsStubPage.new(browser)

      expect_raises(Exception, /point lookup failed/) { page.element_from_point(10, 20) }
    end

    it "element_from_object propagates js context resolution errors" do
      browser = SettingsStubBrowser.new
      browser.responses["Runtime.callFunctionOn"] = %({"result":{"type":"object","objectId":"ctx-obj"}})
      browser.failures["Runtime.evaluate"] = [Exception.new("runtime evaluate failed")]
      page = SettingsStubPage.new(browser)
      obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"node-obj"}))

      expect_raises(Exception, /runtime evaluate failed/) { page.element_from_object(obj) }
    end

    it "close retries not-attached-active-page and finishes on target destroyed" do
      browser = CloseStubBrowser.new
      failures = [] of Exception?
      failures << Exception.new("Not attached to an active page")
      failures << nil
      browser.close_failures = failures
      page = SettingsStubPage.new(browser)

      browser.event_channel.send(
        Rod::Message.new(
          nil,
          Cdp::Target::TargetDestroyedEvent.proto_event,
          JSON.parse(%({"targetId":"target-id"}))
        )
      )

      page.close
      browser.page_close_calls.should eq(2)
    end

    it "close raises PageCloseCanceledError when javascript dialog close result is false" do
      browser = CloseStubBrowser.new
      page = SettingsStubPage.new(browser)

      browser.event_channel.send(
        Rod::Message.new(
          Rod::SessionID.new("session-1"),
          Cdp::Page::JavascriptDialogClosedEvent.proto_event,
          JSON.parse(%({"frameId":"frame-1","result":false,"userInput":""}))
        )
      )

      expect_raises(Rod::PageCloseCanceledError) { page.close }
    end

    it "close propagates page close errors other than not-attached" do
      browser = CloseStubBrowser.new
      browser.close_failures = [] of Exception?
      browser.close_failures << Exception.new("page close failed")
      page = SettingsStubPage.new(browser)

      expect_raises(Exception, /page close failed/) { page.close }
    end
  end
end
