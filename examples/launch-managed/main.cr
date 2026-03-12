require "../../src/rod"

launcher = Rod::Lib::Launcher.must_new_managed("")
launcher.set("disable-gpu").delete("disable-gpu")
launcher.headless(false).xvfb("--server-num=5", "--server-args=-screen 0 1600x900x16")

browser = Rod::Browser.new.client(launcher.must_client).must_connect
Rod::Lib::Launcher.open(browser.serve_monitor(""))
puts browser.must_page("https://developer.mozilla.org").must_eval("() => document.title")

launcher2 = Rod::Lib::Launcher.must_new_managed("")
launcher2.set("disable-sync").delete("disable-sync")
another = Rod::Browser.new.client(launcher2.must_client).must_connect
puts another.must_page("https://go-rod.github.io").must_eval("() => document.title")
Rod::Lib::Utils.pause
