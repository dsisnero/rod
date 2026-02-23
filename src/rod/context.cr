require "http"
require "./error"

module Rod
  # TimeoutContextKey is a unique key for storing timeout context values.
  class TimeoutContextKey
  end

  TIMEOUT_KEY = TimeoutContextKey.new

  # TimeoutContextVal stores parent context and cancel function for timeout contexts.
  struct TimeoutContextVal
    property parent : Context
    property cancel : ->

    def initialize(@parent, @cancel)
    end
  end

  # Context provides timeout and cancellation support for rod operations.
  # Modeled after Go's context.Context but simplified for rod's needs.
  class Context < HTTP::Client::Context
    # Background context never cancelled.
    class_getter background : Context { Context.new }

    # Absolute deadline when context times out, nil if no deadline.
    property deadline : Time::Monotonic?
    @cancelled = false
    @err : Exception? = nil
    @mutex = Mutex.new
    @done = Channel(Nil).new
    @values = {} of Object => Object

    # Create a new context, optionally with a parent.
    def initialize(@parent : Context? = nil, @cancel_func : ->? = nil)
    end

    # Done returns a channel that's closed when the context is cancelled.
    def done : Channel(Nil)
      @done
    end

    # Cancel cancels the context.
    def cancel(reason : String? = nil) : Nil
      @mutex.synchronize do
        return if @cancelled
        @cancelled = true
        # Create appropriate error based on reason and deadline
        if reason
          @err = ContextCanceledError.new(reason)
        elsif deadline && deadline <= Time.monotonic
          @err = ContextTimeoutError.new(deadline - Time.monotonic)
        else
          @err = ContextCanceledError.new("context cancelled")
        end
        @done.close
        @cancel_func.try(&.call)
      end
    end

    # Check if context is cancelled.
    def cancelled? : Bool
      @mutex.synchronize { @cancelled }
    end

    # Err returns the cancellation reason if cancelled.
    def err : Exception?
      @mutex.synchronize do
        @err
      end
    end

    # DeadlineRemaining returns time remaining until deadline, nil if no deadline.
    # Returns zero or negative time if deadline has passed.
    def deadline_remaining : Time::Span?
      deadline = @deadline
      return nil unless deadline
      deadline - Time.monotonic
    end

    # TimeoutRemaining returns the minimum of given timeout and context deadline remaining.
    # If context has no deadline, returns timeout.
    def timeout_remaining(timeout : Time::Span) : Time::Span
      remaining = deadline_remaining
      return timeout unless remaining
      remaining < timeout ? remaining : timeout
    end

    # Value returns the value for key.
    def value(key : Object) : Object?
      @values[key]? || @parent.try(&.value(key))
    end

    # Set a value in the context.
    def set_value(key : Object, val : Object) : Nil
      @values[key] = val
    end

    # WithValue creates a new context with key-value pair.
    def with_value(key : Object, val : Object) : Context
      ctx = Context.new(self)
      ctx.set_value(key, val)
      ctx
    end

    # WithTimeout creates a new context with timeout.
    # Returns the new context and a cancel function.
    def with_timeout(timeout : Time::Span) : Tuple(Context, ->)
      ctx = Context.new(self)
      ctx.deadline = Time.monotonic + timeout

      cancel_fn = -> { ctx.cancel }
      ctx.cancel_func = cancel_fn

      # Store parent context and cancel function in value map for CancelTimeout
      ctx.set_value(TIMEOUT_KEY, TimeoutContextVal.new(self, cancel_fn))

      spawn do
        deadline = ctx.deadline
        if deadline
          sleep_time = deadline - Time.monotonic
          if sleep_time > Time::Span::ZERO
            sleep sleep_time
          end
        end
        ctx.cancel("context timeout after #{timeout}")
      end

      {ctx, cancel_fn}
    end

    # WithCancel creates a new context with cancel function.
    def with_cancel : Tuple(Context, ->)
      ctx = Context.new(self)
      cancel_fn = -> { ctx.cancel }
      ctx.cancel_func = cancel_fn
      {ctx, cancel_fn}
    end

    # TimeoutValue returns the timeout context value if this context was created by WithTimeout.
    def timeout_value : TimeoutContextVal?
      value(TIMEOUT_KEY).as?(TimeoutContextVal)
    end

    protected setter cancel_func = (@cancel_func : ->?)
  end

  # ContextCanceledError is raised when a context is cancelled.
  class ContextCanceledError < RodError
    def initialize(reason : String = "context cancelled")
      super("context cancelled: #{reason}")
    end
  end

  # ContextTimeoutError is raised when a context times out.
  class ContextTimeoutError < RodError
    def initialize(timeout : Time::Span)
      super("context timeout after #{timeout}")
    end
  end
end
