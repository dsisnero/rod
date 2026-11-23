require "../../../src/rod"

Rod::Browser.new.connect!.page!("https://www.google.com/").wait_load!.pdf!("sample.pdf")
puts "wrote sample.pdf"
