module Rod::Lib::Utils
  # Sleeper for retries.
  class Sleeper
    def initialize(@interval : Time::Span = 0.1.seconds, @timeout : Time::Span = 5.seconds)
    end

    def sleep : Nil
      ::sleep(@interval)
    end
  end

  # Random string generator.
  def self.rand_string(length : Int32 = 8) : String
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    String.new(length) { chars.sample }
  end

  # AbsolutePaths returns absolute paths of files in current working directory.
  def self.absolute_paths(paths : Array(String)) : Array(String)
    abs_paths = [] of String
    paths.each do |p|
      abs_paths << File.expand_path(p)
    end
    abs_paths
  end

  # Error helper.
  def self.e(err : Exception?)
    raise err if err
  end

  # Retry executes fn and sleeps using sleeper until fn returns true or context is cancelled.
  def self.retry(ctx : Rod::Context, sleeper : Sleeper, &fn : -> Tuple(Bool, Exception?)) : Exception?
    loop do
      stop, err = fn.call
      if stop
        return err
      end

      # Check context cancellation
      if ctx.cancelled?
        return ctx.err || Rod::ContextCanceledError.new("context cancelled")
      end

      # Sleep using sleeper
      sleeper.sleep
    end
  rescue ex : Exception
    ex
  end
end
