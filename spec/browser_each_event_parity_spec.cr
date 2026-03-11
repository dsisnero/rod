require "./spec_helper"

private class EachEventStubBrowser < Rod::Browser
  getter method_calls = [] of String

  def initialize(@messages : Channel(Rod::Message))
    super()
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_calls << method
    %({}).to_slice
  end

  def event : Channel(Rod::Message)
    @messages
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end
end

describe "browser each_event parity" do
  it "filters by session id and restores domain state" do
    events = Channel(Rod::Message).new(2)
    browser = EachEventStubBrowser.new(events)

    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-1",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )

    events.send(Rod::Message.new(Rod::SessionID.new("sid-2"), payload.proto_event, JSON.parse(payload.to_json)))
    events.send(Rod::Message.new(Rod::SessionID.new("sid-1"), payload.proto_event, JSON.parse(payload.to_json)))

    seen = 0
    callbacks = {
      Cdp::Browser::DownloadWillBeginEvent.proto_event => Rod::Browser::CallbackInfo.new(
        Cdp::Browser::DownloadWillBeginEvent,
        ->(event : Cdp::Event, _sid : Rod::SessionID?) do
          seen += 1
          event.as(Cdp::Browser::DownloadWillBeginEvent).guid == "guid-1"
        end
      ),
    }

    wait = browser.each_event(Rod::SessionID.new("sid-1"), callbacks)
    wait.call

    seen.should eq(1)
    browser.method_calls.should contain("Browser.enable")
    browser.method_calls.should contain("Browser.disable")
  end

  it "raises when wait callback is used twice" do
    events = Channel(Rod::Message).new(1)
    browser = EachEventStubBrowser.new(events)

    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-1",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )
    events.send(Rod::Message.new(nil, payload.proto_event, JSON.parse(payload.to_json)))

    callbacks = {
      Cdp::Browser::DownloadWillBeginEvent.proto_event => Rod::Browser::CallbackInfo.new(
        Cdp::Browser::DownloadWillBeginEvent,
        ->(_event : Cdp::Event, _sid : Rod::SessionID?) { true }
      ),
    }

    wait = browser.each_event(nil, callbacks)
    wait.call

    expect_raises(Exception, /can't use wait function twice/) { wait.call }
  end

  it "supports callback signature with event and session id" do
    events = Channel(Rod::Message).new(1)
    browser = EachEventStubBrowser.new(events)

    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-9",
      guid: "guid-9",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )
    events.send(Rod::Message.new(Rod::SessionID.new("sid-9"), payload.proto_event, JSON.parse(payload.to_json)))

    got_sid : Rod::SessionID? = nil
    callbacks = {
      Cdp::Browser::DownloadWillBeginEvent.proto_event => Rod::Browser::CallbackInfo.new(
        Cdp::Browser::DownloadWillBeginEvent,
        ->(event : Cdp::Event, sid : Rod::SessionID?) do
          got_sid = sid
          event.as(Cdp::Browser::DownloadWillBeginEvent).guid == "guid-9"
        end
      ),
    }

    browser.each_event(nil, callbacks).call
    got_sid.should eq(Rod::SessionID.new("sid-9"))
  end

  it "wait_event_typed respects session filters" do
    events = Channel(Rod::Message).new(2)
    browser = EachEventStubBrowser.new(events)

    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-s",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )

    events.send(Rod::Message.new(Rod::SessionID.new("sid-other"), payload.proto_event, JSON.parse(payload.to_json)))
    events.send(Rod::Message.new(Rod::SessionID.new("sid-match"), payload.proto_event, JSON.parse(payload.to_json)))

    got = browser.wait_event_typed(Cdp::Browser::DownloadWillBeginEvent, Rod::SessionID.new("sid-match")).call
    got.guid.should eq("guid-s")
  end
end
