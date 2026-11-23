require "../../../src/rod"

page = Rod::Browser.new.connect!.page!("https://pkg.go.dev/time")
res = page.element!("#pkg-overview").parent!.text!
puts res.strip
