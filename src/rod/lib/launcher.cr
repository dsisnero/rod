require "http/client"
require "file"
require "file_utils"
require "digest"
require "digest/sha256"
require "base64"
require "process"
require "json"
require "lib_c"
require "./leakless"
require "./url_parser"

module Rod::Lib::Launcher
  HEADER_NAME          = "Rod-Launcher"
  ERR_ALREADY_LAUNCHED = "already launched"
  @@look_path_provider = -> { Browser.look_path }
  @@open_runner = ->(bin : String, args : Array(String)) {
    Process.new(bin, args)
    nil
  }

  @@in_container = begin
    File.exists?("/.dockerenv") || File.exists?("/.containerenv") ||
    begin
      cgroup = File.read("/proc/1/cgroup")
      cgroup.includes?("docker") || cgroup.includes?("kubepods") || cgroup.includes?("containerd")
    rescue
      false
    end
  end

  def self.in_container? : Bool
    @@in_container
  end

  def self.in_container=(value : Bool) : Bool
    @@in_container = value
  end

  def self.to_http(uri : URI) : URI
    new_uri = uri.dup
    case new_uri.scheme
    when "ws"
      new_uri.scheme = "http"
    when "wss"
      new_uri.scheme = "https"
    end
    new_uri
  end

  def self.to_ws(uri : URI) : URI
    new_uri = uri.dup
    case new_uri.scheme
    when "http"
      new_uri.scheme = "ws"
    when "https"
      new_uri.scheme = "wss"
    end
    new_uri
  end

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
    {% elsif flag?(:arm64) || flag?(:aarch64) %}
      "arm64"
    {% elsif flag?(:i386) %}
      "386"
    {% else %}
      "unknown"
    {% end %}
  end

  def self.os_name : String
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

  def self.arch_name : String
    {% if flag?(:x86_64) %}
      "amd64"
    {% elsif flag?(:arm64) || flag?(:aarch64) %}
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
    property lock_port : Int32 = ::Rod::Lib::Defaults.lock_port
    property http_client : HTTP::Client? = nil

    def initialize(
      @context = nil,
      @hosts = [->::Rod::Lib::Launcher.host_google(Int32), ->::Rod::Lib::Launcher.host_npm(Int32), ->::Rod::Lib::Launcher.host_playwright(Int32)],
      @revision = REVISION_DEFAULT,
      @root_dir = ::Rod::Lib::Launcher.default_browser_dir,
      @logger = ::Log.for("rod.launcher"),
      @lock_port = ::Rod::Lib::Defaults.lock_port,
      @http_client = nil,
    )
    end

    # Directory to download the browser.
    def dir : String
      File.join(@root_dir, "chromium-#{@revision}")
    end

    # Binary path of the downloaded browser.
    def bin_path : String
      bin = case ::Rod::Lib::Launcher.os_name
            when "darwin"
              "Chromium.app/Contents/MacOS/Chromium"
            when "linux"
              "chrome"
            when "windows"
              "chrome.exe"
            else
              raise "Unsupported OS: #{::Rod::Lib::Launcher.os_name}"
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

      response = if http_client = @http_client
                   http_client.get(url)
                 else
                   HTTP::Client.get(url)
                 end
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
        unzip_out = IO::Memory.new
        unzip_err = IO::Memory.new
        result = Process.run("unzip", ["-qq", "-o", zip_path, "-d", dir], output: unzip_out, error: unzip_err)
        unless result.success?
          raise "Failed to extract zip: #{unzip_err}"
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
      browser_out = IO::Memory.new
      browser_err = IO::Memory.new
      result = Process.run(bin, args, output: browser_out, error: browser_err)

      unless result.success?
        output = "#{browser_out}#{browser_err}"
        # When the os is missing some dependencies for chromium we treat it as valid binary.
        if output.includes?("error while loading shared libraries")
          return
        end
        code = result.exit_code?.try(&.to_s) || result.to_s
        raise "failed to run the browser: #{code}\n#{output}"
      end

      output = browser_out.to_s
      unless output.includes?("<html><head></head><body></body></html>")
        raise "the browser executable doesn't support headless mode"
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
      list = case ::Rod::Lib::Launcher.os_name
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
        executable = File::Info.executable?(path) rescue false
        found = Process.find_executable(path)

        if executable || found
          return {(found || path), true}
        end
      end

      {nil, false}
    end
  end

  # Open tries to open the url via system's default browser.
  def self.open(url : String) : Nil
    # Windows doesn't support format [::]
    url = url.gsub("[::]", "[::1]")

    found, has = look_path_provider.call
    if has && found
      open_runner.call(found.not_nil!, [url]) # ameba:disable Lint/NotNil
    end
  end

  # Test seam: override executable lookup.
  def self.look_path_provider=(provider : -> Tuple(String?, Bool))
    @@look_path_provider = provider
  end

  def self.look_path_provider
    @@look_path_provider.not_nil!
  end

  # Test seam: override process spawn used by open.
  def self.open_runner=(runner : String, Array(String) -> Nil)
    @@open_runner = runner
  end

  def self.open_runner
    @@open_runner.not_nil!
  end

  # New returns the default arguments to start browser.
  def self.new : Launcher
    Launcher.new
  end

  # NewUserMode enables reusing current user profile.
  def self.new_user_mode : Launcher
    bin, _has = Browser.look_path
    launcher = Launcher.new
    launcher.flags.clear
    launcher.set(Flags::REMOTE_DEBUGGING_PORT, "37712")
    launcher.set("no-startup-window")
    launcher.set(Flags::BIN, bin || "")
    launcher
  end

  # NewAppMode runs browser like a native app window.
  def self.new_app_mode(url : String) : Launcher
    new
      .set(Flags::APP, url)
      .set(Flags::ENV, "GOOGLE_API_KEY=no")
      .headless(false)
      .delete("no-startup-window")
      .delete("enable-automation")
  end

  # NewManaged creates launcher defaults from a remote manager endpoint.
  def self.new_managed(service_url : String = "") : Launcher
    service_url = "ws://127.0.0.1:7317" if service_url.empty?

    uri = URI.parse(service_url)
    launcher = new
    launcher.mark_managed!(to_ws(uri).to_s)
    launcher.flags.clear

    res = HTTP::Client.get(to_http(uri).to_s)
    body = res.body
    launcher.load_flags_json(body)
    launcher
  end

  # MustNewManaged variant.
  def self.must_new_managed(service_url : String = "") : Launcher
    launcher = new_managed(service_url)
    # Keep parity with Go helper for managed docker environments.
    launcher.set("disable-http2")
    launcher
  end

  # NewManager creates a launcher manager HTTP handler.
  def self.new_manager : Manager
    Manager.new
  end

  # Launcher is a helper to launch browser binary smartly.
  class Launcher
    property flags : Hash(String, Array(String))
    property logger : ::Log
    property browser : Browser
    property managed : Bool = false
    property service_url : String = ""
    @pid : Int32 = 0
    @exit : Channel(Nil)? = nil
    @is_launched : Bool = false
    @ctx : Channel(Nil)? = nil

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
      set(Flags::BIN, ::Rod::Lib::Defaults.bin)
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
      set(Flags::NO_SANDBOX) if ::Rod::Lib::Launcher.in_container?
      set(Flags::PROXY_SERVER, ::Rod::Lib::Defaults.proxy) unless ::Rod::Lib::Defaults.proxy.empty?
    end

    # Set a command line argument when launching the browser.
    # Be careful the first argument is a flag name, it shouldn't contain values. The values the will be joined with comma.
    # A flag can have multiple values. If no values are provided the flag will be a boolean flag.
    def set(name : String) : self
      Flags.check(name)
      normalized = Flags.normalize(name)
      @flags[normalized] = [] of String
      self
    end

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

    # Set browser process output sink for API parity with Go Logger(io.Writer).
    def logger(io : IO) : self
      # Keep existing structured logger as source of launch logs; output sink
      # integration can be expanded when websocket launch path is fully ported.
      io # mark argument as used
      self
    end

    # Set launch context cancellation channel.
    def context(ctx : Channel(Nil)) : self
      @ctx = ctx
      self
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

    # Enable or disable --headless=new mode.
    def headless_new(enable : Bool = true) : self
      enable ? set(Flags::HEADLESS, "new") : delete(Flags::HEADLESS)
    end

    # Enable or disable no-sandbox mode.
    def no_sandbox(enable : Bool = true) : self
      enable ? set(Flags::NO_SANDBOX) : delete(Flags::NO_SANDBOX)
    end

    # Enable xvfb wrapper options.
    def xvfb : self
      set(Flags::XVFB)
    end

    # Enable xvfb wrapper options.
    def xvfb(*args : String) : self
      set(Flags::XVFB, *args)
    end

    # Set chromium preferences json.
    def preferences(pref : String) : self
      set(Flags::PREFERENCES, pref)
    end

    # Set preferences to always open PDFs externally.
    def always_open_pdf_externally : self
      preferences(%({"plugins":{"always_open_pdf_externally": true}}))
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

    # Set profile directory.
    def profile_dir(dir : String) : self
      dir.empty? ? delete(Flags::PROFILE_DIR) : set(Flags::PROFILE_DIR, dir)
    end

    # Set remote debugging port.
    def remote_debugging_port(port : Int32) : self
      set(Flags::REMOTE_DEBUGGING_PORT, port.to_s)
    end

    # Set proxy server.
    def proxy(host : String) : self
      set(Flags::PROXY_SERVER, host)
    end

    # Set browser window size.
    def window_size(x : Int32, y : Int32) : self
      set(Flags::WINDOW_SIZE, "#{x},#{y}")
    end

    # Set browser window position.
    def window_position(x : Int32, y : Int32) : self
      set(Flags::WINDOW_POSITION, "#{x},#{y}")
    end

    # Set working directory for process launch.
    def working_dir(path : String) : self
      set(Flags::WORKING_DIR, path)
    end

    # Set process environment variables.
    def env(*env : String) : self
      set(Flags::ENV, *env)
    end

    # Ignore certificates by SPKI fingerprints derived from public-key PEM blocks.
    # Mirrors Go launcher's IgnoreCerts behavior.
    def ignore_certs(keys : Array(String?)) : Nil
      hashes = [] of String

      keys.each do |key|
        raise "invalid certificate key" if key.nil?
        pem = key.not_nil!.strip
        raise "invalid certificate key" if pem.empty?

        b64 = pem
          .lines
          .map(&.strip)
          .reject { |line| line.starts_with?("-----BEGIN ") || line.starts_with?("-----END ") || line.empty? }
          .join

        raise "invalid certificate key" if b64.empty?
        der = Base64.decode(b64)
        hashes << Base64.strict_encode(Digest::SHA256.digest(der))
      rescue
        raise "invalid certificate key"
      end

      set("ignore-certificate-errors-spki-list", hashes.join(","))
    end

    # Add startup URL argument.
    def start_url(url : String) : self
      set(Flags::ARGUMENTS, url)
    end

    # Keep user data dir after cleanup.
    def keep_user_data_dir : self
      must_managed!
      set(Flags::KEEP_USER_DATA_DIR)
    end

    # JSON payload for remote manager.
    def json : Bytes
      to_manager_json.to_json.to_slice
    end

    # Build websocket URL and headers for remote manager launching.
    def client_header : Tuple(String, HTTP::Headers)
      must_managed!
      headers = HTTP::Headers.new
      headers.add(HEADER_NAME, String.new(json))
      {@service_url, headers}
    end

    # Start a managed websocket CDP client.
    def client : Rod::Lib::Cdp::Client
      url, headers = client_header
      ws = Rod::Lib::Cdp::WebSocket.new
      ws.connect(url, headers)
      Rod::Lib::Cdp::Client.new.start(ws)
    end

    # MustClient variant.
    def must_client : Rod::Lib::Cdp::Client
      client
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
      raise ERR_ALREADY_LAUNCHED if @is_launched
      @is_launched = true

      # Respect explicit --bin when provided; otherwise fallback to managed browser.
      bin_path = if explicit_bin = get(Flags::BIN)
                   if explicit_bin.empty?
                     @browser.must_get
                   else
                     unless File.exists?(explicit_bin)
                       raise "Browser executable not found: #{explicit_bin}"
                     end
                     explicit_bin
                   end
                 else
                   @browser.must_get
                 end

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
          return ::Rod::Lib::Launcher.resolve_url(port)
        rescue
          # Browser not running on that port, continue to launch
        end
      end

      ll : Rod::Lib::Leakless::Launcher? = nil
      process : Process
      parser = Rod::Lib::URLParser.new
      if ctx = @ctx
        parser.context(ctx)
      end

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
        # Launch new process with output piped to parser
        process = Process.new(bin_path, args, env_hash, false, false, Process::Redirect::Close, parser, parser, working_dir_or_nil)
        @pid = process.pid.to_i32
      end

      # Create exit channel
      @exit = Channel(Nil).new

      # Monitor process exit in background
      spawn do
        process.wait
        @exit.try(&.close)
      end

      # Get WebSocket URL from parser channel
      if done = @exit
        select
        when ws_url = parser.url.receive
          ws_url
        when done.receive?
          raise parser.error
        when timeout 10.seconds
          raise parser.error
        end
      else
        select
        when ws_url = parser.url.receive
          ws_url
        when timeout 10.seconds
          raise parser.error
        end
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
      # Give browser time to start children processes
      sleep 1.second

      return if @pid == 0

      # Try to kill process group
      {% if flag?(:unix) %}
        # On Unix, negative PID kills process group
        Process.signal(Signal::TERM, -@pid) rescue nil
        Process.signal(Signal::KILL, -@pid) rescue nil
        # Go parity: also kill the browser PID directly as a fallback.
        Process.signal(Signal::TERM, @pid) rescue nil
        Process.signal(Signal::KILL, @pid) rescue nil
      {% else %}
        # On Windows, positive PID kills process
        Process.signal(Signal::TERM, @pid) rescue nil
        Process.signal(Signal::KILL, @pid) rescue nil
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

    private def working_dir_or_nil : String?
      dir = get(Flags::WORKING_DIR)
      return nil if dir.nil? || dir.empty?
      dir
    end

    private def env_hash : Hash(String, String)?
      values = @flags[Flags::ENV]?
      return nil if values.nil? || values.empty?

      env = {} of String => String
      values.each do |entry|
        next if entry.empty?
        parts = entry.split("=", 2)
        key = parts[0]? || ""
        next if key.empty?
        val = parts[1]? || ""
        env[key] = val
      end
      env
    end

    def mark_managed!(service_url : String) : self
      @managed = true
      @service_url = service_url
      self
    end

    def load_flags_json(json : String) : self
      parsed = JSON.parse(json)
      flags_any = parsed["flags"]?
      return self unless flags_any

      @flags.clear
      flags_any.as_h.each do |k, v|
        if v.raw.nil?
          @flags[k] = [] of String
        else
          @flags[k] = v.as_a.map(&.as_s)
        end
      end
      self
    end

    private def to_manager_json : Hash(String, Hash(String, JSON::Any))
      out = {} of String => JSON::Any
      @flags.each do |k, v|
        if v.empty?
          out[k] = JSON::Any.new(nil)
        else
          out[k] = JSON::Any.new(v.map { |item| JSON::Any.new(item) })
        end
      end
      {"flags" => out}
    end

    private def must_managed! : Nil
      raise "Must be used with launcher.new_managed" unless @managed
    end
  end

  # Manager serves launcher defaults and remote launch endpoints.
  class Manager
    include HTTP::Handler

    property logger : ::Log
    property defaults : HTTP::Server::Context -> Launcher
    property before_launch : Launcher, HTTP::Server::Context -> Nil

    def initialize
      @logger = ::Log.for("rod.launcher.manager")
      @defaults = ->(_ctx : HTTP::Server::Context) { Launcher.new }

      working_dir = Dir.current
      @before_launch = ->(launcher : Launcher, ctx : HTTP::Server::Context) {
        {
          Flags::BIN           => ::Rod::Lib::Launcher.default_browser_dir,
          Flags::WORKING_DIR   => working_dir,
          Flags::USER_DATA_DIR => Launcher::DEFAULT_USER_DATA_DIR_PREFIX,
        }.each do |flag, allowed|
          if value = launcher.get(flag)
            next if value.empty?
            next if value.starts_with?(allowed)

            msg = "[rod-manager] not allowed #{flag} path: #{value} (use --allow-all to disable the protection)"
            ctx.response.status_code = 400
            ctx.response.content_type = "text/plain"
            ctx.response.print(msg)
            return nil
          end
        end
        nil
      }
    end

    def call(context : HTTP::Server::Context) : Nil
      if context.request.headers["Upgrade"]?.try(&.downcase) == "websocket"
        options = context.request.headers[HEADER_NAME]?
        unless options
          context.response.status_code = 501
          context.response.print("[rod-manager] websocket launch not implemented")
          return
        end

        launcher = Launcher.new
        launcher.flags.clear
        launcher.load_flags_json(options)
        @before_launch.call(launcher, context)
        return if context.response.status_code == 400

        handler = HTTP::WebSocketHandler.new do |client_ws, _ws_ctx|
          begin
            upstream_url = launcher.launch
            upstream_ws = HTTP::WebSocket.new(upstream_url)

            client_ws.on_message do |message|
              begin
                upstream_ws.send(message)
              rescue
              end
            end

            client_ws.on_binary do |message|
              begin
                upstream_ws.send(message)
              rescue
              end
            end

            client_ws.on_close do |_code, _reason|
              begin
                upstream_ws.close
              rescue
              end
              begin
                launcher.kill
              rescue
              end
            end

            upstream_ws.on_message do |message|
              begin
                client_ws.send(message)
              rescue
              end
            end

            upstream_ws.on_binary do |message|
              begin
                client_ws.send(message)
              rescue
              end
            end

            upstream_ws.on_close do |_code, _reason|
              begin
                client_ws.close
              rescue
              end
              begin
                launcher.kill
              rescue
              end
            end

            spawn do
              begin
                upstream_ws.run
              rescue
              ensure
                begin
                  launcher.kill
                rescue
                end
              end
            end
          rescue
            begin
              client_ws.close
            rescue
            end
            begin
              launcher.kill
            rescue
            end
          end
        end

        handler.call(context)
        return
      end

      launcher = @defaults.call(context)
      context.response.content_type = "application/json"
      context.response.print(String.new(launcher.json))
    end
  end
end
