require "../../src/rod"

launcher = Rod::Lib::Launcher.new
url = launcher.launch
browser = Rod::Browser.new.control_url(url).must_connect
page = browser.must_page("http://example.com").must_wait_stable
puts page.must_info.title
