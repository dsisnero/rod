require "http/client"
require "file"
require "file_utils"
require "digest"
require "process"
require "json"
require "lib_c"
require "./leakless"
require "./url_parser"

module Rod::Lib::Launcher
  # Platform detection
  private macro os
    {% if flag?(:darwin) %}
      "darwin"
    {% elsif flag?(:linux) %}
      "linux"
    {% elsif flag?(:windows) %}
      "windows"
    {% else %}
      "unknown"
    {% end %}
  end

  private macro arch
    {% if flag?(:x86_64) %}
      "amd64"
    {% elsif flag?(:arm64) %}
      "arm64"
    {% elsif flag?(:i386) %}
      "386"
    {% else %}
      "unknown"
    {% end %}
  end

  # Flags module for browser command line arguments
  module Flags
    # Flag name of a command line argument of the browser, also known as command line flag or switch.
    # List of available flags: https://peter.sh/experiments/chromium-command-line-switches
    alias Flag = String

    # TODO: we should automatically generate all the flags here.
    USER_DATA_DIR         = "user-data-dir"
    HEADLESS              = "headless"
    APP                   = "app"
    REMOTE_DEBUGGING_PORT = "remote-debugging-port"
    NO_SANDBOX            = "no-sandbox"
    PROXY_SERVER          = "proxy-server"
    WINDOW_SIZE           = "window-size"
    WINDOW_POSITION       = "window-position"
    WORKING_DIR           = "rod-working-dir"
    ENV                   = "rod-env"
    XVFB                  = "rod-xvfb"
    PROFILE_DIR           = "profile-directory"
    PREFERENCES           = "rod-preferences"
    LEAKLESS              = "rod-leakless"
    BIN                   = "rod-bin"
    KEEP_USER_DATA_DIR    = "rod-keep-user-data-dir"
    ARGUMENTS             = "" # Empty string for arguments

    # Check if the flag name is valid.
    def self.check(flag : String) : Nil
      raise "Flag name should not contain '='" if flag.includes?('=')
    end

    # Normalize flag name, remove leading dash.
    def self.normalize(flag : String) : String
      flag.lstrip('-')
    end
  end

  # Resolve URL by requesting the JSON version endpoint
  def self.resolve_url(url : String) : String
    Rod::Lib::URLParser.resolve_url(url)
  end

  # MustResolveURL variant that raises on error
  def self.must_resolve_url(url : String) : String
    resolve_url(url)
  end

  # Revision constants from revision.go
  REVISION_DEFAULT    = 1321438
  REVISION_PLAYWRIGHT =    1124

  # Host formats a revision number to a downloadable URL for the browser.
  alias Host = Int32 -> String

  # Platform-specific configuration
  private HOST_CONF = begin
    platform = "#{os}_#{arch}"
    case platform
    when "darwin_amd64"
      {"Mac", "chrome-mac.zip"}
    when "darwin_arm64"
      {"Mac_Arm", "chrome-mac.zip"}
    when "linux_amd64"
      {"Linux_x64", "chrome-linux.zip"}
    when "windows_386"
      {"Win", "chrome-win.zip"}
    when "windows_amd64"
      {"Win_x64", "chrome-win.zip"}
    else
      raise "Unsupported platform: #{platform}"
    end
  end

  # HostGoogle to download browser.
  def self.host_google(revision : Int32) : String
    prefix, zip_name = HOST_CONF
    "https://storage.googleapis.com/chromium-browser-snapshots/#{prefix}/#{revision}/#{zip_name}"
  end

  # HostNPM to download browser.
  def self.host_npm(revision : Int32) : String
    prefix, zip_name = HOST_CONF
    "https://registry.npmmirror.com/-/binary/chromium-browser-snapshots/#{prefix}/#{revision}/#{zip_name}"
  end

  # HostPlaywright to download browser.
  def self.host_playwright(revision : Int32) : String
    rev = if os == "linux" && arch == "arm64"
            REVISION_PLAYWRIGHT
          else
            revision
          end
    "https://playwright.azureedge.net/builds/chromium/#{rev}/chromium-linux-arm64.zip"
  end

  # DefaultBrowserDir for downloaded browser.
  def self.default_browser_dir : String
    case os
    when "windows"
      appdata = ENV["APPDATA"]? || raise "APPDATA environment variable not set"
      File.join(appdata, "rod", "browser")
    when "darwin", "linux"
      cache = ENV["HOME"]? || raise "HOME environment variable not set"
      File.join(cache, ".cache", "rod", "browser")
    else
      raise "Unsupported OS: #{os}"
    end
  end

  # Browser is a helper to download browser smartly.
  class Browser
    property context : HTTP::Client::Context? = nil
    property hosts : Array(Host) = [] of Host
    property revision : Int32 = REVISION_DEFAULT
    property root_dir : String = ::Rod::Lib::Launcher.default_browser_dir
    property logger : ::Log = ::Log.for("rod.launcher")
    property lock_port : Int32 = 2968
    property http_client : HTTP::Client? = nil

    def initialize(
      @context = nil,
      @hosts = [->::Rod::Lib::Launcher.host_google(Int32), ->::Rod::Lib::Launcher.host_npm(Int32), ->::Rod::Lib::Launcher.host_playwright(Int32)],
      @revision = REVISION_DEFAULT,
      @root_dir = ::Rod::Lib::Launcher.default_browser_dir,
      @logger = ::Log.for("rod.launcher"),
      @lock_port = 2968,
      @http_client = nil,
    )
    end

    # Directory to download the browser.
    def dir : String
      File.join(@root_dir, "chromium-#{@revision}")
    end

    # Binary path of the downloaded browser.
    def bin_path : String
      bin = case Launcher.os
            when "darwin"
              "Chromium.app/Contents/MacOS/Chromium"
            when "linux"
              "chrome"
            when "windows"
              "chrome.exe"
            else
              raise "Unsupported OS: #{Launcher.os}"
            end
      File.join(dir, bin)
    end

    # Download browser from the fastest host.
    # It will race downloading from each host and use the fastest successful one.
    def download : Nil
      dir = self.dir
      FileUtils.mkdir_p(dir)

      # Build URLs from hosts
      urls = @hosts.map(&.call(@revision))

      # Try to download from each host, first successful wins
      downloaded = false
      urls.each do |url|
        begin
          @logger.info { "Trying to download from #{url}" }
          download_from_url(url, dir)
          downloaded = true
          @logger.info { "Successfully downloaded from #{url}" }
          break
        rescue ex
          @logger.error { "Failed to download from #{url}: #{ex.message}" }
        end
      end

      unless downloaded
        raise "Can't find a browser binary for your OS, the doc might help https://go-rod.github.io/#/compatibility?id=os"
      end

      # Strip first directory from zip if needed
      strip_first_dir(dir)
    end

    # Download and extract a single URL
    private def download_from_url(url : String, dir : String) : Nil
      # Download the file
      zip_path = File.join(dir, "download.zip")

      http_client = @http_client || HTTP::Client.new
      response = http_client.get(url)
      unless response.status_code == 200
        raise "HTTP #{response.status_code} from #{url}"
      end

      # Write to file
      File.write(zip_path, response.body)

      # Extract zip
      extract_zip(zip_path, dir)

      # Cleanup
      File.delete(zip_path)
    end

    # Extract zip file using system unzip command
    private def extract_zip(zip_path : String, dir : String) : Nil
      # Try unzip command
      result = Process.run("unzip", ["-q", "-o", zip_path, "-d", dir], output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
      unless result.success?
        # Try with -qq for quieter output
        result = Process.run("unzip", ["-qq", "-o", zip_path, "-d", dir], output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
        unless result.success?
          raise "Failed to extract zip: #{result.error.gets_to_end}"
        end
      end
    end

    # Strip the first directory level (zip often contains a top-level dir)
    private def strip_first_dir(dir : String) : Nil
      entries = Dir.children(dir)
      return unless entries.size == 1

      only_entry = File.join(dir, entries.first)
      return unless Dir.exists?(only_entry)

      # Move contents up
      Dir.children(only_entry).each do |item|
        src = File.join(only_entry, item)
        dst = File.join(dir, item)
        File.rename(src, dst)
      end

      # Remove empty directory
      Dir.delete(only_entry)
    end

    # Validate returns nil if the browser executable is valid.
    # If the executable is malformed it will return error.
    def validate : Nil
      bin = bin_path
      unless File.exists?(bin)
        raise "Browser executable not found: #{bin}"
      end

      # Test running the browser
      args = ["--headless", "--no-sandbox", "--use-mock-keychain", "--disable-dev-shm-usage",
              "--disable-gpu", "--dump-dom", "about:blank"]
      result = Process.run(bin, args, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)

      unless result.success?
        output = result.error.gets_to_end
        # When the os is missing some dependencies for chromium we treat it as valid binary.
        if output.includes?("error while loading shared libraries")
          return
        end
        raise "Failed to run the browser: #{result.exit_status}\n#{output}"
      end

      output = result.output.gets_to_end
      unless output.includes?("<html><head></head><body></body></html>")
        raise "The browser executable doesn't support headless mode"
      end
    end

    # Get is a smart helper to get the browser executable path.
    # If Browser#bin_path is not valid it will auto download the browser.
    def get : String
      # Use leakless lock port to prevent race downloading
      cleanup = Rod::Lib::Leakless.lock_port(@lock_port)
      begin
        validate
        bin_path
      rescue
        # Try to cleanup before downloading
        FileUtils.rm_rf(dir) if Dir.exists?(dir)
        download
        bin_path
      ensure
        cleanup.call
      end
    end

    # MustGet is similar with Get but raises on error.
    def must_get : String
      get
    end

    # LookPath searches for the browser executable from often used paths on current OS.
    def self.look_path : Tuple(String?, Bool)
      list = case os
             when "darwin"
               [
                 "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
                 "/Applications/Chromium.app/Contents/MacOS/Chromium",
                 "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
                 "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary",
                 "/usr/bin/google-chrome-stable",
                 "/usr/bin/google-chrome",
                 "/usr/bin/chromium",
                 "/usr/bin/chromium-browser",
               ]
             when "linux"
               [
                 "chrome",
                 "google-chrome",
                 "/usr/bin/google-chrome",
                 "microsoft-edge",
                 "/usr/bin/microsoft-edge",
                 "chromium",
                 "chromium-browser",
                 "google-chrome-stable",
                 "/usr/bin/google-chrome-stable",
                 "/usr/bin/chromium",
                 "/usr/bin/chromium-browser",
                 "/snap/bin/chromium",
                 "/data/data/com.termux/files/usr/bin/chromium-browser",
               ]
             when "windows"
               # Windows paths would go here
               [] of String
             else
               [] of String
             end

      list.each do |path|
        if File.executable?(path) || (path.includes?('.') && Process.find_executable(path))
          return {path, true}
        end
      end

      {nil, false}
    end
  end

  # Open tries to open the url via system's default browser.
  def self.open(url : String) : Nil
    # Windows doesn't support format [::]
    url = url.gsub("[::]", "[::1]")

    found, has = look_path
    if has && found
      Process.new(found.not_nil!, [url]).start # ameba:disable Lint/NotNil
    end
  end

  # Launcher is a helper to launch browser binary smartly.
  class Launcher
    property flags : Hash(String, Array(String))
    property logger : ::Log
    property browser : Browser
    @pid : Int32 = 0
    @exit : Channel(Nil)? = nil
    @is_launched : Bool = false

    # Default user data directory prefix
    DEFAULT_USER_DATA_DIR_PREFIX = File.join(Dir.tempdir, "rod", "user-data")

    # Create a new launcher with default arguments.
    # Headless will be enabled by default.
    # UserDataDir will use OS tmp dir by default, this folder will usually be cleaned up by the OS after reboot.
    # It will auto download the browser binary according to the current platform.
    def initialize
      dir = ::Rod::Lib::Defaults.dir
      if dir.empty?
        dir = File.join(DEFAULT_USER_DATA_DIR_PREFIX, Random::Secure.hex(4))
      end

      @flags = {} of String => Array(String)
      @logger = ::Log.for("rod.launcher")
      @browser = Browser.new
      @pid = 0
      @exit = nil
      @is_launched = false

      # Set default flags (similar to Go's New())
      set(Flags::BIN, ::Rod::Lib::Defaults.bin) unless ::Rod::Lib::Defaults.bin.empty?
      set(Flags::LEAKLESS) if ::Rod::Lib::Defaults.lock_port > 0
      set(Flags::USER_DATA_DIR, dir)
      set(Flags::REMOTE_DEBUGGING_PORT, ::Rod::Lib::Defaults.port)
      set(Flags::HEADLESS) unless ::Rod::Lib::Defaults.show

      # Default flags
      set("no-first-run")
      set("no-startup-window")
      set("disable-features", "site-per-process", "TranslateUI")
      set("disable-dev-shm-usage")
      set("disable-background-networking")
      set("disable-background-timer-throttling")
      set("disable-backgrounding-occluded-windows")
      set("disable-breakpad")
      set("disable-client-side-phishing-detection")
      set("disable-component-extensions-with-background-pages")
      set("disable-default-apps")
      set("disable-hang-monitor")
      set("disable-ipc-flooding-protection")
      set("disable-popup-blocking")
      set("disable-prompt-on-repost")
      set("disable-renderer-backgrounding")
      set("disable-sync")
      set("disable-site-isolation-trials")
      set("enable-automation")
      set("enable-features", "NetworkService", "NetworkServiceInProcess")
      set("force-color-profile", "srgb")
      set("metrics-recording-only")
      set("use-mock-keychain")

      # Conditional defaults
      set("auto-open-devtools-for-tabs") if ::Rod::Lib::Defaults.devtools
      set(Flags::PROXY_SERVER, ::Rod::Lib::Defaults.proxy) unless ::Rod::Lib::Defaults.proxy.empty?
    end

    # Set a command line argument when launching the browser.
    # Be careful the first argument is a flag name, it shouldn't contain values. The values the will be joined with comma.
    # A flag can have multiple values. If no values are provided the flag will be a boolean flag.
    def set(name : String, *values : String) : self
      Flags.check(name)
      normalized = Flags.normalize(name)
      @flags[normalized] = values.to_a
      self
    end

    # Get flag's first value.
    def get(name : String) : String?
      list = @flags[Flags.normalize(name)]?
      list.try(&.first?)
    end

    # Check if flag exists.
    def has(name : String) : Bool
      @flags.has_key?(Flags.normalize(name))
    end

    # Delete a flag.
    def delete(name : String) : self
      @flags.delete(Flags.normalize(name))
      self
    end

    # Append values to the flag.
    def append(name : String, *values : String) : self
      normalized = Flags.normalize(name)
      existing = @flags[normalized]? || [] of String
      @flags[normalized] = existing + values.to_a
      self
    end

    # Set browser binary path.
    def bin(path : String) : self
      set(Flags::BIN, path)
    end

    # Set browser revision to auto download.
    def revision(rev : Int32) : self
      @browser.revision = rev
      self
    end

    # Enable or disable headless mode.
    def headless(enable : Bool = true) : self
      enable ? set(Flags::HEADLESS) : delete(Flags::HEADLESS)
    end

    # Enable or disable no-sandbox mode.
    def no_sandbox(enable : Bool = true) : self
      enable ? set(Flags::NO_SANDBOX) : delete(Flags::NO_SANDBOX)
    end

    # Enable or disable leakless mode.
    def leakless(enable : Bool = true) : self
      enable ? set(Flags::LEAKLESS) : delete(Flags::LEAKLESS)
    end

    # Enable or disable devtools auto open.
    def devtools(auto_open : Bool = true) : self
      auto_open ? set("auto-open-devtools-for-tabs") : delete("auto-open-devtools-for-tabs")
    end

    # Set user data directory.
    def user_data_dir(dir : String) : self
      dir.empty? ? delete(Flags::USER_DATA_DIR) : set(Flags::USER_DATA_DIR, dir)
    end

    # Set remote debugging port.
    def remote_debugging_port(port : Int32) : self
      set(Flags::REMOTE_DEBUGGING_PORT, port.to_s)
    end

    # Set proxy server.
    def proxy(host : String) : self
      set(Flags::PROXY_SERVER, host)
    end

    # Format flags as command line arguments.
    def format_args : Array(String)
      exec_args = [] of String
      @flags.each do |k, v|
        # Skip rod- internal flags and empty argument placeholder
        next if k.starts_with?("rod-") || k.empty?

        # Fix a bug of chrome, if path is not absolute chrome will hang
        if k == Flags::USER_DATA_DIR && !v.empty?
          abs = File.expand_path(v.first)
          v[0] = abs
        end

        arg = "--#{k}"
        arg += "=#{v.join(",")}" unless v.empty?
        exec_args << arg
      end

      # Add arguments (empty key)
      if args = @flags[""]?
        exec_args.concat(args)
      end

      exec_args.sort!
    end

    # Launch a standalone temp browser instance and returns the debug url.
    def launch : String
      raise "Launcher can only be used once" if @is_launched
      @is_launched = true

      # Get browser binary path (auto-downloads if needed)
      bin_path = @browser.must_get

      # Setup user preferences if needed
      setup_user_preferences

      # Format command line arguments
      args = format_args

      # Launch process with leakless if enabled
      @logger.info { "Launching browser: #{bin_path} #{args.join(" ")}" }

      # Try to resolve URL first if not using leakless
      unless has(Flags::LEAKLESS) && Rod::Lib::Leakless.support?
        port = get(Flags::REMOTE_DEBUGGING_PORT) || "0"
        begin
          return self.class.resolve_url(port)
        rescue
          # Browser not running on that port, continue to launch
        end
      end

      ll : Rod::Lib::Leakless::Launcher? = nil
      process : Process
      parser = Rod::Lib::URLParser.new

      if has(Flags::LEAKLESS) && Rod::Lib::Leakless.support?
        ll = Rod::Lib::Leakless.new
        process = ll.command(bin_path, args, error: parser)

        # Wait for PID from leakless channel
        pid_channel = ll.pid
        select
        when pid = pid_channel.receive
          @pid = pid
        when timeout 5.seconds
          raise "Timeout waiting for leakless PID"
        end

        # Check for leakless error
        if err = ll.err
          raise "Leakless error: #{err}"
        end
      else
        # Launch new process with stderr piped to parser
        process = Process.new(bin_path, args, output: Process::Redirect::Pipe, error: parser)
        @pid = process.pid
      end

      # Create exit channel
      @exit = Channel(Nil).new

      # Monitor process exit in background
      spawn do
        process.wait
        @exit.try(&.close)
      end

      # Get WebSocket URL from parser channel
      select
      when ws_url = parser.url.receive
        ws_url
      when timeout 10.seconds
        # Check for error in parser
        if err = parser.error
          raise err
        end
        raise "Timeout waiting for WebSocket URL from browser"
      end
    end

    # Launch and connect to browser.
    def launch_and_connect : Rod::Browser
      ws_url = launch
      browser = Rod::Browser.new
      browser.connect(ws_url)
      browser
    end

    # Get browser process PID.
    def pid : Int32
      @pid
    end

    # Kill the browser process.
    def kill : Nil
      return if @pid == 0

      # Give browser time to start children processes
      sleep 1.second

      # Try to kill process group
      {% if flag?(:unix) %}
        # On Unix, negative PID kills process group
        Process.kill("TERM", -@pid) rescue nil
        Process.kill("KILL", -@pid) rescue nil
      {% else %}
        # On Windows, positive PID kills process
        Process.kill("TERM", @pid) rescue nil
        Process.kill("KILL", @pid) rescue nil
      {% end %}
    end

    # Cleanup wait until the Browser exits and remove user data dir.
    def cleanup : Nil
      @exit.try(&.receive?)
      dir = get(Flags::USER_DATA_DIR)
      if dir && !has(Flags::KEEP_USER_DATA_DIR)
        FileUtils.rm_rf(dir) if Dir.exists?(dir)
      end
    end

    private def setup_user_preferences : Nil
      user_dir = get(Flags::USER_DATA_DIR)
      pref = get(Flags::PREFERENCES)
      return if user_dir.nil? || pref.nil?

      user_dir = File.expand_path(user_dir)
      profile = get(Flags::PROFILE_DIR) || "Default"
      path = File.join(user_dir, profile, "Preferences")

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, pref)
    end
  end
end
