require "../../../src/rod"

# Ported from `vendor/rod/lib/examples/compare-chromedp/emulate/main.go`.
page = Rod::Browser.new.connect!.page!

# Emulate an iPhone 6/7/8 in landscape.
page.emulate!(Rod::Util::Devices::IPhone6or7or8.landscape)
page.navigate!("https://www.whatsmyua.info/")
page.screenshot!("screenshot1.png")

# Reset the emulation and set a plain viewport instead.
page.emulate!(Rod::Util::Devices::Clear)
page.set_viewport!(1920, 2000, 1.0, false)
page.navigate!("https://www.whatsmyua.info/?a")
page.screenshot!("screenshot2.png")
