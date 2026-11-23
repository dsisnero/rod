require "../../src/rod"

# Ported from `vendor/rod/lib/examples/custom-websocket/main.go`: the CDP client
# takes any `Rod::Util::Cdp::WebSocketable`, so a different websocket library can
# be used as the transport. This version uses Crystal's `HTTP::WebSocket`; the
# default `Rod::Util::Cdp::WebSocket` is a hand-rolled client.
class StdlibWebSocket
  include Rod::Util::Cdp::WebSocketable

  def initialize(url : String)
    @messages = Channel(Bytes).new(64)
    @ws = HTTP::WebSocket.new(URI.parse(url))
    @ws.on_message { |message| @messages.send(message.to_slice) }
    spawn { @ws.run }
  end

  def send(msg : Bytes) : Nil
    @ws.send(String.new(msg))
  end

  def read : Bytes
    @messages.receive
  end
end

launcher = Rod::Util::Launcher.new
url = launcher.launch

begin
  ws = StdlibWebSocket.new(url)
  client = Rod::Util::Cdp::Client.new.start(ws)
  page = Rod::Browser.new.client(client).connect!.page!("http://example.com")
  puts page.info!.title
ensure
  launcher.cleanup
end
