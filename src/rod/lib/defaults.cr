module Rod::Lib::Defaults
  # Default logger
  def self.logger
    @@logger ||= ::Logger.new(STDOUT).tap do |log|
      log.level = ::Logger::INFO
    end
  end

  # Slow motion duration
  SLOW = 0.seconds

  # Trace flag
  TRACE = false

  # CDP logger
  CDP = logger
end