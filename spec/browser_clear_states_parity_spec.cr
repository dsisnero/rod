require "./spec_helper"

private class BrowserClearStateStub < Rod::Browser
  getter methods = [] of String

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    @methods << method
    %({}).to_slice
  end
end

describe "browser clear states parity" do
  it "allows clear geolocation override request without prior domain state" do
    browser = BrowserClearStateStub.new
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"))

    Cdp::Emulation::ClearGeolocationOverride.new.call(page)
    browser.methods.should contain("Emulation.clearGeolocationOverride")
  end
end
