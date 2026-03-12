require "../../../src/rod"

Rod::Browser.new.must_connect.must_page("https://www.google.com/").must_wait_load.must_pdf("sample.pdf")
puts "wrote sample.pdf"
