require "../../../src/rod"

page = Rod::Browser.new.connect!.page!("https://github.com/search")
page.element!("input[name=q]").wait_visible!.input!("chromedp").type!(Rod::Input::ENTER)
res = page.element_r!("a", "chromedp").parent!.parent!.next!.text!
puts "got: `#{res.strip}`"
