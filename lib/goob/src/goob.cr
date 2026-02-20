# Minimal port of github.com/ysmood/goob - observable pattern
module Goob
  VERSION = "0.1.0"

  # Observable hub
  class Observable(Event)
    @ctx : Channel(Nil)?
    @lock : Mutex = Mutex.new
    @subscribers : Array(Channel(Event)) = [] of Channel(Event)

    # New observable instance
    def initialize(@ctx : Channel(Nil)? = nil)
    end

    # Publish message to the queue
    def publish(e : Event)
      @lock.synchronize do
        @subscribers.each do |ch|
          begin
            ch.send(e)
          rescue
            # Channel closed, ignore
          end
        end
      end
    end

    # Subscribe message
    def subscribe(ctx : Channel(Nil)? = nil) : Channel(Event)
      ch = Channel(Event).new
      @lock.synchronize do
        @subscribers << ch
      end

      spawn do
        select
        when ctx.try &.receive?
        when @ctx.try &.receive?
        end
        @lock.synchronize do
          @subscribers.delete(ch)
        end
      end

      ch
    end

    # Len of the subscribers
    def len : Int32
      @lock.synchronize do
        @subscribers.size
      end
    end
  end
end
