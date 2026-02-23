# URL parser for extracting WebSocket URL from browser output
module Rod::Lib
  class URLParser < IO
    property url : Channel(String)
    property buffer : String
    property? done : Bool
    @lock : Mutex
    @ctx : Channel(Nil)? = nil # Simplified context

    # Regular expression to match WebSocket URL in browser output
    WS_REGEX = /ws:\/\/.+\//

    def initialize
      super()
      @url = Channel(String).new(1)
      @buffer = ""
      @done = false
      @lock = Mutex.new
    end

    # Abstract IO methods
    def read(slice : Bytes) : Int32
      # Not used for writing only
      0
    end

    def flush : Nil
      # Nothing to flush
    end

    # Write interface for IO
    def write(slice : Bytes) : Nil
      @lock.synchronize do
        return if done?

        @buffer += String.new(slice)

        if match = @buffer.match(WS_REGEX)
          ws_url = match[0].strip

          # Send URL to channel
          begin
            @url.send(ws_url)
          rescue Channel::ClosedError
            # Channel closed, ignore
          end

          @done = true
          @buffer = ""
        end
      end
    end

    # Close the parser
    def close : Nil
      super
      @url.close
    end

    # Get error message from buffer
    def error : String?
      @lock.synchronize do
        if @buffer.includes?("error while loading shared libraries")
          return "[launcher] Failed to launch the browser, the doc might help https://go-rod.github.io/#/compatibility?id=os: #{@buffer}"
        end

        return "[launcher] Failed to get the debug url: #{@buffer}" unless @buffer.empty?
      end
      nil
    end

    # Resolve URL by requesting the JSON version endpoint
    def self.resolve_url(url : String) : String
      url = url.strip
      url = "9222" if url.empty?

      # Normalize port format
      if url =~ /^:?(\d+)$/
        url = "127.0.0.1:#{$1}"
      end

      # Ensure protocol
      unless url =~ /^\w+:\/\//
        url = "http://#{url}"
      end

      # Parse URL
      uri = URI.parse(url)

      # Ensure HTTP scheme
      uri.scheme = "http" if uri.scheme.in?("ws", "wss")

      # Path to JSON version endpoint
      uri.path = "/json/version"

      # Make HTTP request
      client = HTTP::Client.new(uri)
      response = client.get(uri.request_target)

      unless response.success?
        raise "Failed to fetch browser debug info: HTTP #{response.status_code}"
      end

      # Parse JSON response
      json = JSON.parse(response.body)
      ws_url = json["webSocketDebuggerUrl"].as_s

      # Replace host with original host (in case of port forwarding)
      ws_uri = URI.parse(ws_url)
      ws_uri.host = uri.host
      ws_uri.port = uri.port

      ws_uri.to_s
    rescue ex
      raise "Failed to resolve debug URL: #{ex.message}"
    end

    # MustResolveURL variant that raises on error
    def self.must_resolve_url(url : String) : String
      resolve_url(url)
    end
  end
end
