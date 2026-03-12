require "../../../src/rod"
require "http/server"

private UPLOAD_HTML = <<-HTML
<!doctype html>
<html><body>
<form method="POST" action="/upload" enctype="multipart/form-data">
  <input name="upload" type="file"/>
  <input name="submit" type="submit"/>
</form>
</body></html>
HTML

private RESULT_HTML = <<-HTML
<!doctype html>
<html><body><div id="result">%d</div></body></html>
HTML

def size(path : String) : Int32
  File.size(path).to_i
end

def upload_server : String
  server = HTTP::Server.new do |ctx|
    if ctx.request.path == "/"
      ctx.response.print(UPLOAD_HTML)
      next
    end

    if ctx.request.path == "/upload" && ctx.request.method == "POST"
      body = ctx.request.body.try(&.gets_to_end) || ""
      ctx.response.print(RESULT_HTML % body.bytesize)
    else
      ctx.response.status_code = 404
    end
  end

  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }
  "http://127.0.0.1:#{addr.port}"
end

host = upload_server
page = Rod::Browser.new.must_connect.must_page(host)
path = "vendor/rod/lib/examples/compare-chromedp/upload/main.go"
page.must_element("input[name=\"upload\"]").must_set_files([path])
page.must_element("input[name=\"submit\"]").must_click

Log.info { "original size: #{size(path)}, upload size: #{page.must_element("#result").must_text}" }
