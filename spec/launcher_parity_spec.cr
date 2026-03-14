require "./spec_helper"
require "http/server"

private CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

private def with_version_server(&)
  server = HTTP::Server.new do |ctx|
    if ctx.request.path == "/json/version"
      ctx.response.content_type = "application/json"
      ctx.response.print(%({"webSocketDebuggerUrl":"ws://127.0.0.1:9222/devtools/browser/id"}))
    else
      ctx.response.status_code = 404
    end
  end

  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }

  begin
    yield addr.port
  ensure
    server.close
  end
end

private def with_managed_defaults_server(body : String, &)
  server = HTTP::Server.new do |ctx|
    ctx.response.content_type = "application/json"
    ctx.response.print(body)
  end

  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }

  begin
    yield addr.port
  ensure
    server.close
  end
end

private def with_launcher_manager_server(manager : Rod::Util::Launcher::Manager, &)
  server = HTTP::Server.new([manager])
  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }

  begin
    yield addr.port
  ensure
    server.close
  end
end

private def with_plain_http_server(body : String, &)
  server = HTTP::Server.new do |ctx|
    ctx.response.content_type = "text/plain"
    ctx.response.print(body)
  end

  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }

  begin
    yield addr.port
  ensure
    server.close
  end
end

private def with_bytes_http_server(payload : Bytes, &)
  server = HTTP::Server.new do |ctx|
    ctx.response.content_type = "application/zip"
    ctx.response.write(payload)
  end

  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }

  begin
    yield addr.port
  ensure
    server.close
  end
end

class Rod::Util::Launcher::Launcher
  def __mark_launched!
    @is_launched = true
  end

  def __setup_user_preferences_for_test!
    setup_user_preferences
  end
end

