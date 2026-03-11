require "./spec_helper"

private class IncognitoStubBrowser < Rod::Browser
  getter methods = [] of String
  getter params = [] of JSON::Any

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, payload : JSON::Any) : Bytes
    @methods << method
    @params << payload

    case method
    when "Target.createBrowserContext"
      %({"browserContextId":"ctx-1"}).to_slice
    else
      %({}).to_slice
    end
  end
end

describe "browser incognito parity" do
  it "creates incognito browser context and closes via disposeBrowserContext" do
    browser = IncognitoStubBrowser.new

    incognito = browser.incognito
    incognito.browser_context_id.should eq(Rod::BrowserContextID.new("ctx-1"))

    incognito.close

    browser.methods.should contain("Target.createBrowserContext")
    browser.methods.should contain("Target.disposeBrowserContext")
    browser.methods.should_not contain("Browser.close")
  end

  it "closes normal browser with Browser.close" do
    browser = IncognitoStubBrowser.new
    browser.close

    browser.methods.should contain("Browser.close")
  end
end
