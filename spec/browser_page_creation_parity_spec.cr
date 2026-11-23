require "./spec_helper"

private class PageCreationStubPage < Rod::Page
  property navigated_to : String? = nil

  def navigate(url : String) : Nil
    @navigated_to = url
  end
end

private class PageCreationBrowser < Rod::Browser
  property fail_page_from_target : Exception? = nil
  property next_page : Rod::Page? = nil
  getter closed_target_ids = [] of String
  getter method_calls = [] of String
  getter method_params = {} of String => JSON::Any

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    @method_params[method] = params
    case method
    when "Target.createTarget"
      %({"targetId":"target-1"}).to_slice
    when "Target.attachToTarget"
      %({"sessionId":"sid-1"}).to_slice
    when "Target.closeTarget"
      @closed_target_ids << params["targetId"].as_s
      %({"success":true}).to_slice
    else
      %({}).to_slice
    end
  end

  def page_from_target(target_id : Rod::TargetID) : Rod::Page
    if ex = @fail_page_from_target
      raise ex
    end

    @next_page || super
  end
end

describe "browser page creation parity" do
  it "closes created target when page_from_target fails (Go parity cleanup path)" do
    browser = PageCreationBrowser.new
    browser.fail_page_from_target = Exception.new("attach failed")

    expect_raises(Exception, /attach failed/) do
      browser.page("https://example.test")
    end

    browser.closed_target_ids.should eq(["target-1"])
  end

  it "navigates newly created page when url is not about:blank" do
    browser = PageCreationBrowser.new
    page = PageCreationStubPage.new(browser, Rod::TargetID.new("target-1"))
    browser.next_page = page

    created = browser.page("https://example.test")

    created.should eq(page)
    page.navigated_to.should eq("https://example.test")
  end

  it "does not navigate when url is about:blank" do
    browser = PageCreationBrowser.new
    page = PageCreationStubPage.new(browser, Rod::TargetID.new("target-1"))
    browser.next_page = page

    browser.page("about:blank")

    page.navigated_to.should be_nil
  end

  it "applies default device emulation when creating pages" do
    browser = PageCreationBrowser.new
    browser.default_device(Rod::Util::Devices::IPhone6or7or8)
    browser.page("about:blank")

    browser.method_calls.should contain("Emulation.setDeviceMetricsOverride")
    browser.method_calls.should contain("Emulation.setTouchEmulationEnabled")
    browser.method_calls.should contain("Emulation.setUserAgentOverride")
  end

  it "no_default_device disables automatic emulation for new pages" do
    browser = PageCreationBrowser.new
    browser.default_device(Rod::Util::Devices::IPhone6or7or8)
    browser.no_default_device
    browser.page("about:blank")

    browser.method_calls.should_not contain("Emulation.setDeviceMetricsOverride")
    browser.method_calls.should_not contain("Emulation.setTouchEmulationEnabled")
    browser.method_calls.should_not contain("Emulation.setUserAgentOverride")
  end

  it "forwards go's Target.createTarget options like Browser.Page" do
    browser = PageCreationBrowser.new
    browser.browser_context_id = Rod::BrowserContextID.new("ctx-1")
    page = PageCreationStubPage.new(browser, Rod::TargetID.new("target-1"))
    browser.next_page = page

    # go: `func (b *Browser) Page(opts proto.TargetCreateTarget)` forwards the
    # caller's options, forces the creation URL to `about:blank` and adds the
    # browser context (`browser.go:267-316`).
    created = browser.page(Cdp::Target::CreateTarget.new("https://example.test", new_window: true, background: true))

    created.should eq(page)
    params = browser.method_params["Target.createTarget"]
    params["url"].as_s.should eq("about:blank")
    params["newWindow"].as_bool.should be_true
    params["background"].as_bool.should be_true
    params["browserContextId"].as_s.should eq("ctx-1")
    page.navigated_to.should eq("https://example.test")
  end

  it "navigates an options-created page even for about:blank like go" do
    browser = PageCreationBrowser.new
    page = PageCreationStubPage.new(browser, Rod::TargetID.new("target-1"))
    browser.next_page = page

    browser.page(Cdp::Target::CreateTarget.new("about:blank"))

    # go only skips the navigation for an *empty* URL (`if opts.URL == "" { return }`).
    page.navigated_to.should eq("about:blank")
  end
end

describe "browser page creation with a real browser" do
  it "opens a new window through go's Target.createTarget options" do
    RodSpec.with_live_browser do |browser|
      page = browser.page(Cdp::Target::CreateTarget.new("", new_window: true))
      begin
        page.must_eval("() => location.href").as_s.should eq("about:blank")
        page.must_eval("() => 1 + 1").should eq(JSON.parse("2"))
      ensure
        page.must_close
      end
    end
  end
end
