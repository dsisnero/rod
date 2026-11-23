require "../../../src/rod"

# `trace(true)` logs what rod is doing, like the upstream example
# (`Trace(true)` in its chained call); each span is a `[wait]`/`[input]` line.
page = Rod::Browser.new
  .connect!
  .trace(true)
  .timeout(15.seconds)
  .page!("https://pkg.go.dev/time/")

page.element!("body > footer").wait_visible!
page.element!("#pkg-examples").click!
example = page.element!("#example-After textarea").text!

puts "Go's time.After example:\n#{example}"
