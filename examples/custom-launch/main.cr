require "../../src/rod"

# Ported from `vendor/rod/lib/examples/custom-launch/main.go`: let the launcher
# start a browser (instead of connecting to one you started), then drive it.
# See `Rod::Util::Launcher::Launcher` for the available flags.
launcher = Rod::Util::Launcher.new
url = launcher.launch

begin
  browser = Rod::Browser.new.control_url(url).connect!
  page = browser.page!("http://example.com").wait_stable!
  puts page.info!.title
ensure
  launcher.cleanup
end
