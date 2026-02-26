require "json"
require "channel"
require "../../../cdp/cdp"

module Rod::Lib::Cdp
  # Request to send to browser.
  struct Request
    include JSON::Serializable
    property id : Int32
    property session_id : String?
    property method : String
    property params : JSON::Any?

    def initialize(@id, @method, @params = nil, @session_id = nil)
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
  end

  # Event from browser.
  struct Event
    include JSON::Serializable
    property session_id : String?
    property method : String
    property params : JSON::Any?

    def initialize(@method, @params = nil, @session_id = nil)
    end
  end

  # Error from browser.
  struct Error
    include JSON::Serializable
    property code : Int32
    property message : String

    def initialize(@code, @message)
    end

    def to_s : String
      "#{message} (#{code})"
    end
  end

  # Client is a devtools protocol connection instance.
  class Client < ::Cdp::Client
    @count = Atomic(Int32).new(0)
    @pending = {} of Int32 => Channel(Result)
    @pending_lock = Mutex.new
    @event_channel = Channel(Event).new
    @ws : WebSocket?
    @logger : ::Log?

    # New creates a cdp connection, all messages from Client.event must be received or they will block the client.
    def initialize(@logger : ::Log? = nil)
    end

    # Start to browser.
    def start(ws : WebSocket) : self
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

      select
      when result = done.receive
        @pending_lock.synchronize { @pending.delete(id) }
        if result.error
          raise result.error.to_s
        else
          result.msg.to_s.to_slice
        end
      when timeout 30.seconds
        @pending_lock.synchronize { @pending.delete(id) }
        raise "CDP call timeout"
      end
    end

    # Event returns a channel that will emit browser devtools protocol events. Must be consumed or will block producer.
    def event : Channel(Event)
      @event_channel
    end

    # Consume messages coming from the browser via the websocket.
    private def consume_messages
      ws = @ws.not_nil!
      loop do
        data = ws.read
        json = JSON.parse(String.new(data))

        id = json["id"]?.try &.as_i
        if id.nil?
          # Event
          evt = Event.from_json(json.to_json)
          @logger.try &.info { "CDP event: #{json}" }
          @event_channel.send(evt)
          next
        end

        # Response
        res = Response.from_json(json.to_json)
        @logger.try &.info { "CDP response: #{json}" }

        @pending_lock.synchronize do
          if channel = @pending[id]?
            channel.send(Result.new(res.result, res.error))
          end
        end
      rescue ex
        # Handle error: notify all pending requests
        @pending_lock.synchronize do
          @pending.each_value do |ch|
            ch.send(Result.new(nil, Error.new(0, ex.message.to_s)))
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
  end
end
