# Leakless process launcher for Crystal port of Rod
# Provides similar interface to Go's github.com/ysmood/leakless package
# Ensures browser processes are killed when parent process exits
module Rod::Lib::Leakless
  class_property? support : Bool = true
  class_property lock_port : Int32 = 2968

  # Track all leakless processes for cleanup
  class_property tracked_processes = [] of Int32
  @@cleanup_registered = false

  # Register at_exit handler for cleanup
  private def self.register_cleanup
    return if @@cleanup_registered
    at_exit do
      tracked_processes.each do |pid|
        begin
          {% if flag?(:unix) %}
            Process.kill("KILL", -pid) rescue nil
          {% else %}
            Process.kill("KILL", pid) rescue nil
          {% end %}
        rescue
          # Ignore errors during exit
        end
      end
    end
    @@cleanup_registered = true
  end

  # Launcher for leakless process management
  class Launcher
    @pid_channel : Channel(Int32)?
    @error : String?
    @process : Process?
    @pid : Int32?

    def initialize
      @pid_channel = Channel(Int32).new(1)
      @error = nil
      @process = nil
      @pid = nil
    end

    # Create a command that will be managed by leakless
    def command(bin : String, args : Array(String) = [] of String, error : IO = Process::Redirect::Pipe) : Process
      # Register cleanup handler if not already done
      self.class.register_cleanup

      # Create process with pipes for stderr/stdout
      process = Process.new(bin, args, output: Process::Redirect::Pipe, error: error)
      @process = process

      # Start monitoring process
      spawn do
        begin
          # Wait for process to start and get PID
          sleep 0.1 # small delay to ensure process started
          pid = process.pid
          @pid = pid
          # Track PID for cleanup
          self.class.tracked_processes << pid
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
      if pid = @pid
        self.class.tracked_processes.delete(pid)
      end
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
