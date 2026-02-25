require "../cdp/cdp"
require "../cdp/fetch/fetch"
require "../cdp/network/network"
require "http/client"
require "uri"
require "regex"
require "json"

module Rod
  # Forward declaration
  class Browser < ::Cdp::Client
  end

  # HijackRouter context.
  class HijackRouter
    @run : -> Nil
    @stop : -> Nil
    @handlers : Array(HijackHandler)
    @enable : Cdp::Fetch::Enable
    @client : Cdp::Client
    @browser : Browser

    # Creates a new hijack router.
    def initialize(@browser : Browser, @client : Cdp::Client)
      @enable = Cdp::Fetch::Enable.new
      @handlers = [] of HijackHandler
      @run = -> { }
      @stop = -> { }
    end

    # Initializes event listeners.
    def init_events : self
      ctx = @browser.ctx
      if @client.responds_to?(:get_context)
        ctx = @client.get_context
      end

      session_id = nil
      if @client.responds_to?(:get_session_id)
        session_id = @client.get_session_id
      end

      event_ctx, cancel = ctx.with_cancel
      @stop = cancel

      @enable.call(@client)

      # Create callback for Fetch.requestPaused events
      callback = ->(event : Cdp::Event, sid : SessionID?) do
        e = event.as(Cdp::Fetch::RequestPausedEvent)
        spawn do
          hijack = new(event_ctx, e)
          @handlers.each do |h|
            next unless h.regex.match(e.request.url)

            h.handler.call(hijack)

            if cont = hijack.continue_request
              cont.request_id = e.request_id
              begin
                cont.call(@client)
              rescue err
                hijack.on_error.call(err)
              end
              return
            end

            if hijack.skip
              next
            end

            if hijack.response.fail.error_reason != ""
              begin
                hijack.response.fail.call(@client)
              rescue err
                hijack.on_error.call(err)
              end
              return
            end

            begin
              hijack.response.payload.call(@client)
            rescue err
              hijack.on_error.call(err)
            end
          end
        end
        nil # Return nil (don't stop listening)
      end

      # Get the run function from browser.each_event
      # This function will block and process events until context is cancelled
      browser_with_ctx = @browser.context(event_ctx)
      @run = browser_with_ctx.each_event(
        session_id,
        {"Fetch.requestPaused" => Browser::CallbackInfo.new(
          Cdp::Fetch::RequestPausedEvent,
          callback
        )}
      )

      self
    end

    # Add a hijack handler to router, the doc of the pattern is the same as "Cdp::Fetch::RequestPattern.url_pattern".
    def add(pattern : String, resource_type : Cdp::Network::ResourceType, handler : Hijack -> Nil) : Nil
      @enable.patterns ||= [] of Cdp::Fetch::RequestPattern
      @enable.patterns << Cdp::Fetch::RequestPattern.new(
        url_pattern: pattern,
        resource_type: resource_type
      )

      reg = Regex.new(proto_pattern_to_reg(pattern))

      @handlers << HijackHandler.new(
        pattern: pattern,
        regex: reg,
        handler: handler
      )

      @enable.call(@client)
    end

    # Remove handler via the pattern.
    def remove(pattern : String) : Nil
      patterns = [] of Cdp::Fetch::RequestPattern
      handlers = [] of HijackHandler
      @handlers.each do |h|
        if h.pattern != pattern
          patterns << Cdp::Fetch::RequestPattern.new(url_pattern: h.pattern)
          handlers << h
        end
      end
      @enable.patterns = patterns
      @handlers = handlers
      @enable.call(@client)
    end

    # Creates a new hijack context.
    private def new(ctx : Context, e : Cdp::Fetch::RequestPaused) : Hijack
      headers = HTTP::Headers.new
      e.request.headers.each do |k, v|
        headers[k] = v.to_s
      end

      u = URI.parse(e.request.url)

      req = HTTP::Request.new(
        method: e.request.method,
        uri: u,
        body: e.request.post_data || "",
        headers: headers
      )

      Hijack.new(
        request: HijackRequest.new(event: e, req: req),
        response: HijackResponse.new(
          payload: Cdp::Fetch::FulfillRequest.new(
            response_code: 200,
            request_id: e.request_id
          ),
          fail: Cdp::Fetch::FailRequest.new(
            request_id: e.request_id
          )
        ),
        on_error: ->(_err : Exception) { },
        browser: @browser
      )
    end

    # Run the router, after you call it, you shouldn't add new handler to it.
    def run : Nil
      @run.call
    end

    # Stop the router.
    def stop : Nil
      @stop.call
      Cdp::Fetch::Disable.new.call(@client)
    end
  end

  # hijackHandler to handle each request that match the regex.
  private class HijackHandler
    getter pattern : String
    getter regex : Regex
    getter handler : Hijack -> Nil

    def initialize(@pattern : String, @regex : Regex, @handler : Hijack -> Nil)
    end
  end

  # Hijack context.
  class Hijack
    property request : HijackRequest
    property response : HijackResponse
    property on_error : Exception -> Nil
    property skip = false
    property custom_state : JSON::Any?

    @continue_request : Cdp::Fetch::ContinueRequest?
    @browser : Browser

    def initialize(@request : HijackRequest, @response : HijackResponse, @on_error : Exception -> Nil, @browser : Browser)
    end

    def continue_request : Cdp::Fetch::ContinueRequest?
      @continue_request
    end

    # ContinueRequest without hijacking. The RequestID will be set by the router, you don't have to set it.
    def continue_request(cq : Cdp::Fetch::ContinueRequest) : Nil
      @continue_request = cq
    end

    # LoadResponse will send request to the real destination and load the response as default response to override.
    def load_response(client : HTTP::Client, load_body : Bool) : Nil
      res = client.exec(request.req)
      response.raw_response = res
      response.payload.response_code = res.status.code

      res.headers.each do |k, vs|
        vs.each do |v|
          response.set_header(k, v)
        end
      end

      if load_body
        response.payload.body = res.body.to_slice
      end
    rescue err
      raise err
    ensure
      res.try(&.close)
    end
  end

  # HijackRequest context.
  class HijackRequest
    @event : Cdp::Fetch::RequestPausedEvent
    @req : HTTP::Request

    def initialize(@event : Cdp::Fetch::RequestPausedEvent, @req : HTTP::Request)
    end

    # Type of the resource.
    def type : Cdp::Network::ResourceType
      @event.resource_type
    end

    # Method of the request.
    def method : String
      @event.request.method
    end

    # URL of the request.
    def url : URI
      URI.parse(@event.request.url)
    end

    # Header via a key.
    def header(key : String) : String
      @event.request.headers[key]?.try(&.to_s) || ""
    end

    # Headers of request.
    def headers : Cdp::Network::Headers
      @event.request.headers
    end

    # Body of the request, devtools API doesn't support binary data yet, only string can be captured.
    def body : String
      @event.request.post_data || ""
    end

    # JSONBody of the request.
    def json_body : JSON::Any
      JSON.parse(body)
    end

    # Returns the underlying HTTP::Request instance that will be used to send the request.
    def req : HTTP::Request
      @req
    end

    # SetContext of the underlying HTTP::Request instance.
    def set_context(c : Context) : self
      # Crystal HTTP::Request doesn't have context, we can store it in custom field
      self
    end

    # SetBody of the request, if obj is Bytes or String, raw body will be used, else it will be encoded as json.
    def set_body(obj : Bytes | String | JSON::Any) : self
      case obj
      when Bytes
        @req.body = obj
      when String
        @req.body = obj.to_slice
      else
        @req.body = obj.to_json.to_slice
      end
      self
    end

    # IsNavigation determines whether the request is a navigation request.
    def navigation? : Bool
      type == Cdp::Network::ResourceType::Document
    end
  end

  # HijackResponse context.
  class HijackResponse
    property payload : Cdp::Fetch::FulfillRequest
    property raw_response : HTTP::Client::Response?
    property fail : Cdp::Fetch::FailRequest

    def initialize(@payload : Cdp::Fetch::FulfillRequest, @fail : Cdp::Fetch::FailRequest)
    end

    # Body of the payload.
    def body : String
      String.new(payload.body)
    end

    # Headers returns the clone of response headers.
    def headers : HTTP::Headers
      headers = HTTP::Headers.new
      payload.response_headers.each do |h|
        headers.add(h.name, h.value)
      end
      headers
    end

    # SetHeader of the payload via key-value pairs.
    def set_header(pairs : String*) : self
      # Build index of existing headers
      header_index = {} of String => Int32
      payload.response_headers.each_with_index do |header, idx|
        header_index[header.name] = idx
      end

      i = 0
      while i < pairs.size
        name = pairs[i]
        value = pairs[i + 1]

        if idx = header_index[name]?
          # Update existing header
          payload.response_headers[idx].value = value
        else
          # Add new header
          payload.response_headers << Cdp::Fetch::HeaderEntry.new(name: name, value: value)
          header_index[name] = payload.response_headers.size - 1
        end

        i += 2
      end

      self
    end

    # AddHeader appends key-value pairs to the end of the response headers.
    def add_header(pairs : String*) : self
      i = 0
      while i < pairs.size
        name = pairs[i]
        value = pairs[i + 1]
        payload.response_headers << Cdp::Fetch::HeaderEntry.new(name: name, value: value)
        i += 2
      end

      self
    end

    # SetBody of the payload, if obj is Bytes or String, raw body will be used, else it will be encoded as json.
    def set_body(obj : Bytes | String | JSON::Any) : self
      case obj
      when Bytes
        payload.body = obj
      when String
        payload.body = obj.to_slice
      else
        payload.body = must_to_json_bytes(obj)
      end
      self
    end

    # Fail request.
    def fail(reason : Cdp::Network::ErrorReason) : self
      @fail.error_reason = reason
      self
    end
  end

  # PatternToReg converts a URL pattern to a regex string.
  # Ported from Go's a_utils.go PatternToReg.
  private def proto_pattern_to_reg(pattern : String) : String
    return "" if pattern.empty?

    # Prepend a space to make regex replacements easier
    pattern = " " + pattern

    # Replace unescaped * with .* and unescaped ? with .
    result = String.build do |str|
      i = 0
      while i < pattern.size
        ch = pattern[i]
        if i > 0 && ch == '*' && pattern[i - 1] != '\\'
          str << ".*"
        elsif i > 0 && ch == '?' && pattern[i - 1] != '\\'
          str << '.'
        else
          str << ch
        end
        i += 1
      end
    end

    # Remove the leading space we added, then add anchors
    "\\A" + result.lstrip + "\\z"
  end

  private def must_to_json_bytes(obj) : Bytes
    obj.to_json.to_slice
  end
end
