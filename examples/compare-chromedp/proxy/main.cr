require "../../../src/rod"
require "http/server"

# Ported from `vendor/rod/lib/examples/compare-chromedp/proxy/main.go`: the
# browser talks to a proxy that requires credentials, and `Browser#handle_auth`
# answers the 407 challenge.
#
# The proxy answers the absolute-URI request itself, so Chrome needs no DNS for
# `proxy-test.invalid` — it hands the request straight to the proxy, which is
# what makes this example runnable offline.
proxy = HTTP::Server.new do |context|
  request = context.request
  # Chrome tunnels HTTPS through CONNECT; this example only shows plain HTTP.
  if request.method == "CONNECT"
    context.response.status_code = 502
    next
  end

  # Hardcoded username/password "u:p" (base64 "dTpw") to keep it simple.
  if request.headers["Proxy-Authorization"]? != "Basic dTpw"
    context.response.status_code = 407
    context.response.headers["Proxy-Authenticate"] = %(Basic realm="Proxy Authorization")
    next
  end

  context.response.content_type = "text/html"
  context.response.print("<title>proxy</title><body>through the proxy</body>")
end
proxy_address = proxy.bind_tcp("127.0.0.1", 0)
spawn { proxy.listen }

launcher = Rod::Util::Launcher.new
launcher.proxy("http://127.0.0.1:#{proxy_address.port}")
url = launcher.launch

browser = Rod::Browser.new.control_url(url).must_connect
begin
  # The challenge blocks the navigation, so answer it from another fiber.
  spawn { browser.must_handle_auth("u", "p").call }

  page = browser.must_page("http://proxy-test.invalid/")
  page.must_navigate("http://proxy-test.invalid/tab")
  puts page.must_element("body").must_text
ensure
  browser.close
  launcher.cleanup
  proxy.close
end
