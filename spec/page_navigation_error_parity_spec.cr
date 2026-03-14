require "./spec_helper"

private class NavigateErrorStubPage < Rod::Page
  property responses = {} of String => String

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"), Rod::SessionID.new("session-1"), Rod::FrameID.new("frame-1"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    (@responses[method]? || %({})).to_slice
  end
end

private def with_real_browser_for_navigation(&)
  launcher = Rod::Util::Launcher.new
  browser = Rod::Browser.new

  begin
    ws_url = launcher.launch
    browser.connect(ws_url)
    yield browser
  ensure
    begin
      browser.close
    rescue
      nil
    end
    begin
      launcher.kill
    rescue
      nil
    end
    begin
      launcher.cleanup
    rescue
      nil
    end
  end
end

describe "page navigation error parity" do
  it "maps Page.navigate errorText to Rod::NavigationError (go parity)" do
    page = NavigateErrorStubPage.new
    page.responses["Page.navigate"] = %({"frameId":"frame-1","errorText":"net::ERR_NAME_NOT_RESOLVED"})

    ex = expect_raises(Rod::NavigationError) { page.navigate("http://nonexistent.invalid") }
    ex.message.should eq("navigation failed: net::ERR_NAME_NOT_RESOLVED")
  end

  it "matches go network navigation error behavior in real browser" do
    next unless ENV["ROD_REAL_BROWSER"]? == "1"

    with_real_browser_for_navigation do |browser|
      page = browser.page

      ex = expect_raises(Rod::NavigationError) { page.navigate("http://nonexistent.invalid") }
      ex.message.should eq("navigation failed: net::ERR_NAME_NOT_RESOLVED")

      # Go TestPageNavigateNetworkErr parity: navigation still works after network error.
      page.navigate("about:blank")
    end
  end
end
