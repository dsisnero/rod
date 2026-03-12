require "../../src/rod"

u = Rod::Lib::Launcher.must_resolve_url("")
browser = Rod::Browser.new.control_url(u).must_connect
puts browser.must_page("https://mdn.dev/").must_eval("() => document.title")
