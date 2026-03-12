require "../../../src/rod"

browser = Rod::Browser.new.must_connect
browser.must_page("https://google.com").must_element("body div").must_screenshot("elementScreenshot.png")

req = Cdp::Page::CaptureScreenshot.new(
  format: Cdp::Page::CaptureScreenshotFormatJpeg,
  quality: 90_i64,
  clip: nil,
  from_surface: true,
  capture_beyond_viewport: true,
  optimize_for_speed: false
)
buf = browser.must_page("https://brank.as/").screenshot(true, req)
File.write("fullScreenshot.png", buf)
