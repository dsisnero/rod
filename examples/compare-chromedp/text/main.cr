require "../../../src/rod"

page = Rod::Browser.new.must_connect.must_page("https://pkg.go.dev/time")
res = page.must_element("#pkg-overview").must_parent.must_text
puts res.strip
