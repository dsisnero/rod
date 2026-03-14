require "./spec_helper"
require "http/server"
require "http/web_socket"

private class StubWebSocket < Rod::Util::Cdp::WebSocket
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

private def with_ws_echo_server(&)
  server = HTTP::Server.new([
    HTTP::WebSocketHandler.new do |ws, _ctx|
      ws.on_message { |msg| ws.send(msg) }
    end,
  ])

  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }

  begin
    yield "ws://127.0.0.1:#{addr.port}/"
  ensure
    server.close
  end
end

describe Rod::Util::Examples::CompareChromedpProxy::Transport do
  it "raises header value when X-Failed is present" do
    transport = Rod::Util::Examples::CompareChromedpProxy::Transport.new do |_request|
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
    transport = Rod::Util::Examples::CompareChromedpProxy::Transport.new do |request|
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

describe Rod::Util::Examples::CustomWebsocket::WebSocket do
  it "new_web_socket connects through cdp websocket and roundtrips data" do
    with_ws_echo_server do |url|
      socket = Rod::Util::Examples::CustomWebsocket::WebSocket.new_web_socket(url)

      socket.send("ping".to_slice)
      String.new(socket.read).should eq("ping")
    end
  end

  it "delegates send and read to underlying cdp websocket" do
    conn = StubWebSocket.new
    socket = Rod::Util::Examples::CustomWebsocket::WebSocket.new(conn)
    payload = "client-text".to_slice

    socket.send(payload)
    data = socket.read

    conn.last_sent.should_not be_nil
    String.new(conn.last_sent.not_nil!).should eq("client-text")
    String.new(data).should eq("server-text")
  end
end
