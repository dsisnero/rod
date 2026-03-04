require "./spec_helper"

private class CookieCaptureBrowser < Rod::Browser
  getter captured_cookie_params : Array(Cdp::Network::CookieParam)?
  getter? cleared = false

  def set_cookies(cookies : Array(Cdp::Network::CookieParam)? = nil) : Nil # ameba:disable Naming/AccessorMethodName
    if cookies.nil?
      @cleared = true
    else
      @captured_cookie_params = cookies
    end
  end
end

private class WaitEventBrowser < Rod::Browser
  def initialize(@messages : Channel(Rod::Message))
    super()
  end

  def event : Channel(Rod::Message)
    @messages
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end
end

describe Rod::Browser do
  it "converts Network::Cookie to Network::CookieParam when setting cookies" do
    browser = CookieCaptureBrowser.new
    cookie = Cdp::Network::Cookie.from_json({
      "name"               => "a",
      "value"              => "1",
      "domain"             => "example.com",
      "path"               => "/",
      "expires"            => 0.0,
      "size"               => 1,
      "httpOnly"           => false,
      "secure"             => false,
      "session"            => false,
      "sameSite"           => Cdp::Network::CookieSameSiteLax,
      "priority"           => Cdp::Network::CookiePriorityMedium,
      "sourceScheme"       => Cdp::Network::CookieSourceSchemeNonSecure,
      "sourcePort"         => 80,
      "partitionKey"       => nil,
      "partitionKeyOpaque" => nil,
    }.to_json)

    browser.set_cookies([cookie])

    if captured = browser.captured_cookie_params
      captured.size.should eq(1)
      captured[0].name.should eq("a")
      captured[0].value.should eq("1")
      captured[0].domain.should eq("example.com")
    else
      raise "expected converted cookie params to be captured"
    end
  end

  it "clears cookies when nil is passed to cookie param setter" do
    browser = CookieCaptureBrowser.new
    browser.set_cookies(nil.as(Array(Cdp::Network::CookieParam)?))
    browser.cleared?.should be_true
  end

  it "returns typed payload from wait_event_typed" do
    event = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-1",
      url: "https://example.com/file",
      suggested_filename: "file.txt"
    )
    messages = Channel(Rod::Message).new(1)
    messages.send(Rod::Message.new(nil, event.proto_event, JSON.parse(event.to_json)))
    browser = WaitEventBrowser.new(messages)

    waited = browser.wait_event_typed(Cdp::Browser::DownloadWillBeginEvent)
    loaded = waited.call

    loaded.guid.should eq("guid-1")
    loaded.suggested_filename.should eq("file.txt")
  end
end
