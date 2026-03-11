require "./spec_helper"

private class MacroEachEventStubBrowser < Rod::Browser
  getter methods = [] of String
  property captured_sid : Rod::SessionID? = nil

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

  def macro_wait_one : Proc(Nil)
    eachevent(
      ->(event : Cdp::Browser::DownloadWillBeginEvent) { event.guid == "guid-1" }
    )
  end

  def macro_wait_two : Proc(Nil)
    eachevent(
      ->(event : Cdp::Browser::DownloadWillBeginEvent, sid : Rod::SessionID?) do
        @captured_sid = sid
        event.guid == "guid-2"
      end
    )
  end
end

describe "browser eachevent macro parity" do
  it "accepts proc literals with one argument" do
    events = Channel(Rod::Message).new(1)
    browser = MacroEachEventStubBrowser.new(events)

    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-1",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )
    events.send(Rod::Message.new(nil, payload.proto_event, JSON.parse(payload.to_json)))

    browser.macro_wait_one.call
  end

  it "accepts proc literals with two arguments" do
    events = Channel(Rod::Message).new(1)
    browser = MacroEachEventStubBrowser.new(events)

    payload = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-2",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )
    events.send(Rod::Message.new(Rod::SessionID.new("sid-2"), payload.proto_event, JSON.parse(payload.to_json)))

    browser.macro_wait_two.call
    browser.captured_sid.should eq(Rod::SessionID.new("sid-2"))
  end
end
