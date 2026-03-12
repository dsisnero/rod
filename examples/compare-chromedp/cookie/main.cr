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

def cookie_server : String
  server = HTTP::Server.new do |context|
    cookies = context.request.cookies
    cookies.each_with_index do |cookie, i|
      Log.info { "from #{context.request.remote_address}, server received cookie #{i}: #{cookie}" }
    end
    cookie_data = cookies.map do |cookie|
      {
        "name"   => cookie.name,
        "value"  => cookie.value,
        "path"   => cookie.path,
        "domain" => cookie.domain,
      }
    end
    context.response.content_type = "text/html"
    context.response.print(INDEX_HTML % cookie_data.to_json)
  end
  addr = server.bind_tcp("127.0.0.1", 0)
  spawn { server.listen }
  "http://127.0.0.1:#{addr.port}"
end

expires = Cdp::Network.time_since_epoch_from_now(180.days)

cookie1 = Cdp::Network::CookieParam.from_json({
  "name"     => "cookie1",
  "value"    => "value1",
  "domain"   => "127.0.0.1",
  "httpOnly" => true,
  "expires"  => expires,
}.to_json)

cookie2 = Cdp::Network::CookieParam.from_json({
  "name"     => "cookie2",
  "value"    => "value2",
  "domain"   => "127.0.0.1",
  "httpOnly" => true,
  "expires"  => expires,
}.to_json)

page = Rod::Browser.new.must_connect.must_page
page.must_set_cookies([cookie1, cookie2])

page.must_navigate(cookie_server)
page.must_cookies.each_with_index do |cookie, i|
  Log.info { "chrome cookie #{i}: #{cookie}" }
end
Log.info { "chrome received cookies: #{page.must_element("#result").must_text}" }
