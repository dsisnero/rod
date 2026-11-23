require "../../src/rod"
require "http/server"

private TEST_PAGE = %(<html><script>alert("message")</script></html>)

def serve
  server = HTTP::Server.new(&.response.print(TEST_PAGE))
  server.bind_tcp("127.0.0.1", 8080)
  server.listen
end

spawn { serve }

browser = Rod::Browser.new.connect!
page = browser.page!
page.eval_on_new_document!("window.alert = () => {}")
page.navigate!("http://localhost:8080")
puts page.element!("script").text!
