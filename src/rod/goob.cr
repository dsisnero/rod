require "channel"

module Goob
  # Pipe buffers events between writer and reader.
  private class Pipe(T)
    @buffer = [] of T
    @lock = Mutex.new
    @wait = Channel(Nil).new(1)
    @events = Channel(T).new
    @done = Channel(Nil).new

    # Create a new pipe.
    def initialize(@done : Channel(Nil))
      spawn run_loop
    end

    # Write an event to the pipe (non-blocking).
    def write(event : T) : Nil
      @lock.synchronize do
        @buffer << event
        # Signal if wait channel is empty
        if @wait.empty?
          select
          when @wait.send(nil)
          when @done.receive
            # Done signaled, discard
          end
        end
      end
    end

    # Events channel for reading.
    def events : Channel(T)
      @events
    end

    # Close the pipe.
    def close : Nil
      @events.close
      @done.close
      @wait.close
    end

    private def run_loop : Nil
      loop do
        # Wait for signal or done
        select
        when @wait.receive
          # Process buffer
          buf = @lock.synchronize do
            tmp = @buffer
            @buffer = [] of T
            tmp
          end
          buf.each do |event|
            select
            when @events.send(event)
            when @done.receive
              return
            end
          end
        when @done.receive
          return
        end
      end
    end
  end

  # Observable hub for event subscription
  class Observable(T)
    @subscribers = {} of Pipe(T) => Proc(T, Nil)
    @lock = Mutex.new
    @done : Channel(Nil)

    # Create a new Observable instance.
    # The done channel signals when to stop.
    def initialize(@done : Channel(Nil))
    end

    # Subscribe to events.
    # Returns a Channel that will receive published events.
    # The subscription will be closed when the done channel is closed.
    def subscribe(done : Channel(Nil)) : Channel(T)
      @lock.synchronize do
        pipe = Pipe(T).new(done)
        @subscribers[pipe] = ->(e : T) { pipe.write(e) }

        # Cleanup when done
        spawn do
          done.receive
          @lock.synchronize do
            @subscribers.delete(pipe)
            pipe.close
          end
        end

        pipe.events
      end
    end

    # Publish an event to all subscribers.
    def publish(event : T) : Nil
      @lock.synchronize do
        @subscribers.each_value do |write|
          write.call(event)
        end
      end
    end

    # Number of active subscribers.
    def size : Int32
      @lock.synchronize { @subscribers.size }
    end
  end
end
