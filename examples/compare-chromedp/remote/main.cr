require "../../../src/rod"

ws_url = ENV["DEVTOOLS_WS_URL"]? || ARGV[0]?
raise "must specify DEVTOOLS_WS_URL or pass websocket url as argv[0]" if ws_url.nil? || ws_url.empty?

page = Rod::Browser.new.control_url(ws_url).connect!.page!("https://duckduckgo.com")
page.element!("#logo_homepage_link").wait_visible!

html = page.html!
puts "Body of duckduckgo.com starts with:"
puts html[0, Math.min(100, html.size)]
