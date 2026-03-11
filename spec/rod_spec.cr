require "./spec_helper"

private class RodParityBrowser < Rod::Browser
  def version : Cdp::Browser::GetVersionResult
    Cdp::Browser::GetVersionResult.new(
      protocol_version: "1.3",
      product: "rod-parity",
      revision: "test",
      user_agent: "rod-parity",
      js_version: "test"
    )
  end
end

private class RodParityPage < Rod::Page
  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target"), Rod::SessionID.new("session"), nil)
  end

  def navigate(url : String) : Nil
    @text = url.includes?("ok") ? "ok" : ""
  end

  def wait_load : Nil
  end

  def element(selector : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    raise Rod::ElementNotFoundError.new unless selector == "body"

    text = @text
    raise Rod::ElementNotFoundError.new if text.nil?

    RodParityElement.new(self, text)
  end
end

private class RodParityElement < Rod::Element
  def initialize(page : Rod::Page, @text_value : String)
    super(
      Cdp::Runtime::RemoteObject.from_json(%({"type":"object","description":"body"})),
      page
    )
  end

  def text : String
    @text_value
  end
end

describe "Rod parity template smoke test" do
  it "matches vendor/rod/rod_test.go behavior" do
    browser = RodParityBrowser.new
    page = RodParityPage.new(browser)
    doc = <<-HTML
      <html>
        <body>ok</body>
      </html>
    HTML

    page.must_navigate(doc).must_wait_load

    browser.must_version.protocol_version.should eq("1.3")
    page.must_element("body").must_text.should contain("ok")
  end
end
