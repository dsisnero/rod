require "./cdp/websocket"
require "./cdp/client"
require "http/headers"

module Rod::Util::Cdp
  # MustConnectWS helper to make a websocket connection.
  def self.must_connect_ws(ws_url : String, headers : HTTP::Headers = HTTP::Headers.new) : WebSocket
    ws = WebSocket.new
    ws.connect(ws_url, headers)
    ws
  end

  # StartWithURL helper to connect with the default websocket implementation.
  def self.start_with_url(url : String, headers : HTTP::Headers = HTTP::Headers.new) : Client
    raise "empty websocket url" if url.empty?
    Client.new.start(must_connect_ws(url, headers))
  end

  # MustStartWithURL helper for start_with_url.
  def self.must_start_with_url(url : String, headers : HTTP::Headers = HTTP::Headers.new) : Client
    start_with_url(url, headers)
  end
end
