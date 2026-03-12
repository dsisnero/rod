require "../../../src/rod"

ws_url = ENV["DEVTOOLS_WS_URL"]? || ARGV[0]?
raise "must specify DEVTOOLS_WS_URL or pass websocket url as argv[0]" if ws_url.nil? || ws_url.empty?

page = Rod::Browser.new.control_url(ws_url).must_connect.must_page("https://duckduckgo.com")
page.must_element("#logo_homepage_link").must_wait_visible

html = page.must_html
Log.info { "Body of duckduckgo.com starts with:" }
Log.info { html[0, Math.min(100, html.size)] }
