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
  server = HTTP::Server.new(&.response.print(INDEX_HTML))
  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }
  "http://127.0.0.1:#{addr.port}"
end

page = Rod::Browser.new.connect!.page!(test_server)
page.eval!(MAKE_VISIBLE_SCRIPT)
puts "waiting 3s for box to become visible"
page.element!("#box1").wait_visible!
puts ">>>>>>>>>>>>>>>>>>>> BOX1 IS VISIBLE"
page.element!("#box2").wait_visible!
puts ">>>>>>>>>>>>>>>>>>>> BOX2 IS VISIBLE"
