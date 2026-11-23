require "../../../src/rod"

browser = Rod::Browser.new.connect!
browser.page!("https://google.com").element!("body div").screenshot!("elementScreenshot.png")

req = Cdp::Page::CaptureScreenshot.new(
  format: Cdp::Page::CaptureScreenshotFormatJpeg,
  quality: 90_i64,
  clip: nil,
  from_surface: true,
  capture_beyond_viewport: true,
  optimize_for_speed: false
)
buf = browser.page!("https://brank.as/").screenshot(true, req)
File.write("fullScreenshot.png", buf)
