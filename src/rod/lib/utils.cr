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

  # Error helper.
  def self.e(err : Exception?)
    raise err if err
  end
end
