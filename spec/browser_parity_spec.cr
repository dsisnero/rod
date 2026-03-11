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

private class CookiesStubBrowser < Rod::Browser
  getter calls = 0

  def get_cookies : Array(Cdp::Network::Cookie) # ameba:disable Naming/AccessorMethodName
    @calls += 1
    [] of Cdp::Network::Cookie
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
      captured[0].expires.should_not be_nil
      captured[0].expires.not_nil!.to_unix.should eq(0)
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

  it "supports timeout cancel chain before get_cookies" do
    browser = CookiesStubBrowser.new
    derived = browser.timeout(1.second).cancel_timeout.as(CookiesStubBrowser)
    derived.get_cookies
    derived.calls.should eq(1)
  end

  it "raises on connect conflict when both client and control_url are set" do
    browser = Rod::Browser.new
      .client(Rod::Lib::Cdp::Client.new)
      .control_url("ws://example.invalid")

    expect_raises(Exception, /can't be set at the same time/) do
      browser.connect
    end
  end

  it "must_connect raises when control_url is invalid (go TestBrowserConnectErr parity)" do
    browser = Rod::Browser.new.control_url("bad-url")
    expect_raises(Exception) { browser.must_connect }
  end

  it "connect fails when called with an already-canceled context" do
    ctx, cancel = Rod::Context.background.with_cancel
    cancel.call
    browser = Rod::Browser.new.context(ctx).control_url("bad-url")

    expect_raises(Exception) { browser.connect }
  end

  it "wait_event consumes the next matching event and returns nil" do
    event = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-2",
      guid: "guid-2",
      url: "https://example.com/other",
      suggested_filename: "other.txt"
    )
    messages = Channel(Rod::Message).new(1)
    messages.send(Rod::Message.new(nil, event.proto_event, JSON.parse(event.to_json)))
    browser = WaitEventBrowser.new(messages)

    wait = browser.wait_event(event)
    wait.call.should be_nil
  end
end

describe Rod::Message do
  it "loads matching event payload by class and returns nil for mismatch" do
    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-3",
      guid: "guid-3",
      url: "https://example.com/three",
      suggested_filename: "three.txt"
    )
    msg = Rod::Message.new(nil, payload.proto_event, JSON.parse(payload.to_json))

    loaded = msg.load(Cdp::Browser::DownloadWillBeginEvent)
    loaded.should_not be_nil
    loaded.not_nil!.as(Cdp::Browser::DownloadWillBeginEvent).guid.should eq("guid-3")

    msg.load(Cdp::Browser::DownloadProgressEvent).should be_nil
  end

  it "returns boolean load status for event instance matching" do
    payload = Cdp::Browser::DownloadProgressEvent.new(
      guid: "guid-4",
      total_bytes: 100.0,
      received_bytes: 100.0,
      state: Cdp::Browser::DownloadProgressStateCompleted,
      file_path: "/tmp/guid-4"
    )
    msg = Rod::Message.new(nil, payload.proto_event, JSON.parse(payload.to_json))

    matching = Cdp::Browser::DownloadProgressEvent.new(
      guid: "",
      total_bytes: 0.0,
      received_bytes: 0.0,
      state: Cdp::Browser::DownloadProgressStateInProgress,
      file_path: nil
    )
    mismatching = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame",
      guid: "",
      url: "",
      suggested_filename: ""
    )

    msg.load(matching).should be_true
    msg.load(mismatching).should be_false
  end
end
