require "../../../src/rod"

# Ported from `vendor/rod/lib/examples/compare-chromedp/emulate/main.go`.
page = Rod::Browser.new.must_connect.must_page

# Emulate an iPhone 6/7/8 in landscape.
page.must_emulate(Rod::Util::Devices::IPhone6or7or8.landscape)
page.must_navigate("https://www.whatsmyua.info/")
page.must_screenshot("screenshot1.png")

# Reset the emulation and set a plain viewport instead.
page.must_emulate(Rod::Util::Devices::Clear)
page.must_set_viewport(1920, 2000, 1.0, false)
page.must_navigate("https://www.whatsmyua.info/?a")
page.must_screenshot("screenshot2.png")
