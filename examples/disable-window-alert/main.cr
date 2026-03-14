require "../../src/rod"
require "http/server"

private TEST_PAGE = %(<html><script>alert("message")</script></html>)

def serve
  server = HTTP::Server.new(&.response.print(TEST_PAGE))
  server.bind_tcp("127.0.0.1", 8080)
  server.listen
end

spawn { serve }

browser = Rod::Browser.new.must_connect
page = browser.must_page
page.must_eval_on_new_document("window.alert = () => {}")
page.must_navigate("http://localhost:8080")
puts page.must_element("script").must_text
