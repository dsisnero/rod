require "../../../src/rod"
require "http/server"
require "json"

private INDEX_HTML = <<-HTML
<!doctype html>
<html>
<body>
  <div id="result">%s</div>
</body>
</html>
HTML

def header_server : String
  server = HTTP::Server.new do |context|
    context.response.content_type = "text/html"
    context.response.print(INDEX_HTML % context.request.headers.to_h.to_json)
  end
  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }
  "http://127.0.0.1:#{addr.port}"
end

host = header_server
page = Rod::Browser.new.must_connect.must_page(host)
cleanup = page.must_set_extra_headers(["X-Header", "my request header"])
page.must_navigate(host)
Log.info { "received headers: #{page.must_element("#result").must_text}" }
cleanup.call
