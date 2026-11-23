require "../../../src/rod"

page = Rod::Browser.new.connect!.timeout(15.seconds).page!("https://github.com/avelino/awesome-go")
section = page.element_r!("p", "Selenium and browser control tools").next!
projects = section.elements!("li")

projects.each do |project|
  link = project.element!("a")
  puts "project #{link.text!} (#{link.property!("href")}): '#{project.text!}'"
end
