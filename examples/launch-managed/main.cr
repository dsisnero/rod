require "../../src/rod"

# Ported from `vendor/rod/lib/examples/launch-managed/main.go`.
#
# This launches a browser *remotely* through a `launcher manager` service, not a
# browser that is already running (for that see `../connect-browser`):
#
#     docker run --rm -p 7317:7317 ghcr.io/go-rod/rod
#
# For the available CLI flags run `docker run --rm ghcr.io/go-rod/rod rod-manager -h`.
launcher = Rod::Util::Launcher.new_managed!("")

# Flags can be set remotely before the browser starts.
# Available flags: https://peter.sh/experiments/chromium-command-line-switches
launcher.set("disable-gpu").delete("disable-gpu")

# Launch with headful mode behind Xvfb.
launcher.headless(false).xvfb("--server-num=5", "--server-args=-screen 0 1600x900x16")

browser = Rod::Browser.new.client(launcher.client!).connect!

# Start a server to watch the remote browser's screenshots.
Rod::Util::Launcher.open(browser.serve_monitor(""))
puts browser.page!("https://developer.mozilla.org").eval!("() => document.title")

# Launch another browser from the same container with different flags.
another_launcher = Rod::Util::Launcher.new_managed!("")
another_launcher.set("disable-sync").delete("disable-sync")
another = Rod::Browser.new.client(another_launcher.client!).connect!
puts another.page!("https://go-rod.github.io").eval!("() => document.title")

Rod::Util::Utils.pause
