require "../../../src/rod"

res = Rod::Browser.new.connect!
  .page!("https://www.google.com/")
  .element!("input")
  .eval!("() => Object.keys(window)")

puts "window object keys: #{res}"
