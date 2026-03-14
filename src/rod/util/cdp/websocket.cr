require "base64"
require "digest/sha1"
require "http/client/response"
require "http/headers"
require "openssl"
require "socket"
require "uri"

module Rod::Util::Cdp
  module WebSocketable
    abstract def send(msg : Bytes) : Nil
    abstract def read : Bytes
  end

  module Dialer
    abstract def dial(uri : URI) : IO
  end

  class TcpDialer
    include Dialer

    def dial(uri : URI) : IO
      host = uri.host
      port = uri.port
      raise "invalid websocket url: #{uri}" unless host && port

      TCPSocket.new(host, port)
    end
  end

  class TlsDialer
    include Dialer

    def dial(uri : URI) : IO
      dial_context(nil, uri)
    end

    # Go parity: expose a context-aware dial entrypoint even if Crystal's TLS
    # socket constructor doesn't consume the context directly.
    def dial_context(_ctx : HTTP::Client::Context?, uri : URI) : IO
      host = uri.host
      port = uri.port
      raise "invalid websocket url: #{uri}" unless host && port

      tcp = TCPSocket.new(host, port)
      OpenSSL::SSL::Socket::Client.new(tcp, sync_close: true, hostname: host)
    end
  end

  class BadHandshakeError < Exception
    getter status : String
    getter body : String

    def initialize(@status : String, @body : String)
      super("websocket bad handshake: #{@status}. #{@body}")
    end
  end

  # WebSocket client for chromium. It only implements a subset of WebSocket protocol.
  # Both the Read and Write are thread-safe.
  class WebSocket
    include WebSocketable
    property dialer : Dialer?

    @state_lock = Mutex.new
    @read_lock = Mutex.new
    @write_lock = Mutex.new
    @conn : IO?
    @reader : IO?

    # Connect to browser.
    def connect(ws_url : String, headers : HTTP::Headers = HTTP::Headers.new) : Nil
      if @conn
        raise "duplicated connection: #{ws_url}"
      end

      uri = URI.parse(ws_url)
      init_dialer(uri)

      dialer = @dialer
      raise "websocket dialer not configured" unless dialer
      io = dialer.dial(uri)

      @state_lock.synchronize do
        @conn = io
        @reader = io
      end
      handshake(uri, headers)
    end

    # Close the underlying connection.
    def close : Nil
      @state_lock.synchronize do
        @conn.try &.close
        @conn = nil
        @reader = nil
      end
    end

    # Send a message to browser.
    def send(msg : Bytes) : Nil
      send_frame(msg)
    rescue ex
      close
      raise ex
    end

    # Read returns text message only.
    def read : Bytes
      read_frame
    rescue ex
      close
      if ex.is_a?(IO::EOFError)
        raise IO::Error.new("EOF")
      elsif ex.is_a?(IO::Error)
        message = ex.message.to_s.downcase
        if message.includes?("broken pipe") ||
           message.includes?("connection reset") ||
           message.includes?("connection closed") ||
           message.includes?("bad file descriptor")
          raise IO::Error.new("websocket closed")
        end
      end
      raise ex
    end

    private def init_dialer(uri : URI) : Nil
      return if @dialer

      if uri.scheme == "wss"
        if uri.port.nil?
          uri.port = 443
        end
        @dialer = TlsDialer.new
      else
        @dialer = TcpDialer.new
      end
    end

    private def send_frame(msg : Bytes) : Nil
      conn = @state_lock.synchronize { @conn }
      raise "not connected" unless conn

      # FIN is always true, opcode is always text frame.
      header = StaticArray(UInt8, 18).new(0_u8)
      header[0] = 0b1000_0001_u8
      header[1] = 0b1000_0000_u8
      mask = StaticArray[0_u8, 1_u8, 2_u8, 3_u8]

      size = msg.size
      field_len = 0

      if size <= 125
        header[1] |= size.to_u8
      elsif size < 65_536
        header[1] |= 126_u8
        field_len = 2
      else
        header[1] |= 127_u8
        field_len = 8
      end

      i = 0
      while i < field_len
        digit = (field_len - i - 1) * 8
        header[i + 2] = ((size >> digit) & 0xff).to_u8
        i += 1
      end

      j = 0
      while j < 4
        header[i + 2 + j] = mask[j]
        j += 1
      end

      payload = Bytes.new(msg.size)
      payload.copy_from(msg)
      payload.each_index do |idx|
        payload[idx] ^= mask[idx % 4]
      end

      frame = Bytes.new(i + 6 + payload.size)
      k = 0
      while k < i + 6
        frame[k] = header[k]
        k += 1
      end
      frame[(i + 6), payload.size].copy_from(payload)

      @write_lock.synchronize do
        current = @state_lock.synchronize { @conn }
        raise "not connected" unless current
        current.write(frame)
        current.flush
      end
    end

    private def read_frame : Bytes
      reader = @state_lock.synchronize { @reader }
      raise "not connected" unless reader

      @read_lock.synchronize do
        current_reader = @state_lock.synchronize { @reader }
        raise "not connected" unless current_reader

        reader = current_reader
        raise "not connected" unless reader

        reader.read_byte

        second = reader.read_byte
        raise IO::EOFError.new unless second

        size = 0_i64
        field_len = 0

        b = second & 0x7f
        if b <= 125
          size = b
        elsif b == 126
          field_len = 2
        elsif b == 127
          field_len = 8
        end

        i = 0
        while i < field_len
          part = reader.read_byte
          raise IO::EOFError.new unless part
          size = (size << 8) + part
          i += 1
        end

        raise "invalid websocket frame size: #{size}" if size < 0 || size > Int32::MAX

        data = Bytes.new(size.to_i)
        reader.read_fully(data)
        data
      end
    end

    private def verify_websocket_accept(response_headers : HTTP::Headers, websocket_key : String) : Bool
      expected_key = websocket_key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
      expected_accept = Base64.strict_encode(Digest::SHA1.digest(expected_key))
      response_headers["Sec-WebSocket-Accept"]? == expected_accept
    end

    private def handshake(uri : URI, headers : HTTP::Headers) : Nil
      conn = @conn
      reader = @reader
      raise "not connected" unless conn && reader

      default_sec_key = "nil"
      sec_key = default_sec_key

      host_header = uri.host.to_s
      if port = uri.port
        host_header = "#{host_header}:#{port}"
      end

      request_headers = HTTP::Headers{
        "Upgrade"               => "websocket",
        "Connection"            => "Upgrade",
        "Sec-WebSocket-Key"     => default_sec_key,
        "Sec-WebSocket-Version" => "13",
        "Host"                  => host_header,
      }

      headers.each do |key, value|
        values = value.is_a?(Array(String)) ? value : [value]

        if key == "Host"
          request_headers["Host"] = values.first.to_s
        elsif key == "Sec-WebSocket-Key"
          sec_key = values.first.to_s
          request_headers["Sec-WebSocket-Key"] = values.first.to_s
        else
          request_headers[key] = values.join(", ")
        end
      end

      target = uri.request_target
      request = String.build do |io|
        io << "GET " << target << " HTTP/1.1\r\n"
        request_headers.each do |k, v|
          values = v.is_a?(Array(String)) ? v : [v]
          values.each do |value|
            io << k << ": " << value << "\r\n"
          end
        end
        io << "\r\n"
      end

      conn.write(request.to_slice)
      conn.flush

      response = HTTP::Client::Response.from_io(reader, ignore_body: true)
      status = "#{response.status_code} #{response.status_message}"

      if response.status_code != 101 || !verify_websocket_accept(response.headers, sec_key)
        body = response.body || ""
        raise BadHandshakeError.new(status, body)
      end
    end
  end
end
