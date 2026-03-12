require "../../../src/rod"

page = Rod::Browser.new.must_connect.timeout(15.seconds).must_page("https://github.com/avelino/awesome-go")
section = page.must_element_r("p", "Selenium and browser control tools").must_next
projects = section.must_elements("li")

projects.each do |project|
  link = project.must_element("a")
  Log.info { "project #{link.must_text} (#{link.must_property("href")}): '#{project.must_text}'" }
end
