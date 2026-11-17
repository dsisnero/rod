require "./spec_helper"

# `Page#reload` must mirror go-rod's `Page.Reload`: subscribe to
# `Page.frameNavigated` for this page's frame *before* triggering
# `location.reload()`, then wait for it. Returning as soon as the JS call is
# accepted makes the next query race the navigation, which is how
# `TestSearchIframesAfterReload` intermittently picked up a node handle from the
# destroyed frame context.
private class ReloadStubBrowser < Rod::Browser
  @lock = Mutex.new
  @callbacks : Hash(String, Rod::Browser::CallbackInfo)? = nil
  @waiter : Channel(Nil)? = nil

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

  # Fires an event at the registered callbacks and releases the waiter only when
  # a callback accepts it, exactly like `Browser#each_event`.
  def dispatch(method : String, payload : String) : Bool
    info = @lock.synchronize { @callbacks.try(&.[method]?) }
    return false unless info

    event = info.loader.call(JSON.parse(payload))
    matched = info.callback.call(event, nil) == true
    if matched
      @lock.synchronize { @waiter.try(&.send(nil)) }
    end
    matched
  end

  def subscribed_events : Array(String)
    @lock.synchronize { @callbacks.try(&.keys) || [] of String }
  end
end

private class ReloadStubPage < Rod::Page
  getter evaluated = [] of String

  def initialize(browser : Rod::Browser, frame_id : String = "frame-1")
    super(browser, Rod::TargetID.new("target-1"), Rod::SessionID.new("sid-1"), Rod::FrameID.new(frame_id))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @evaluated << opts.js
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private def frame_navigated_payload(frame_id : String) : String
  {
    "frame" => {
      "id"                             => frame_id,
      "loaderId"                       => "loader-1",
      "url"                            => "file:///click.html",
      "domainAndRegistry"              => "",
      "securityOrigin"                 => "file://",
      "mimeType"                       => "text/html",
      "secureContextType"              => "Secure",
      "crossOriginIsolatedContextType" => "NotIsolated",
      "gatedAPIFeatures"               => [] of String,
    },
    "type" => "Reload",
  }.to_json
end

private def wait_for_subscription(browser : ReloadStubBrowser) : Nil
  deadline = Time.instant + 2.seconds
  while browser.subscribed_events.empty? && Time.instant < deadline
    sleep 10.milliseconds
  end
end

describe "page reload parity" do
  it "reloads through location.reload before waiting like go" do
    browser = ReloadStubBrowser.new
    page = ReloadStubPage.new(browser)

    done = Channel(Nil).new(1)
    spawn do
      page.reload
      done.send(nil)
    end

    wait_for_subscription(browser)
    # Go triggers `location.reload()` (not the CDP `Page.reload`, which does
    # not work for iframes) and only then waits for the navigation.
    page.evaluated.size.should eq(1)
    page.evaluated.first.should contain("location.reload()")

    browser.dispatch(Cdp::Page::FrameNavigatedEvent.proto_event, frame_navigated_payload("frame-1")).should be_true
    select
    when done.receive?
    when timeout(2.seconds)
      fail "reload did not return after frameNavigated"
    end
  end

  it "waits for this frame's frameNavigated event before returning" do
    browser = ReloadStubBrowser.new
    page = ReloadStubPage.new(browser, frame_id: "frame-1")

    done = Channel(Nil).new(1)
    spawn do
      page.reload
      done.send(nil)
    end

    # The subscription is registered before the reload JS runs, otherwise the
    # navigation event can be missed.
    wait_for_subscription(browser)
    browser.subscribed_events.should contain(Cdp::Page::FrameNavigatedEvent.proto_event)

    sleep 50.milliseconds
    select
    when done.receive?
      fail "reload returned before any frameNavigated event"
    else
      # Still waiting.
    end

    # Another frame's navigation must not release the wait.
    browser.dispatch(Cdp::Page::FrameNavigatedEvent.proto_event, frame_navigated_payload("frame-other")).should be_false
    sleep 50.milliseconds
    select
    when done.receive?
      fail "reload returned for another frame's navigation"
    else
      # Still waiting.
    end

    browser.dispatch(Cdp::Page::FrameNavigatedEvent.proto_event, frame_navigated_payload("frame-1")).should be_true
    select
    when done.receive?
      # Returned after the navigation settled.
    when timeout(2.seconds)
      fail "reload did not return after frameNavigated for its own frame"
    end
  end
end
