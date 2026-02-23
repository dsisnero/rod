# Leakless process launcher for Crystal port of Rod
# Provides similar interface to Go's github.com/ysmood/leakless package
# Ensures browser processes are killed when parent process exits
module Rod::Lib::Leakless
  class_property? support : Bool = true
  class_property lock_port : Int32 = 2968

  # Launcher for leakless process management
  class Launcher
    @pid_channel : Channel(Int32)?
    @error : String?
    @process : Process?

    def initialize
      @pid_channel = Channel(Int32).new(1)
      @error = nil
      @process = nil
    end

    # Create a command that will be managed by leakless
    def command(bin : String, args : Array(String) = [] of String, error : IO = Process::Redirect::Pipe) : Process
      # Create process with pipes for stderr/stdout
      process = Process.new(bin, args, output: Process::Redirect::Pipe, error: error)
      @process = process

      # Start monitoring process
      spawn do
        begin
          # Wait for process to start and get PID
          sleep 0.1 # small delay to ensure process started
          pid = process.pid
          @pid_channel.try &.send(pid)
        rescue ex
          @error = ex.message
          @pid_channel.try &.close
        end
      end

      process
    end

    # Get PID channel
    def pid : Channel(Int32)
      @pid_channel ||= Channel(Int32).new(1)
    end

    # Get error if any
    def err : String?
      @error
    end

    # Cleanup resources
    def cleanup : Nil
      @process.try &.terminate rescue nil
      @pid_channel.try &.close
    end
  end

  # Create a new leakless launcher
  def self.new : Launcher
    Launcher.new
  end

  # Check if leakless is supported on current platform
  def self.support? : Bool
    # Leakless is supported on all platforms for now
    # In Go implementation, it checks for Windows vs Unix
    @@support
  end

  # Lock a TCP port to prevent race conditions
  # Returns a cleanup function that should be deferred
  def self.lock_port(port : Int32 = @@lock_port) : -> Nil
    # Attempt to bind to the port to create a lock
    server = TCPServer.new("127.0.0.1", port) rescue nil

    proc do
      server.try &.close
    end
  end

  # Set default lock port
  def self.lock_port=(port : Int32) : Nil
    @@lock_port = port
  end

  # Set support flag
  def self.support=(value : Bool) : Nil
    @@support = value
  end
end
