module Rod::Lib::Launcher
  # Launcher for starting browser processes.
  class Launcher
    @flags : Array(String)

    def initialize(@flags = [] of String)
    end

    # Launch browser and return WebSocket URL.
    def launch : String
      "ws://localhost:9222/devtools/browser/..."
    end
  end
end