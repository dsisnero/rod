require "../../../src/rod"

page = Rod::Browser.new.must_connect.must_page
page.must_emulate(Rod::Lib::Devices::IPhone6or7or8.landscape)
page.must_navigate("https://www.whatsmyua.info/")
page.must_screenshot("screenshot1.png")

page.must_emulate(Rod::Lib::Devices::Clear)
page.must_set_viewport(1920, 2000, 1.0, false)
page.must_navigate("https://www.whatsmyua.info/?a")
page.must_screenshot("screenshot2.png")
