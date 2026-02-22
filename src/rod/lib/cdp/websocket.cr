require "http/web_socket"

module Rod::Lib::Cdp
  # WebSocket client for chromium. It only implements a subset of WebSocket protocol.
  # Both the Read and Write are thread-safe.
  class WebSocket
    @ws : HTTP::WebSocket?
    @lock = Mutex.new

    # Connect to browser.
    def connect(ws_url : String, headers : HTTP::Headers = HTTP::Headers.new) : Nil
      @lock.synchronize do
        if @ws
          raise "duplicated connection: #{ws_url}"
        end
        @ws = HTTP::WebSocket.new(ws_url, headers)
      end
    end

    # Close the underlying connection.
    def close : Nil
      @lock.synchronize do
        @ws.try &.close
      end
    end

    # Send a message to browser.
    def send(data : Bytes) : Nil
      @lock.synchronize do
        ws = @ws
        raise "not connected" unless ws
        ws.send(String.new(data))
      end
    end

    # Read returns text message only.
    def read : Bytes
      @lock.synchronize do
        ws = @ws
        raise "not connected" unless ws
        message = ws.receive
        case message
        when HTTP::WebSocket::Text
          message.data.to_slice
        when HTTP::WebSocket::Binary
          message.data
        when HTTP::WebSocket::Close
          raise "websocket closed"
        when HTTP::WebSocket::Ping, HTTP::WebSocket::Pong
          # Ignore and read next
          read
        else
          raise "unexpected message type: #{message.class}"
        end
      end
    end
  end
end
