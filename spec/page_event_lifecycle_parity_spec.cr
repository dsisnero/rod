require "./spec_helper"

private class PageEventLifecycleBrowser < Rod::Browser
  property event_channel : Channel(Rod::Message)

  def initialize
    super()
    @event_channel = Channel(Rod::Message).new(4)
  end

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def event : Channel(Rod::Message)
    @event_channel
  end
end

describe "page event lifecycle parity" do
  it "stops page event stream when upstream browser event channel closes" do
    browser = PageEventLifecycleBrowser.new
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("sid-1"))
    events = page.event

    browser.event_channel.send(Rod::Message.new(Rod::SessionID.new("sid-1"), "Page.frameStartedLoading", JSON.parse(%({}))))
    events.receive.method.should eq("Page.frameStartedLoading")

    browser.event_channel.close

    closed = Channel(Bool).new(1)
    spawn do
      closed.send(events.receive?.nil?)
    end

    select
    when ok = closed.receive
      ok.should be_true
    when timeout(1.second)
      fail("page event channel did not close after upstream detach/close")
    end
  end

  it "stops page event stream after detach event for same session (go TestPageStopEventAfterDetach parity)" do
    browser = PageEventLifecycleBrowser.new
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"), Rod::SessionID.new("sid-1"))
    events = page.event

    browser.event_channel.send(Rod::Message.new(Rod::SessionID.new("sid-1"), "Page.frameStartedLoading", JSON.parse(%({}))))
    events.receive.method.should eq("Page.frameStartedLoading")

    browser.event_channel.send(
      Rod::Message.new(
        nil,
        Cdp::Target::DetachedFromTargetEvent.proto_event,
        JSON.parse(%({"sessionId":"sid-1","targetId":"target-id"}))
      )
    )

    closed = Channel(Bool).new(1)
    spawn do
      closed.send(events.receive?.nil?)
    end

    select
    when ok = closed.receive
      ok.should be_true
    when timeout(1.second)
      fail("page event channel did not close after detach")
    end
  end
end
