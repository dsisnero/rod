require "../../src/rod"

source = ARGV.join(" ").strip
raise "usage: crystal run examples/translator/main.cr -- 'This is the phrase to translate to Spanish.'" if source.empty?

browser = Rod::Browser.new.must_connect
page = browser.must_page("https://translate.google.com/?sl=auto&tl=es&op=translate")
el = page.must_element("textarea[aria-label=\"Source text\"]")
wait = page.wait_request_idle(300.milliseconds, ["https://accounts.google.com"], [] of String, nil)
el.must_input(source)
wait.call
result = page.must_element("[role=region] span[lang]").must_text
puts result
