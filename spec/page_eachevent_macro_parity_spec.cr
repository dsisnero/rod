require "./spec_helper"

private class MacroPageEventBrowser < Rod::Browser
  getter methods = [] of String

  def initialize(@messages : Channel(Rod::Message))
    super()
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @methods << method
    %({}).to_slice
  end

  def event : Channel(Rod::Message)
    @messages
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end
end

private class MacroPageEventPage < Rod::Page
  property seen_name : String? = nil
  property seen_sid : Rod::SessionID? = nil

  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("target-1"), Rod::SessionID.new("sid-1"))
  end

  def macro_wait_one : Proc(Nil)
    eachevent(
      ->(event : Cdp::Page::LifecycleEventEvent) do
        @seen_name = event.name
        event.name == "networkAlmostIdle"
      end
    )
  end

  def macro_wait_two : Proc(Nil)
    eachevent(
      ->(event : Cdp::Page::LifecycleEventEvent, sid : Rod::SessionID?) do
        @seen_name = event.name
        @seen_sid = sid
        event.name == "networkAlmostIdle"
      end
    )
  end
end

describe "page eachevent macro parity" do
  it "supports one-arg callback and page session scoping" do
    events = Channel(Rod::Message).new(2)
    browser = MacroPageEventBrowser.new(events)
    page = MacroPageEventPage.new(browser)

    payload = Cdp::Page::LifecycleEventEvent.from_json(%({
      "frameId":"frame-1",
      "loaderId":"loader-1",
      "name":"networkAlmostIdle",
      "timestamp":"2026-01-01T00:00:00Z"
    }))

    events.send(Rod::Message.new(Rod::SessionID.new("sid-2"), payload.proto_event, JSON.parse(payload.to_json)))
    events.send(Rod::Message.new(Rod::SessionID.new("sid-1"), payload.proto_event, JSON.parse(payload.to_json)))

    page.macro_wait_one.call
    page.seen_name.should eq("networkAlmostIdle")
  end

  it "supports two-arg callback and yields matching session id" do
    events = Channel(Rod::Message).new(1)
    browser = MacroPageEventBrowser.new(events)
    page = MacroPageEventPage.new(browser)

    payload = Cdp::Page::LifecycleEventEvent.from_json(%({
      "frameId":"frame-1",
      "loaderId":"loader-1",
      "name":"networkAlmostIdle",
      "timestamp":"2026-01-01T00:00:00Z"
    }))

    events.send(Rod::Message.new(Rod::SessionID.new("sid-1"), payload.proto_event, JSON.parse(payload.to_json)))

    page.macro_wait_two.call
    page.seen_name.should eq("networkAlmostIdle")
    page.seen_sid.should eq(Rod::SessionID.new("sid-1"))
  end
end
