require "../../../src/rod"
require "http/server"

private MAKE_VISIBLE_SCRIPT = <<-JS
() => setTimeout(function() {
  document.querySelector('#box1').style.display = '';
}, 3000)
JS

private INDEX_HTML = <<-HTML
<!doctype html>
<html>
<head><title>example</title></head>
<body>
  <div id="box1" style="display:none"><div id="box2"><p>box2</p></div></div>
</body>
</html>
HTML

def test_server : String
  server = HTTP::Server.new { |ctx| ctx.response.print(INDEX_HTML) }
  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }
  "http://127.0.0.1:#{addr.port}"
end

page = Rod::Browser.new.must_connect.must_page(test_server)
page.must_eval(MAKE_VISIBLE_SCRIPT)
Log.info { "waiting 3s for box to become visible" }
page.must_element("#box1").must_wait_visible
Log.info { ">>>>>>>>>>>>>>>>>>>> BOX1 IS VISIBLE" }
page.must_element("#box2").must_wait_visible
Log.info { ">>>>>>>>>>>>>>>>>>>> BOX2 IS VISIBLE" }
