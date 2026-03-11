require "./spec_helper"

private class PagesListBrowser < Rod::Browser
  property targets_payload : String = %({"targetInfos":[]})
  property fail_get_targets : Exception? = nil
  getter requested_target_ids = [] of String

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    case method
    when "Target.getTargets"
      if ex = @fail_get_targets
        raise ex
      end
      @targets_payload.to_slice
    else
      %({}).to_slice
    end
  end

  def page_from_target(target_id : Rod::TargetID) : Rod::Page
    @requested_target_ids << target_id.value
    Rod::Page.new(self, target_id)
  end
end

private class VersionStubBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    case method
    when "Browser.getVersion"
      %({
        "protocolVersion":"1.3",
        "product":"Chrome/123.0.0.0",
        "revision":"rev",
        "userAgent":"ua",
        "jsVersion":"js"
      }).to_slice
    else
      %({}).to_slice
    end
  end
end

describe "browser pages parity" do
  it "returns only page targets (filters iframe/other target types)" do
    browser = PagesListBrowser.new
    browser.targets_payload = %({
      "targetInfos": [
        {"targetId":"p1","type":"page","title":"p1","url":"about:blank","attached":false,"canAccessOpener":false},
        {"targetId":"f1","type":"iframe","title":"f1","url":"about:blank","attached":false,"canAccessOpener":false},
        {"targetId":"w1","type":"worker","title":"w1","url":"about:blank","attached":false,"canAccessOpener":false},
        {"targetId":"p2","type":"page","title":"p2","url":"about:blank","attached":false,"canAccessOpener":false}
      ]
    })

    pages = browser.pages

    pages.size.should eq(2)
    browser.requested_target_ids.should eq(["p1", "p2"])
  end

  it "propagates getTargets failures for pages and must_pages" do
    browser = PagesListBrowser.new
    browser.fail_get_targets = Exception.new("getTargets failed")

    expect_raises(Exception, /getTargets failed/) { browser.pages }
    expect_raises(Exception, /getTargets failed/) { browser.must_pages }
  end

  it "returns typed version payload from Browser.getVersion (Go TestBrowserCall parity)" do
    browser = VersionStubBrowser.new
    browser.version.protocol_version.should eq("1.3")
    browser.must_version.protocol_version.should eq("1.3")
  end
end
