require "../../src/rod"

# Ported from `vendor/rod/lib/examples/custom-launch/main.go`: let the launcher
# start a browser (instead of connecting to one you started), then drive it.
# See `Rod::Util::Launcher::Launcher` for the available flags.
launcher = Rod::Util::Launcher.new
url = launcher.launch

begin
  browser = Rod::Browser.new.control_url(url).must_connect
  page = browser.must_page("http://example.com").must_wait_stable
  puts page.must_info.title
ensure
  launcher.cleanup
end
