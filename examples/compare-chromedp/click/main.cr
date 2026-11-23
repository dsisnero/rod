require "../../../src/rod"

# `trace(true)` logs what rod is doing, like the upstream example
# (`Trace(true)` in its chained call); each span is a `[wait]`/`[input]` line.
page = Rod::Browser.new
  .must_connect
  .trace(true)
  .timeout(15.seconds)
  .must_page("https://pkg.go.dev/time/")

page.must_element("body > footer").must_wait_visible
page.must_element("#pkg-examples").must_click
example = page.must_element("#example-After textarea").must_text

puts "Go's time.After example:\n#{example}"
