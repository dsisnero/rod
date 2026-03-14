require "../../../src/rod"
require "http/server"

private INDEX_HTML = <<-HTML
<!doctype html>
<html>
<head><title>example</title></head>
<body>
  <div id="box1" style="display:none"><div id="box2"><p>box2</p></div></div>
  <div id="box3"><h2>box3</h2><p id="box4">box4 text
    <input id="input1" value="some value"><br><br>
    <textarea id="textarea1" style="width:500px;height:400px">textarea</textarea><br><br>
    <input id="input2" type="submit" value="Next">
    <select id="select1">
      <option value="one">1</option><option value="two">2</option><option value="three">3</option><option value="four">4</option>
    </select>
  </p></div>
</body>
</html>
HTML

def test_server : String
  server = HTTP::Server.new(&.response.print(INDEX_HTML))
  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }
  "http://127.0.0.1:#{addr.port}"
end

page = Rod::Browser.new.must_connect.must_page(test_server)
val1 = page.must_element("#input1").must_text
val2 = page.must_element("#textarea1").must_input("\b\b\n\naoeu\n\ntest1\n\nblah2\n\n\t\t\t\b\bother box!\t\ntest4").must_text
val3 = page.must_element("#input2").must_input("test3").must_text
val4 = page.must_element("#select1").must_type(Rod::Input::ARROW_DOWN, Rod::Input::ARROW_DOWN).must_property("value").to_s

Log.info { "#input1 value: #{val1}" }
Log.info { "#textarea1 value: #{val2}" }
Log.info { "#input2 value: #{val3}" }
Log.info { "#select1 value: #{val4}" }
