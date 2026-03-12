require "../../src/rod"

ws = Rod::Lib::Examples::CustomWebsocket::WebSocket.new_web_socket(Rod::Lib::Launcher.new.launch)
client = Rod::Lib::Cdp::Client.new.start(ws)
page = Rod::Browser.new.client(client).must_connect.must_page("http://example.com")
puts page.must_info.title
