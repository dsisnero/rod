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

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
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
end
