module Rod::Lib::Defaults
  # Default logger
  def self.logger
    @@logger ||= ::Log.for("rod")
  end

  # Slow motion duration
  SLOW = 0.seconds

  def self.slow
    SLOW
  end

  # Trace flag
  TRACE = false

  def self.trace
    TRACE
  end

  # CDP logger
  CDP = logger
end
