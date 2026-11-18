require "./spec_helper"

# go-rod's `Page.Navigate` only stops the current load, calls `Page.navigate`,
# turns a non-empty `errorText` into a NavigationError and unsets the JS context.
# It never waits for network events: Chrome already reports
# `net::ERR_HTTP_RESPONSE_CODE_FAILURE` through `errorText` for HTTP error
# responses, so a second watcher only adds latency and can attribute another
# response's status to this navigation.
private class NavigateStubBrowser < Rod::Browser
  @lock = Mutex.new
  @callbacks : Hash(String, Rod::Browser::CallbackInfo)? = nil
  @waiter : Channel(Nil)? = nil

  # Payload returned by the next `Page.navigate` call.
  property navigate_result : String = %({"frameId":"frame-1"})
  getter calls = [] of String

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end

  def each_event(session_id : Rod::SessionID?, callbacks : Hash(String, Rod::Browser::CallbackInfo)) : Proc(Nil)
    _ = session_id
    waiter = Channel(Nil).new(1)
    @lock.synchronize do
      @callbacks = callbacks
      @waiter = waiter
    end
    -> { waiter.receive? }
  end

  # Fires an event at the registered callbacks, releasing the waiter when one
  # accepts it, exactly like `Browser#each_event`.
  def dispatch(method : String, payload : String) : Bool
    info = @lock.synchronize { @callbacks.try(&.[method]?) }
    return false unless info

    event = info.loader.call(JSON.parse(payload))
    matched = info.callback.call(event, nil) == true
    @lock.synchronize { @waiter.try(&.send(nil)) } if matched
    matched
  end
end

private class NavigateStubPage < Rod::Page
  getter browser_stub : NavigateStubBrowser

  def initialize(browser : NavigateStubBrowser)
    @browser_stub = browser
    super(browser, Rod::TargetID.new("target-1"), Rod::SessionID.new("sid-1"), Rod::FrameID.new("frame-1"))
  end

  # Answers the CDP commands `navigate` issues without a browser.
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @browser_stub.calls << method
    payload = case method
              when "Page.navigate"
                @browser_stub.navigate_result
              else
                "{}"
              end
    payload.to_slice
  end
end

private def http_error_response_payload(status : Int32) : String
  {
    "requestId" => "req-1",
    "loaderId"  => "loader-1",
    "timestamp" => 1.0,
    "type"      => "Document",
    "response"  => {
      "url"               => "http://127.0.0.1:1/404",
      "status"            => status,
      "statusText"        => "Not Found",
      "headers"           => {} of String => String,
      "mimeType"          => "text/html",
      "charset"           => "",
      "connectionReused"  => false,
      "connectionId"      => 1.0,
      "encodedDataLength" => 1.0,
      "securityState"     => "secure",
    },
    "frameId"      => "frame-1",
    "hasExtraInfo" => false,
  }.to_json
end

describe "page navigate parity" do
  it "returns without waiting for network response events" do
    browser = NavigateStubBrowser.new
    page = NavigateStubPage.new(browser)

    start = Time.instant
    page.navigate("http://127.0.0.1:1/slow")
    elapsed = Time.instant - start

    browser.calls.should contain("Page.stopLoading")
    browser.calls.should contain("Page.navigate")
    # go-rod does not wait at all here; the port used to block for up to 3s.
    elapsed.should be < 1.second
  end

  it "raises NavigationError from the protocol error text" do
    browser = NavigateStubBrowser.new
    browser.navigate_result = %({"frameId":"frame-1","errorText":"net::ERR_NAME_NOT_RESOLVED"})
    page = NavigateStubPage.new(browser)

    expect_raises(Rod::NavigationError, /ERR_NAME_NOT_RESOLVED/) do
      page.navigate("http://no-such-host.invalid/")
    end
  end

  it "does not attribute another HTTP error response to this navigation" do
    browser = NavigateStubBrowser.new
    page = NavigateStubPage.new(browser)

    # A document response with an error status that does not belong to this
    # navigation (e.g. a frame or a previous load). go-rod only looks at
    # `Page.navigate`'s own `errorText`.
    done = Channel(Nil).new(1)
    spawn do
      page.navigate("http://127.0.0.1:1/ok")
      done.send(nil)
    end

    sleep 50.milliseconds
    browser.dispatch(Cdp::Network::ResponseReceivedEvent.proto_event, http_error_response_payload(404))

    select
    when done.receive?
      # Returned without inventing a navigation error.
    when timeout(5.seconds)
      fail "navigate did not return"
    end
  end
end
