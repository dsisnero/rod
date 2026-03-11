require "./spec_helper"

private class PageWaitEventBrowser < Rod::Browser
  property seen_session : Rod::SessionID? = nil

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def wait_event(e : Cdp::Event, session_id : Rod::SessionID? = nil) : Proc(Nil)
    @seen_session = session_id
    -> { nil }
  end
end

private class PageWaitEventFanoutBrowser < Rod::Browser
  @subs = [] of Channel(Rod::Message)
  @subs_lock = Mutex.new

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end

  def event : Channel(Rod::Message)
    ch = Channel(Rod::Message).new(4)
    @subs_lock.synchronize { @subs << ch }
    ch
  end

  def emit(msg : Rod::Message) : Nil
    subs = @subs_lock.synchronize { @subs.dup }
    subs.each(&.send(msg))
  end
end

describe "page wait_event parity" do
  it "forwards page session id to browser wait_event" do
    browser = PageWaitEventBrowser.new
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("sid-1"))

    event = Cdp::Page::LifecycleEventEvent.from_json(%({
      "frameId":"frame-1",
      "loaderId":"loader-1",
      "name":"load",
      "timestamp":"2026-01-01T00:00:00Z"
    }))

    page.wait_event(event).call

    browser.seen_session.should eq(Rod::SessionID.new("sid-1"))
  end

  it "matches go parse-once behavior with two waiters on same event occurrence" do
    browser = PageWaitEventFanoutBrowser.new
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("sid-1"))

    nav_event = Cdp::Page::LifecycleEventEvent.from_json(%({
      "frameId":"frame-1",
      "loaderId":"loader-1",
      "name":"networkAlmostIdle",
      "timestamp":"2026-01-01T00:00:00Z"
    }))

    wait1 = page.wait_event(nav_event)
    wait2 = page.wait_event(nav_event)

    done = Channel(Nil).new(2)
    spawn do
      wait1.call
      done.send(nil)
    end
    spawn do
      wait2.call
      done.send(nil)
    end

    browser.emit(Rod::Message.new(Rod::SessionID.new("sid-1"), nav_event.proto_event, JSON.parse(nav_event.to_json)))

    done.receive
    done.receive
  end
end
