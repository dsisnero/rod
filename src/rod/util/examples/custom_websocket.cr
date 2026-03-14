module Rod::Util::Examples::CustomWebsocket
  # WebSocket is a custom transport adapter for CDP client examples.
  class WebSocket
    include ::Rod::Util::Cdp::WebSocketable

    @conn : ::Rod::Util::Cdp::WebSocket

    def initialize(@conn : ::Rod::Util::Cdp::WebSocket)
    end

    # NewWebSocket creates a websocket connection for custom transport usage.
    def self.new_web_socket(url : String) : self
      conn = ::Rod::Util::Cdp::WebSocket.new
      conn.connect(url)
      new(conn)
    end

    # Send writes a text message payload.
    def send(msg : Bytes) : Nil
      @conn.send(msg)
    end

    # Read reads a text message payload.
    def read : Bytes
      @conn.read
    end
  end
end
