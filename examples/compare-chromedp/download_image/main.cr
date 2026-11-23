require "../../../src/rod"

url = "https://avatars.githubusercontent.com/u/33149672"
browser = Rod::Browser.new.connect!
page = browser.page!(url).wait_load!

bytes = page.get_resource(url)
File.write("download.png", bytes)
puts "wrote download.png"
