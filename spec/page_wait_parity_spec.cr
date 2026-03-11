require "./spec_helper"

private class WaitStubPage < Rod::Page
  property eval_calls : Int32 = 0
  property last_opts : Rod::EvalOptions? = nil
  property results : Array(Bool) = [] of Bool
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @eval_calls += 1
    @last_opts = opts

    if ex = @eval_error
      raise ex
    end

    value = @results.empty? ? false : @results.shift
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":#{value}}))
  end
end

private class ReloadStubPage < Rod::Page
  property last_eval_opts : Rod::EvalOptions? = nil

  def initialize(browser : Rod::Browser = Rod::Browser.new)
    super(browser, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @last_eval_opts = opts
    Cdp::Runtime::RemoteObject.from_json(%({"type":"boolean","value":true}))
  end
end

private class NavigationStubBrowser < Rod::Browser
  property last_session_id : Rod::SessionID? = nil
  property last_callbacks : Hash(String, Rod::Browser::CallbackInfo)? = nil
  property wait_called = false
  property last_page_target_id : Rod::TargetID? = nil
  property page_from_target_result : Rod::Page? = nil

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def each_event(session_id : Rod::SessionID?, callbacks : Hash(String, Rod::Browser::CallbackInfo)) : Proc(Nil)
    @last_session_id = session_id
    @last_callbacks = callbacks
    -> { @wait_called = true }
  end

  def page_from_target(target_id : Rod::TargetID) : Rod::Page
    @last_page_target_id = target_id
    @page_from_target_result || super
  end
end

private class DialogStubBrowser < Rod::Browser
  property dialog_event : Cdp::Page::JavascriptDialogOpeningEvent? = nil
  property file_event : Cdp::Page::FileChooserOpenedEvent? = nil
  property waited_proto_events : Array(String) = [] of String

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def wait_event_typed(event_class : T.class, session_id : Rod::SessionID? = nil) : Proc(T) forall T
    @waited_proto_events << event_class.proto_event
    -> do
      {% if T == Cdp::Page::JavascriptDialogOpeningEvent %}
        @dialog_event.not_nil!
      {% elsif T == Cdp::Page::FileChooserOpenedEvent %}
        @file_event.not_nil!
      {% else %}
        raise "unexpected event class #{event_class}"
      {% end %}
    end
  end
end

private class NavigationStubPage < Rod::Page
  property method_calls : Array(String) = [] of String

  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("session-1"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    %({}).to_slice
  end
end

private class DialogStubPage < Rod::Page
  property method_calls : Array(String) = [] of String
  property failures : Hash(String, Array(Exception)) = {} of String => Array(Exception)

  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("session-1"))
  end

  def fail_once(method : String, ex : Exception) : Nil
    list = (@failures[method]? || [] of Exception)
    list << ex
    @failures[method] = list
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    if list = @failures[method]?
      if ex = list.shift?
        @failures[method] = list
        raise ex
      end
    end
    %({}).to_slice
  end
end

private class MustNavigationPage < Rod::Page
  property last_wait_name : String? = nil
  property wait_open_called = false
  property wait_request_idle_called = false

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def wait_navigation(name : String = "networkAlmostIdle") : Proc(Nil)
    @last_wait_name = name
    -> { }
  end

  def wait_open : Proc(Rod::Page)
    @wait_open_called = true
    -> { self.as(Rod::Page) }
  end

  def wait_request_idle(
    d : Time::Span,
    includes : Array(String)? = nil,
    excludes : Array(String)? = nil,
    exclude_types : Array(Cdp::Network::ResourceType)? = nil,
  ) : Proc(Nil)
    @wait_request_idle_called = true
    -> { }
  end
end

describe Rod::Page do
  describe "#wait" do
    it "retries until the evaluated expression becomes true" do
      page = WaitStubPage.new
      page.results = [false, false, true]

      page.wait(Rod::EvalOptions.new(js: "() => true"))

      page.eval_calls.should eq(3)
    end

    it "propagates evaluate errors" do
      page = WaitStubPage.new
      page.eval_error = Exception.new("boom")

      expect_raises(Exception, "boom") { page.wait(Rod::EvalOptions.new(js: "() => true")) }
    end
  end

  describe "#wait_elements_more_than" do
    it "delegates to wait with querySelectorAll length check" do
      page = WaitStubPage.new
      page.results = [true]

      page.wait_elements_more_than(".row", 2)

      opts = page.last_opts.not_nil!
      opts.js.should contain("querySelectorAll")
      opts.js_args.size.should eq(2)
      opts.js_args[0].should eq(JSON.parse(%(".row")))
      opts.js_args[1].should eq(JSON.parse("2"))
    end
  end

  describe "#reload" do
    it "uses location.reload via evaluate with user gesture" do
      browser = NavigationStubBrowser.new
      page = ReloadStubPage.new(browser)

      page.reload

      opts = page.last_eval_opts.not_nil!
      opts.js.should eq("() => location.reload()")
      opts.user_gesture?.should be_true
    end
  end

  describe "#wait_navigation" do
    it "enables lifecycle events, waits on lifecycle event name, and disables afterward" do
      browser = NavigationStubBrowser.new
      page = NavigationStubPage.new(browser)

      wait = page.wait_navigation("networkAlmostIdle")

      page.method_calls.count("Page.setLifecycleEventsEnabled").should eq(1)
      browser.last_session_id.should eq(Rod::SessionID.new("session-1"))
      cb_info = browser.last_callbacks.not_nil![Cdp::Page::LifecycleEventEvent.proto_event]

      matched = Cdp::Page::LifecycleEventEvent.new("frame-1", "loader-1", "networkAlmostIdle", 1.0)
      unmatched = Cdp::Page::LifecycleEventEvent.new("frame-1", "loader-1", "DOMContentLoaded", 1.0)
      cb_info.callback.call(matched, nil).should eq(true)
      cb_info.callback.call(unmatched, nil).should eq(false)

      wait.call

      browser.wait_called.should be_true
      page.method_calls.count("Page.setLifecycleEventsEnabled").should eq(2)
    end
  end

  describe "#wait_open" do
    it "returns the opened page when target opener matches the current page" do
      browser = NavigationStubBrowser.new
      opened_page = Rod::Page.new(browser, Rod::TargetID.new("child-target"))
      browser.page_from_target_result = opened_page
      page = NavigationStubPage.new(browser)

      wait = page.wait_open
      cb_info = browser.last_callbacks.not_nil![Cdp::Target::TargetCreatedEvent.proto_event]
      event = Cdp::Target::TargetCreatedEvent.from_json(%({
        "targetInfo": {
          "targetId": "child-target",
          "type": "page",
          "title": "",
          "url": "",
          "attached": false,
          "openerId": "target-id",
          "canAccessOpener": true,
          "openerFrameId": null,
          "parentFrameId": null,
          "browserContextId": null,
          "subtype": null
        }
      }))
      cb_info.callback.call(event, nil).should eq(true)

      wait.call.should eq(opened_page)
      browser.last_page_target_id.should eq(Rod::TargetID.new("child-target"))
    end
  end

  describe "#wait_request_idle" do
    it "returns a wait proc and uses default include/exclude wiring" do
      browser = NavigationStubBrowser.new
      page = NavigationStubPage.new(browser)

      wait = page.wait_request_idle(10.milliseconds, nil, [".*ignore.*"], nil)
      wait.call

      callbacks = browser.last_callbacks.not_nil!
      callbacks.has_key?(Cdp::Network::RequestWillBeSentEvent.proto_event).should be_true
      callbacks.has_key?(Cdp::Network::LoadingFinishedEvent.proto_event).should be_true
      callbacks.has_key?(Cdp::Network::LoadingFailedEvent.proto_event).should be_true
      browser.wait_called.should be_true
    end
  end

  describe "#handle_dialog" do
    it "waits for javascript dialog and then handles it with restore on completion" do
      browser = DialogStubBrowser.new
      browser.dialog_event = Cdp::Page::JavascriptDialogOpeningEvent.from_json(%({
        "url":"https://example.test",
        "frameId":"frame-1",
        "message":"m",
        "type":"alert",
        "hasBrowserHandler":true,
        "defaultPrompt":""
      }))
      page = DialogStubPage.new(browser)

      wait, handle = page.handle_dialog
      event = wait.call
      event.message.should eq("m")
      browser.waited_proto_events.should contain(Cdp::Page::JavascriptDialogOpeningEvent.proto_event)

      handle.call(Cdp::Page::HandleJavaScriptDialog.new(true, "ok"))
      page.method_calls.should contain("Page.enable")
      page.method_calls.should contain("Page.handleJavaScriptDialog")
      page.method_calls.should contain("Page.disable")
    end
  end

  describe "#handle_file_dialog" do
    it "intercepts next file chooser and sets absolute files via backend node id" do
      browser = DialogStubBrowser.new
      browser.file_event = Cdp::Page::FileChooserOpenedEvent.from_json(%({
        "frameId":"frame-1",
        "mode":"selectSingle",
        "backendNodeId":42
      }))
      page = DialogStubPage.new(browser)

      set_files = page.handle_file_dialog
      set_files.call(["./temp/a.txt"])

      page.method_calls.should contain("Page.setInterceptFileChooserDialog")
      page.method_calls.should contain("DOM.setFileInputFiles")
    end

    it "surfaces intercept enable errors (Go TestPageHandleFileDialog parity)" do
      browser = DialogStubBrowser.new
      page = DialogStubPage.new(browser)
      page.fail_once("Page.setInterceptFileChooserDialog", Exception.new("enable failed"))

      expect_raises(Exception, "enable failed") do
        page.handle_file_dialog
      end
    end

    it "surfaces intercept disable errors during set_files (Go TestPageHandleFileDialog parity)" do
      browser = DialogStubBrowser.new
      browser.file_event = Cdp::Page::FileChooserOpenedEvent.from_json(%({
        "frameId":"frame-1",
        "mode":"selectSingle",
        "backendNodeId":42
      }))
      page = DialogStubPage.new(browser)

      set_files = page.handle_file_dialog
      page.fail_once("Page.setInterceptFileChooserDialog", Exception.new("disable failed"))

      expect_raises(Exception, "disable failed") do
        set_files.call(["./temp/a.txt"])
      end

      page.method_calls.count("Page.setInterceptFileChooserDialog").should eq(2)
      page.method_calls.should_not contain("DOM.setFileInputFiles")
    end
  end
end

describe Rod::Page do
  describe "#must_wait_navigation" do
    it "uses networkAlmostIdle by default and supports custom names" do
      page = MustNavigationPage.new

      page.must_wait_navigation.call
      page.last_wait_name.should eq("networkAlmostIdle")

      page.must_wait_navigation("DOMContentLoaded").call
      page.last_wait_name.should eq("DOMContentLoaded")
    end
  end

  describe "#must_wait_open and #must_wait_request_idle" do
    it "delegates to the corresponding wait methods" do
      page = MustNavigationPage.new

      page.must_wait_open.call.should eq(page)
      page.must_wait_request_idle.call

      page.wait_open_called.should be_true
      page.wait_request_idle_called.should be_true
    end
  end
end
