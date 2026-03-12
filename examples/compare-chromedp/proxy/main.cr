require "../../../src/rod"
require "../../../src/rod/lib/examples/compare_chromedp_proxy"
require "http/server"

# Proxy auth in Crystal stdlib differs from Go net/http. This keeps parity for
# transport failure behavior demonstrated by upstream example.
transport = Rod::Lib::Examples::CompareChromedpProxy::Transport.new do |_request|
  HTTP::Client::Response.new(200)
end

request = HTTP::Request.new("GET", "http://example.test")
request.headers["X-Failed"] = "407"
begin
  transport.round_trip(request)
rescue ex
  Log.warn { "proxy: not authorized (#{ex.message})" }
end

browser = Rod::Browser.new.must_connect
browser.must_ignore_cert_errors(true)
page = browser.must_page("https://example.com")
page.must_wait_load
