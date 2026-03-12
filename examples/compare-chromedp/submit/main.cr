require "../../../src/rod"

page = Rod::Browser.new.must_connect.must_page("https://github.com/search")
page.must_element("input[name=q]").must_wait_visible.must_input("chromedp").must_type(Rod::Input::ENTER)
res = page.must_element_r("a", "chromedp").must_parent.must_parent.must_next.must_text
Log.info { "got: `#{res.strip}`" }
