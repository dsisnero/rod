require "../../../src/rod"

page = Rod::Browser.new
  .must_connect
  .trace(false)
  .timeout(15.seconds)
  .must_page("https://pkg.go.dev/time/")

page.must_element("body > footer").must_wait_visible
page.must_element("#pkg-examples").must_click
example = page.must_element("#example-After textarea").must_text

Log.info { "Go's time.After example:\n#{example}" }
