require "../../src/rod"

# Ported from `vendor/rod/lib/examples/connect-browser/main.go`.
#
# To manually launch a browser first:
#
#     chrome --headless --remote-debugging-port=9222
#
# Or use docker:
#
#     docker run -p 9222:9222 ghcr.io/go-rod/rod chrome --headless --no-sandbox --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0
url = Rod::Util::Launcher.resolve_url!("")
browser = Rod::Browser.new.control_url(url).connect!

puts browser.page!("https://mdn.dev/").eval!("() => document.title")
