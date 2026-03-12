require "./spec_helper"

private class StubWebSocket < Rod::Lib::Cdp::WebSocket
  getter connected_url : String?
  getter last_sent : Bytes?
  getter next_read : Bytes

  def initialize(@next_read : Bytes = "server-text".to_slice)
  end

  def connect(ws_url : String, headers : HTTP::Headers = HTTP::Headers.new) : Nil
    @connected_url = ws_url
  end

  def send(msg : Bytes) : Nil
    @last_sent = msg
  end

  def read : Bytes
    @next_read
  end
end

describe Rod::Lib::Examples::CompareChromedpProxy::Transport do
  it "raises header value when X-Failed is present" do
    transport = Rod::Lib::Examples::CompareChromedpProxy::Transport.new do |_request|
      raise "round tripper should not be called"
    end
    request = HTTP::Request.new("GET", "http://example.test")
    request.headers["X-Failed"] = "boom"

    expect_raises(Exception, "boom") do
      transport.round_trip(request)
    end
  end

  it "delegates to wrapped round tripper when X-Failed is absent" do
    expected = HTTP::Client::Response.new(204)
    called = false
    transport = Rod::Lib::Examples::CompareChromedpProxy::Transport.new do |request|
      called = true
      request.resource.should eq("http://example.test/test")
      expected
    end
    request = HTTP::Request.new("GET", "http://example.test/test")

    response = transport.round_trip(request)

    called.should be_true
    response.should be(expected)
  end
end

describe Rod::Lib::Examples::CustomWebsocket::WebSocket do
  it "delegates send and read to underlying cdp websocket" do
    conn = StubWebSocket.new
    socket = Rod::Lib::Examples::CustomWebsocket::WebSocket.new(conn)
    payload = "client-text".to_slice

    socket.send(payload)
    data = socket.read

    conn.last_sent.should_not be_nil
    String.new(conn.last_sent.not_nil!).should eq("client-text")
    String.new(data).should eq("server-text")
  end
end
