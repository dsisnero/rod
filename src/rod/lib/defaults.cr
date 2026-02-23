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

  # Launcher defaults
  SHOW      = false
  DEVTOOLS  = false
  DIR       = ""
  PORT      = "0"
  BIN       = ""
  PROXY     = ""
  LOCK_PORT = 2978
  URL       = ""

  def self.show
    SHOW
  end

  def self.devtools
    DEVTOOLS
  end

  def self.dir
    DIR
  end

  def self.port
    PORT
  end

  def self.bin
    BIN
  end

  def self.proxy
    PROXY
  end

  def self.lock_port
    LOCK_PORT
  end

  def self.url
    URL
  end
end
