require "./spec_helper"

private class WaitDownloadBrowser < Rod::Browser
  getter methods = [] of String
  getter params = [] of JSON::Any

  def initialize(@messages : Channel(Rod::Message))
    super()
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, payload : JSON::Any) : Bytes
    @methods << method
    @params << payload
    %({}).to_slice
  end

  def event : Channel(Rod::Message)
    @messages
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end
end

private class CancelWaitDownloadBrowser < Rod::Browser
  getter methods = [] of String
  getter params = [] of JSON::Any

  def initialize
    ctx, cancel = Rod::Context.background.with_cancel
    cancel.call
    super(ctx)
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, payload : JSON::Any) : Bytes
    @methods << method
    @params << payload
    %({}).to_slice
  end

  def event : Channel(Rod::Message)
    Channel(Rod::Message).new
  end

  def with_cancel : Tuple(Rod::Browser, Proc(Nil))
    {self, -> { nil }}
  end
end

describe "browser wait_download parity" do
  it "returns DownloadWillBegin event after matching completed progress and restores behavior" do
    events = Channel(Rod::Message).new(2)

    start = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-1",
      guid: "guid-1",
      url: "https://example.test/file",
      suggested_filename: "file.txt"
    )

    done = Cdp::Browser::DownloadProgressEvent.new(
      guid: "guid-1",
      total_bytes: 100.0,
      received_bytes: 100.0,
      state: Cdp::Browser::DownloadProgressStateCompleted,
      file_path: "/tmp/downloads/guid-1"
    )

    events.send(Rod::Message.new(nil, start.proto_event, JSON.parse(start.to_json)))
    events.send(Rod::Message.new(nil, done.proto_event, JSON.parse(done.to_json)))

    browser = WaitDownloadBrowser.new(events)
    wait = browser.wait_download("/tmp/downloads")
    result = wait.call

    result.should_not be_nil
    result.not_nil!.guid.should eq("guid-1")

    indices = browser.methods.each_index.select { |i| browser.methods[i] == "Browser.setDownloadBehavior" }.to_a
    indices.size.should eq(2)

    first = browser.params[indices[0]]
    second = browser.params[indices[1]]

    first["behavior"].as_s.should eq("allowAndName")
    first["downloadPath"].as_s.should eq("/tmp/downloads")
    second["behavior"].as_s.should eq("default")
  end

  it "returns nil when context is already canceled (Go TestWaitDownloadCancel parity)" do
    browser = CancelWaitDownloadBrowser.new
    wait = browser.wait_download("/tmp/downloads")

    wait.call.should be_nil
    browser.methods.count("Browser.setDownloadBehavior").should eq(2)
  end

  it "captures data-uri initiated downloads by guid completion" do
    events = Channel(Rod::Message).new(2)
    start = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "frame-data",
      guid: "guid-data",
      url: "data:text/plain;,test%20data",
      suggested_filename: "download.txt"
    )
    done = Cdp::Browser::DownloadProgressEvent.new(
      guid: "guid-data",
      total_bytes: 9.0,
      received_bytes: 9.0,
      state: Cdp::Browser::DownloadProgressStateCompleted,
      file_path: "/tmp/downloads/guid-data"
    )
    events.send(Rod::Message.new(nil, start.proto_event, JSON.parse(start.to_json)))
    events.send(Rod::Message.new(nil, done.proto_event, JSON.parse(done.to_json)))

    browser = WaitDownloadBrowser.new(events)
    result = browser.wait_download("/tmp/downloads").call

    result.should_not be_nil
    result.not_nil!.url.should eq("data:text/plain;,test%20data")
    result.not_nil!.suggested_filename.should eq("download.txt")
  end

  it "captures completed downloads regardless of originating page/frame" do
    events = Channel(Rod::Message).new(2)
    start = Cdp::Browser::DownloadWillBeginEvent.new(
      frame_id: "new-page-frame",
      guid: "guid-new-page",
      url: "https://example.test/from-new-page.bin",
      suggested_filename: "from-new-page.bin"
    )
    done = Cdp::Browser::DownloadProgressEvent.new(
      guid: "guid-new-page",
      total_bytes: 100.0,
      received_bytes: 100.0,
      state: Cdp::Browser::DownloadProgressStateCompleted,
      file_path: "/tmp/downloads/guid-new-page"
    )
    events.send(Rod::Message.new(nil, start.proto_event, JSON.parse(start.to_json)))
    events.send(Rod::Message.new(nil, done.proto_event, JSON.parse(done.to_json)))

    browser = WaitDownloadBrowser.new(events)
    result = browser.wait_download("/tmp/downloads").call

    result.should_not be_nil
    result.not_nil!.guid.should eq("guid-new-page")
    result.not_nil!.frame_id.should eq("new-page-frame")
  end
end
