require "json"
require "channel"
require "../../../cdp/cdp"

module Rod::Lib::Cdp
  # Request to send to browser.
  struct Request
    include JSON::Serializable
    property id : Int32
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : String?
    property method : String
    property params : JSON::Any?

    def initialize(@id, @method, @params = nil, @session_id = nil)
    end

    def to_s : String
      sid = (@session_id || "").ljust(8, ' ')[0, 8].gsub(' ', '0')
      body = @params ? @params.to_json : "null"
      "=> ##{@id} @#{sid} #{@method} #{body}"
    end
  end

  # Response from browser.
  struct Response
    include JSON::Serializable
    property id : Int32
    property result : JSON::Any?
    property error : Error?

    def initialize(@id, @result = nil, @error = nil)
    end

    def to_s : String
      if err = @error
        "<= ##{@id} error: #{err.to_json}"
      else
        body = @result ? @result.to_json : "null"
        "<= ##{@id} #{body}"
      end
    end
  end

  # Event from browser.
  struct Event
    include JSON::Serializable
    @[JSON::Field(key: "sessionId", emit_null: false)]
    property session_id : String?
    property method : String
    property params : JSON::Any?

    def initialize(@method, @params = nil, @session_id = nil)
    end

    def to_s : String
      sid = (@session_id || "").ljust(8, ' ')[0, 8].gsub(' ', '0')
      body = @params ? @params.to_json : "null"
      "<- @#{sid} #{@method} #{body}"
    end
  end

  # Error from browser.
  struct Error
    include JSON::Serializable
    property code : Int32
    property message : String
    @[JSON::Field(emit_null: false)]
    property data : JSON::Any?

    def initialize(@code, @message, @data = JSON::Any.new(""))
    end

    def to_s : String
      data_str = begin
        raw = @data.try(&.raw)
        if raw.nil?
          ""
        elsif raw.is_a?(String)
          raw.as(String)
        else
          data = @data
          data ? data.to_json : ""
        end
      end
      "{#{code} #{message} #{data_str}}"
    end

    def is?(other : Error) : Bool
      code == other.code && message == other.message && data == other.data
    end
  end

  # Client is a devtools protocol connection instance.
  class Client < ::Cdp::Client
    @count = Atomic(Int32).new(0)
    @pending = {} of Int32 => Channel(Result)
    @pending_lock = Mutex.new
    @event_channel = Channel(Event).new(1024)
    @ws : WebSocketable?
    @logger : ::Log?

    # New creates a cdp connection, all messages from Client.event must be received or they will block the client.
    def initialize(@logger : ::Log? = nil)
    end

    # Logger sets logger and returns self for fluent chaining.
    def logger(logger : ::Log?) : self
      @logger = logger
      self
    end

    # Start to browser.
    def start(ws : WebSocketable) : self
      @ws = ws
      spawn consume_messages
      self
    end

    # Call a method and wait for its response.
    def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
      ws = @ws
      raise "not started" unless ws

      id = @count.add(1)
      req = Request.new(id, method, params, session_id)

      @logger.try &.info { "CDP request: #{req.to_json}" }

      data = req.to_json.to_slice

      done = Channel(Result).new(1)
      @pending_lock.synchronize do
        @pending[id] = done
      end

      begin
        ws.send(data)
      rescue ex
        @pending_lock.synchronize { @pending.delete(id) }
        raise ex
      end

      if ctx = context.as?(Rod::Context)
        select
        when result = done.receive
          @pending_lock.synchronize { @pending.delete(id) }
          if result.error
            raise result.error.to_s
          else
            result.msg.to_json.to_slice
          end
        when ctx.done.receive?
          @pending_lock.synchronize { @pending.delete(id) }
          raise(ctx.err || Rod::ContextCanceledError.new("context cancelled"))
        end
      else
        result = done.receive
        @pending_lock.synchronize { @pending.delete(id) }
        if result.error
          raise result.error.to_s
        else
          result.msg.to_json.to_slice
        end
      end
    end

    # Event returns a channel that will emit browser devtools protocol events. Must be consumed or will block producer.
    def event : Channel(Event)
      @event_channel
    end

    # Consume messages coming from the browser via the websocket.
    private def consume_messages
      ws = @ws
      return unless ws
      loop do
        data = ws.read
        envelope = MessageEnvelope.from_json(String.new(data))

        id = envelope.id
        if id.nil?
          # Event
          evt = Event.new(
            method: envelope.method || "",
            params: envelope.params,
            session_id: envelope.session_id
          )
          @logger.try &.info { "CDP event: #{evt.to_json}" }
          @event_channel.send(evt)
          next
        end

        # Response
        res = Response.new(id, envelope.result, envelope.error)
        @logger.try &.info { "CDP response: #{res.to_json}" }

        @pending_lock.synchronize do
          if channel = @pending[id]?
            channel.send(Result.new(res.result, res.error))
          end
        end
      rescue ex
        # Handle error: notify all pending requests
        @pending_lock.synchronize do
          @pending.each_value do |channel|
            channel.send(Result.new(nil, Error.new(0, ex.message.to_s)))
          end
          @pending.clear
        end
        @event_channel.close
        break
      end
    end

    private struct Result
      property msg : JSON::Any?
      property error : Error?

      def initialize(@msg = nil, @error = nil)
      end
    end

    private struct MessageEnvelope
      include JSON::Serializable

      property id : Int32?
      property method : String?
      property params : JSON::Any?
      property result : JSON::Any?
      property error : Error?
      @[JSON::Field(key: "sessionId", emit_null: false)]
      property session_id : String?
    end
  end
end
