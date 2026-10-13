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

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    case method
    when "Target.attachToTarget"
      %({"sessionId":"sid-1"}).to_slice
    else
      %({}).to_slice
    end
  end
end

private def eventually(timeout : Time::Span = 1.second, &condition : -> Bool) : Bool
  deadline = Time.instant + timeout
  until condition.call
    return false if Time.instant >= deadline
    sleep 5.milliseconds
  end
  true
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

  it "cancels the page session context when the target detaches (Go Page.initEvents parity)" do
    browser = PageEventLifecycleBrowser.new
    page = browser.page_from_target(Rod::TargetID.new("target-id"))

    page.get_context.cancelled?.should be_false

    browser.event_channel.send(
      Rod::Message.new(
        Rod::SessionID.new("sid-1"),
        Cdp::Target::DetachedFromTargetEvent.proto_event,
        JSON.parse(%({"sessionId":"sid-1","targetId":"target-id"}))
      )
    )

    eventually { page.get_context.cancelled? }.should be_true
  end

  it "cancels the page session context when the target is destroyed (Go Page.initEvents parity)" do
    browser = PageEventLifecycleBrowser.new
    page = browser.page_from_target(Rod::TargetID.new("target-id"))

    page.get_context.cancelled?.should be_false

    browser.event_channel.send(
      Rod::Message.new(
        nil,
        Cdp::Target::TargetDestroyedEvent.proto_event,
        JSON.parse(%({"targetId":"target-id"}))
      )
    )

    eventually { page.get_context.cancelled? }.should be_true
  end

  it "does not cancel the page session context for another session's detach (Go Page.initEvents parity)" do
    browser = PageEventLifecycleBrowser.new
    page = browser.page_from_target(Rod::TargetID.new("target-id"))

    browser.event_channel.send(
      Rod::Message.new(
        Rod::SessionID.new("other-session"),
        Cdp::Target::DetachedFromTargetEvent.proto_event,
        JSON.parse(%({"sessionId":"other-session","targetId":"other-target"}))
      )
    )

    sleep 50.milliseconds
    page.get_context.cancelled?.should be_false
  end
end
