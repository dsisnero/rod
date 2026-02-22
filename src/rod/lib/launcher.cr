require "http/client"
require "file"
require "file_utils"
require "digest"
require "process"
require "json"

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
      # TODO: Implement lock port to prevent race downloading
      validate
      bin_path
    rescue
      # Try to cleanup before downloading
      FileUtils.rm_rf(dir) if Dir.exists?(dir)
      download
      bin_path
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

    def initialize(
      @flags = {} of String => Array(String),
      @logger = ::Log.for("rod.launcher"),
      @browser = Browser.new,
    )
    end

    # Launch browser and return WebSocket URL.
    def launch : String
      # TODO: Implement actual browser launching
      "ws://localhost:9222/devtools/browser/..."
    end

    # Launch and connect to browser.
    def launch_and_connect : Rod::Browser
      ws_url = launch
      browser = Rod::Browser.new
      browser.connect(ws_url)
      browser
    end
  end
end
