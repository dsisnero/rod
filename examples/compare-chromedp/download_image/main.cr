require "../../../src/rod"

url = "https://avatars.githubusercontent.com/u/33149672"
browser = Rod::Browser.new.must_connect
page = browser.must_page(url).must_wait_load

bytes = page.get_resource(url)
File.write("download.png", bytes)
Log.info { "wrote download.png" }