describe "launcher parity" do
  it "formats download host URLs for default revision" do
    Rod::Util::Launcher.host_google(Rod::Util::Launcher::REVISION_DEFAULT).should contain("https://storage.googleapis.com/chromium-browser-snapshots")
    Rod::Util::Launcher.host_npm(Rod::Util::Launcher::REVISION_DEFAULT).should contain("https://registry.npmmirror.com/-/binary/chromium-browser-snapshots")
    Rod::Util::Launcher.host_playwright(Rod::Util::Launcher::REVISION_DEFAULT).should contain("https://playwright.azureedge.net/")
  end

  it "normalizes [::] to [::1] when opening URLs" do
    original_provider = Rod::Util::Launcher.look_path_provider
    original_runner = Rod::Util::Launcher.open_runner
    seen = [] of String

    begin
      Rod::Util::Launcher.look_path_provider = -> { {"/bin/echo".as(String?), true} }
      Rod::Util::Launcher.open_runner = ->(_bin : String, args : Array(String)) {
        seen.concat(args)
        nil
      }

      Rod::Util::Launcher.open("http://[::]/a")
      seen.should eq(["http://[::1]/a"])
    ensure
      Rod::Util::Launcher.look_path_provider = original_provider
      Rod::Util::Launcher.open_runner = original_runner
    end
  end

  it "converts ws/http uri schemes like go launcher utils" do
    u = URI.parse("wss://a.com")
    Rod::Util::Launcher.to_http(u).scheme.should eq("https")

    u = URI.parse("ws://a.com")
    Rod::Util::Launcher.to_http(u).scheme.should eq("http")

    u = URI.parse("https://a.com")
    Rod::Util::Launcher.to_ws(u).scheme.should eq("wss")

    u = URI.parse("http://a.com")
    Rod::Util::Launcher.to_ws(u).scheme.should eq("ws")
  end

  it "resolves url from multiple input formats" do
    with_version_server do |port|
      [
        port.to_s,
        ":#{port}",
        "127.0.0.1:#{port}",
        "ws://127.0.0.1:#{port}",
      ].each do |u|
        out = Rod::Util::Launcher.resolve_url(u)
        out.should eq("ws://127.0.0.1:#{port}/devtools/browser/id")
      end
    end
  end

  it "matches TestLaunch live launch behavior" do
    l = Rod::Util::Launcher.new
      .bin(CHROME_BIN)
      .leakless(false)
      .preferences("")
      .always_open_pdf_externally
    begin
      u = l.launch
      u.should match(/\Aws:\/\/.+\z/)

      parsed = URI.parse(u)
      port = parsed.port
      port.should_not be_nil
      p = port.not_nil!

      ["#{p}", ":#{p}", "127.0.0.1:#{p}", "ws://127.0.0.1:#{p}"].each do |prefix|
        out = Rod::Util::Launcher.resolve_url(prefix)
        out.should eq(u)
      end
    ensure
      l.kill
    end
  end

  it "raises for malformed resolve_url input" do
    expect_raises(Exception) { Rod::Util::Launcher.resolve_url("1://") }
  end

  it "builds ignore-certificate-errors-spki-list from public-key pem blocks" do
    test_data = [
      <<-PEM,
        -----BEGIN PUBLIC KEY-----
        MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgF9pr2zok5bivQIEUN7Y58a9uB1o
        sroMt3hxNfzOh/G+sXgYPPoEl2/Ys/2zbvym7Ze0eGbb6FrV8aueg89TPTNWAKlN
        N49q6S3zLG1WmI2rVYz4LtPgpg1YR9FQRIg4Ll0C02daufXgvUBGjIARH19FTw6P
        61kEhnEQxUHhdAqbAgMBAAE=
        -----END PUBLIC KEY-----
      PEM
      <<-PEM,
        -----BEGIN PUBLIC KEY-----
        MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCvBTz/TOYc66qB97OyYenSHk4T
        hAUKX5RUWZ/80o0zyJoo1dfrrwW9PlT5o4DlGMs0NSbtJ8RMQRTLZwL/zxXjiEMv
        dKFs2OrefYKANTc0e2XAtQAm3Is5Ro8AF1S4Fk+eZXr2yZtBRKXvhJ/A2bilVoSn
        fmQnyBe7dVU43NXfrQIDAQAB
        -----END PUBLIC KEY-----
      PEM
    ] of String

    l = Rod::Util::Launcher.new
    l.ignore_certs(test_data.map(&.as(String?)))

    expected = "--ignore-certificate-errors-spki-list=" + [
      "+ZqfrXb+V/36nZecO59bghHlNhiHTzImjYLnNWGUd1I=",
      "llpTCSqZ2/IKsMg4tz+o1mCkXIOdKcM6sKu9kC6o7S4=",
    ].join(",")
    l.format_args.should contain(expected)
  end

  it "raises on invalid ignore-certs key input" do
    l = Rod::Util::Launcher.new
    expect_raises(Exception, /invalid certificate key/) do
      l.ignore_certs([nil] of String?)
    end
  end

  it "loads defaults from new_managed endpoint and sets websocket service URL" do
    body = %({"flags":{"headless":null,"remote-debugging-port":["9222"],"no-startup-window":null}})
    with_managed_defaults_server(body) do |port|
      l = Rod::Util::Launcher.new_managed("http://127.0.0.1:#{port}")
      l.managed.should be_true
      l.service_url.should eq("ws://127.0.0.1:#{port}")
      l.has("headless").should be_true
      l.get("remote-debugging-port").should eq("9222")
    end
  end

  it "accepts ws service URL and still fetches defaults over http" do
    body = %({"flags":{"headless":null}})
    with_managed_defaults_server(body) do |port|
      l = Rod::Util::Launcher.new_managed("ws://127.0.0.1:#{port}")
      l.service_url.should eq("ws://127.0.0.1:#{port}")
      l.has("headless").should be_true
    end
  end

  it "must_new_managed adds disable-http2 flag" do
    body = %({"flags":{"headless":null}})
    with_managed_defaults_server(body) do |port|
      l = Rod::Util::Launcher.must_new_managed("http://127.0.0.1:#{port}")
      l.has("disable-http2").should be_true
    end
  end

  it "returns already launched error when launch is reused" do
    l = Rod::Util::Launcher.new
    l.__mark_launched!

    expect_raises(Exception, /already launched/) { l.launch }
  end

  it "matches TestLaunchErrs behavior" do
    expect_raises(Exception) do
      Rod::Util::Launcher.new.bin("echo").launch
    end

    with_plain_http_server("") do |port|
      root = File.join("tmp", "browser-from-mirror-#{Random::Secure.hex(8)}")
      begin
        l = Rod::Util::Launcher.new.bin("")
        l.browser.root_dir = root
        l.browser.hosts = [->(rev : Int32) {
          suffix = URI.parse(Rod::Util::Launcher.host_google(rev)).request_target
          "http://127.0.0.1:#{port}#{suffix}"
        }] of Rod::Util::Launcher::Host

        expect_raises(Exception) { l.launch }
      ensure
        FileUtils.rm_rf(root)
      end
    end
  end

  it "new browser lock port follows defaults" do
    Rod::Util::Defaults.reset
    Rod::Util::Defaults.parse("lock=9981")
    begin
      b = Rod::Util::Launcher::Browser.new
      b.lock_port.should eq(9981)
    ensure
      Rod::Util::Defaults.reset
    end
  end

  it "new launcher keeps internal bin flag even when value is empty" do
    Rod::Util::Defaults.reset
    l = Rod::Util::Launcher.new
    l.has(Rod::Util::Launcher::Flags::BIN).should be_true
    l.get(Rod::Util::Launcher::Flags::BIN).should eq("")
  end

  it "browser download errors when no hosts are available" do
    root = File.join(Dir.tempdir, "launcher-browser-#{Random::Secure.hex(6)}")
    begin
      b = Rod::Util::Launcher::Browser.new
      b.root_dir = root
      b.hosts = [] of Rod::Util::Launcher::Host
      expect_raises(Exception) { b.download }
    ensure
      FileUtils.rm_rf(root)
    end
  end

  it "browser download errors when host response is not a zip archive" do
    with_plain_http_server("ok") do |port|
      root = File.join(Dir.tempdir, "launcher-browser-#{Random::Secure.hex(6)}")
      begin
        b = Rod::Util::Launcher::Browser.new
        b.root_dir = root
        b.hosts = [->(_rev : Int32) { "http://127.0.0.1:#{port}/download/file" }] of Rod::Util::Launcher::Host
        expect_raises(Exception) { b.download }
      ensure
        FileUtils.rm_rf(root)
      end
    end
  end

  it "downloads and extracts browser archive, stripping top-level directory" do
    zip_bin = Process.find_executable("zip")
    zip_bin.should_not be_nil
    next unless zip_bin

    build_dir = File.join(Dir.tempdir, "launcher-zip-build-#{Random::Secure.hex(6)}")
    root = File.join(Dir.tempdir, "launcher-download-#{Random::Secure.hex(6)}")

    begin
      FileUtils.mkdir_p(File.join(build_dir, "a", "b"))
      File.write(File.join(build_dir, "a", "b", "c.txt"), "ok")

      archive = File.join(build_dir, "archive.zip")
      status = Process.run(zip_bin, ["-rq", archive, "a"], chdir: build_dir)
      status.success?.should be_true

      payload = File.read(archive).to_slice
      with_bytes_http_server(payload) do |port|
        b = Rod::Util::Launcher::Browser.new(root_dir: root, revision: 1)
        b.hosts = [->(_rev : Int32) { "http://127.0.0.1:#{port}/a.zip" }] of Rod::Util::Launcher::Host
        b.download

        File.exists?(File.join(b.dir, "b", "c.txt")).should be_true
      end
    ensure
      FileUtils.rm_rf(build_dir)
      FileUtils.rm_rf(root)
    end
  end

  it "new_manager serves default launcher JSON flags" do
    manager = Rod::Util::Launcher.new_manager
    with_launcher_manager_server(manager) do |port|
      res = HTTP::Client.get("http://127.0.0.1:#{port}")
      res.status_code.should eq(200)

      payload = JSON.parse(res.body)
      payload["flags"].as_h.size.should be > 0
      payload["flags"]["headless"].raw.should be_nil
    end
  end

  it "manager websocket endpoint returns not implemented for now" do
    manager = Rod::Util::Launcher.new_manager
    with_launcher_manager_server(manager) do |port|
      headers = HTTP::Headers{"Upgrade" => "websocket"}
      res = HTTP::Client.get("http://127.0.0.1:#{port}", headers)
      res.status_code.should eq(501)
    end
  end

  it "manager before_launch receives parsed launcher options from websocket headers" do
    manager = Rod::Util::Launcher.new_manager
    seen_disable_http2 = false
    manager.before_launch = ->(launcher : Rod::Util::Launcher::Launcher, _ctx : HTTP::Server::Context) {
      seen_disable_http2 = launcher.has("disable-http2")
      nil
    }

    with_launcher_manager_server(manager) do |port|
      header_payload = %({"flags":{"disable-http2":null}})
      headers = HTTP::Headers{
        "Upgrade"                        => "websocket",
        Rod::Util::Launcher::HEADER_NAME => header_payload,
      }
      res = HTTP::Client.get("http://127.0.0.1:#{port}", headers)
      res.status_code.should eq(404)
      seen_disable_http2.should be_true
    end
  end

  it "matches TestLaunchClient managed websocket client behavior" do
    manager = Rod::Util::Launcher.new_manager
    manager.before_launch = ->(launcher : Rod::Util::Launcher::Launcher, _ctx : HTTP::Server::Context) {
      launcher.bin(CHROME_BIN).leakless(false)
      nil
    }

    with_launcher_manager_server(manager) do |port|
      launcher = Rod::Util::Launcher.must_new_managed("http://127.0.0.1:#{port}")
        .keep_user_data_dir
        .delete(Rod::Util::Launcher::Flags::KEEP_USER_DATA_DIR)

      client = launcher.client
      version = Cdp::Browser::GetVersion.new.call(client)
      version.product.should_not be_empty
    end
  end

  it "manager rejects disallowed paths by default before launch" do
    manager = Rod::Util::Launcher.new_manager
    with_launcher_manager_server(manager) do |port|
      header_payload = %({"flags":{"rod-bin":["/tmp/not-allowed-bin"]}})
      headers = HTTP::Headers{
        "Upgrade"                        => "websocket",
        Rod::Util::Launcher::HEADER_NAME => header_payload,
      }
      res = HTTP::Client.get("http://127.0.0.1:#{port}", headers)
      res.status_code.should eq(400)
      res.body.should contain("not allowed rod-bin path")
    end
  end

  it "manager defaults hook can override returned launcher flags" do
    manager = Rod::Util::Launcher.new_manager
    manager.defaults = ->(_ctx : HTTP::Server::Context) {
      Rod::Util::Launcher.new.delete("headless")
    }

    with_launcher_manager_server(manager) do |port|
      res = HTTP::Client.get("http://127.0.0.1:#{port}")
      res.status_code.should eq(200)

      payload = JSON.parse(res.body)
      payload["flags"]["headless"]?.should be_nil
    end
  end

  it "raises for invalid or unreachable managed endpoints" do
    expect_raises(Exception) { Rod::Util::Launcher.new_managed("1://") }
    expect_raises(Exception) { Rod::Util::Launcher.new_managed("ws://127.0.0.1:1") }
  end

  it "builds client headers only for managed launchers" do
    body = %({"flags":{"headless":null}})
    with_managed_defaults_server(body) do |port|
      l = Rod::Util::Launcher.new_managed("http://127.0.0.1:#{port}")
      url, headers = l.client_header
      url.should eq("ws://127.0.0.1:#{port}")
      payload = JSON.parse(headers[Rod::Util::Launcher::HEADER_NAME])
      payload["flags"]["headless"].raw.should be_nil
    end

    expect_raises(Exception, /new_managed/) do
      Rod::Util::Launcher.new.client_header
    end
  end

  it "supports user mode and app mode defaults" do
    user = Rod::Util::Launcher.new_user_mode
    user.get(Rod::Util::Launcher::Flags::REMOTE_DEBUGGING_PORT).should eq("37712")
    user.has("no-startup-window").should be_true
    user.has(Rod::Util::Launcher::Flags::HEADLESS).should be_false
    user.has(Rod::Util::Launcher::Flags::BIN).should be_true

    app = Rod::Util::Launcher.new_app_mode("http://example.com")
    app.get(Rod::Util::Launcher::Flags::APP).should eq("http://example.com")
    app.has(Rod::Util::Launcher::Flags::HEADLESS).should be_false
    app.has("enable-automation").should be_false
  end

  it "supports logger(io) fluent API without changing chain behavior" do
    l = Rod::Util::Launcher.new
    io = IO::Memory.new
    l.logger(io).should eq(l)
  end

  it "enables no-sandbox by default in container mode" do
    previous = Rod::Util::Launcher.in_container?
    begin
      Rod::Util::Launcher.in_container = true
      l = Rod::Util::Launcher.new
      l.has(Rod::Util::Launcher::Flags::NO_SANDBOX).should be_true
    ensure
      Rod::Util::Launcher.in_container = previous
    end
  end

  it "matches go-style argument formatting for launcher toggles" do
    l = Rod::Util::Launcher.new_user_mode
    initial_dir = l.get(Rod::Util::Launcher::Flags::USER_DATA_DIR) || ""
    l = l
      .append("test-append", "a")
      .user_data_dir("test").user_data_dir(initial_dir)
      .headless_new(true).headless_new(false)
      .headless(false).headless(true)
      .remote_debugging_port(58472)
      .no_sandbox(true).no_sandbox(false)
      .devtools(true).devtools(false)
      .start_url("about:blank")
      .proxy("test.com")
      .working_dir("")
      .env("TZ=Asia/Tokyo")

    l.format_args.should eq([
      "--headless",
      "--no-startup-window",
      "--proxy-server=test.com",
      "--remote-debugging-port=58472",
      "--test-append=a",
      "about:blank",
    ])
  end

  it "matches TestLaunchUserMode live launch behavior with fixed debug port" do
    tcp = TCPServer.new("127.0.0.1", 0)
    port = tcp.local_address.as(Socket::IPAddress).port
    tcp.close

    l1 = Rod::Util::Launcher.new_user_mode
      .bin(CHROME_BIN)
      .leakless(false)
      .remote_debugging_port(port)
      .user_data_dir(File.join(Dir.tempdir, "rod-user-mode-#{Random::Secure.hex(6)}-1"))

    l2 = Rod::Util::Launcher.new_user_mode
      .bin(CHROME_BIN)
      .leakless(false)
      .remote_debugging_port(port)
      .user_data_dir(File.join(Dir.tempdir, "rod-user-mode-#{Random::Secure.hex(6)}-2"))

    begin
      u1 = l1.launch
      u2 = l2.launch
      u1.should eq(u2)
    ensure
      l1.kill
      l2.kill
    end
  end

  it "formats window size and window position flags" do
    args = Rod::Util::Launcher.new
      .window_size(1280, 720)
      .window_position(10, 20)
      .format_args

    args.should contain("--window-size=1280,720")
    args.should contain("--window-position=10,20")
  end

  it "matches TestUserModeErr launch failures for invalid bins" do
    expect_raises(Exception) do
      Rod::Util::Launcher.new_user_mode
        .remote_debugging_port(48277)
        .bin("not-exists")
        .launch
    end

    expect_raises(Exception) do
      Rod::Util::Launcher.new_user_mode
        .remote_debugging_port(58217)
        .bin("echo")
        .launch
    end
  end

  it "matches TestLaunchErr missing-binary launch branches" do
    expect_raises(Exception) do
      Rod::Util::Launcher.new
        .bin("not-exists")
        .launch
    end

    expect_raises(Exception) do
      Rod::Util::Launcher.new
        .headless(false)
        .bin("not-exists")
        .launch
    end
  end

  it "matches TestLaunchErr xvfb smoke branch" do
    l = Rod::Util::Launcher.new
      .bin(CHROME_BIN)
      .leakless(false)
      .xvfb
    begin
      begin
        l.launch
      rescue
      end
    ensure
      l.kill
    end
  end

  it "raises when set receives a flag name with equals sign" do
    expect_raises(Exception, /should not contain '='/) do
      Rod::Util::Launcher.new.set("a=b")
    end
  end

  it "writes preferences into selected profile directory" do
    dir = File.join(Dir.tempdir, "launcher-profile-#{Random::Secure.hex(6)}")
    begin
      l = Rod::Util::Launcher.new
        .user_data_dir(dir)
        .profile_dir("test-profile-dir")
        .preferences(%({"plugins":{"always_open_pdf_externally": true}}))

      l.__setup_user_preferences_for_test!

      pref_path = File.join(dir, "test-profile-dir", "Preferences")
      File.exists?(pref_path).should be_true
      File.read(pref_path).should contain("always_open_pdf_externally")
    ensure
      FileUtils.rm_rf(dir)
    end
  end

  it "validate errors when browser executable is missing" do
    root = File.join(Dir.tempdir, "launcher-validate-#{Random::Secure.hex(6)}")
    begin
      b = Rod::Util::Launcher::Browser.new(root_dir: root, revision: 0)
      expect_raises(Exception) { b.validate }
    ensure
      FileUtils.rm_rf(root)
    end
  end

  it "matches TestBrowserValid fixture-binary validation behavior" do
    go_bin = Process.find_executable("go")
    next unless go_bin

    root = File.join(Dir.tempdir, "launcher-browser-valid-#{Random::Secure.hex(6)}")
    begin
      b = Rod::Util::Launcher::Browser.new(root_dir: root, revision: 0)
      expect_raises(Exception) { b.validate }

      FileUtils.mkdir_p(File.dirname(b.bin_path))

      go_module_dir = File.expand_path("vendor/rod", Dir.current)
      exit_err_fixture = "./lib/launcher/fixtures/chrome-exit-err"
      empty_fixture = "./lib/launcher/fixtures/chrome-empty"
      lib_missing_fixture = "./lib/launcher/fixtures/chrome-lib-missing"

      Process.run(go_bin, ["build", "-o", b.bin_path, exit_err_fixture], chdir: go_module_dir).success?.should be_true
      expect_raises(Exception, /failed to run the browser/) { b.validate }

      Process.run(go_bin, ["build", "-o", b.bin_path, empty_fixture], chdir: go_module_dir).success?.should be_true
      expect_raises(Exception, "the browser executable doesn't support headless mode") { b.validate }

      Process.run(go_bin, ["build", "-o", b.bin_path, lib_missing_fixture], chdir: go_module_dir).success?.should be_true
      b.validate
    ensure
      FileUtils.rm_rf(root)
    end
  end

  it "parses launcher stderr for common failures" do
    parser = Rod::Util::URLParser.new
    parser.write("error while loading shared libraries: libx\n".to_slice)

    err = parser.error
    err.should contain("compatibility")
  end

  it "returns default debug-url error even when buffer is empty" do
    parser = Rod::Util::URLParser.new
    parser.error.should eq("[launcher] Failed to get the debug url: ")
  end
end
