require "./spec_helper"
require "base64"
require "digest/sha1"
require "http/server"
require "http/web_socket"
require "socket"

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

private def with_raw_ws_frame_server(frame : Bytes, &)
  server = TCPServer.new("127.0.0.1", 0)
  addr = server.local_address.as(Socket::IPAddress)
  done = Channel(Nil).new(1)

  spawn do
    socket = server.accept?
    begin
      if socket
        sec_key = "nil"
        while line = socket.gets("\n")
          break if line == "\r\n"
          if line.starts_with?("Sec-WebSocket-Key:")
            sec_key = line.split(":", 2)[1].strip
          end
        end

        accept = Base64.strict_encode(Digest::SHA1.digest("#{sec_key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))
        response = "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: #{accept}\r\n\r\n"
        socket << response
        socket.write(frame)
        socket.flush
      end
    ensure
      socket.try &.close
      done.send(nil)
    end
  end

  begin
    yield "ws://127.0.0.1:#{addr.port}/"
  ensure
    server.close
    done.receive?
  end
end

describe "cdp websocket parity" do
  it "forwards custom headers and reports bad websocket handshake" do
    seen = Channel(HTTP::Request).new(1)
    server = HTTP::Server.new do |ctx|
      seen.send(ctx.request)
      ctx.response.status_code = 200
      ctx.response.print("ok")
    end

    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      ws = Rod::Lib::Cdp::WebSocket.new
      headers = HTTP::Headers{
        "Host" => "test.com",
        "Test" => "header",
      }

      expect_raises(Exception, /handshake|Handshake|websocket/i) do
        ws.connect("ws://127.0.0.1:#{addr.port}/a?q=ok", headers)
      end

      req = seen.receive
      req.headers["Test"].should eq("header")
      req.path.should eq("/a")
      req.query.should eq("q=ok")
    ensure
      server.close
    end
  end

  it "raises on invalid websocket URL" do
    ws = Rod::Lib::Cdp::WebSocket.new
    expect_raises(Exception) { ws.connect("://") }
  end

  it "raises when send/read called before connect" do
    ws = Rod::Lib::Cdp::WebSocket.new

    expect_raises(Exception, /not connected/) { ws.send("x".to_slice) }
    expect_raises(Exception, /not connected/) { ws.read }
  end

  it "connects, roundtrips messages, and rejects duplicated connect" do
    with_ws_echo_server do |url|
      ws = Rod::Lib::Cdp::WebSocket.new
      ws.connect(url)

      ws.send("ping".to_slice)
      String.new(ws.read).should eq("ping")

      expect_raises(Exception, /duplicated connection/) { ws.connect(url) }

      ws.close
      expect_raises(Exception, /not connected|websocket closed/) { ws.read }
    end
  end

  it "roundtrips large payloads" do
    with_ws_echo_server do |url|
      ws = Rod::Lib::Cdp::WebSocket.new
      ws.connect(url)

      size = 2 * 1024 * 1024
      payload = "a" * size
      ws.send(payload.to_slice)
      echoed = String.new(ws.read)

      echoed.size.should eq(size)
      echoed.should eq(payload)
      ws.close
    end
  end

  it "uses tls dialer for wss URLs and surfaces tls dialer errors" do
    ws = Rod::Lib::Cdp::WebSocket.new
    expect_raises(Exception) { ws.connect("wss://no-exist") }
    ws.dialer.should be_a(Rod::Lib::Cdp::TlsDialer)

    tls = Rod::Lib::Cdp::TlsDialer.new
    expect_raises(Exception) { tls.dial(URI.parse("wss://")) }
  end

  it "raises on malformed websocket frames from server" do
    with_raw_ws_frame_server(Bytes[0_u8, 127_u8, 1_u8]) do |url|
      ws = Rod::Lib::Cdp::WebSocket.new
      ws.connect(url)
      expect_raises(Exception) { ws.read }
    end

    with_raw_ws_frame_server(Bytes[0_u8]) do |url|
      ws = Rod::Lib::Cdp::WebSocket.new
      ws.connect(url)
      expect_raises(Exception) { ws.read }
    end
  end
end
