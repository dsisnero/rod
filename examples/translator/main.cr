require "../../src/rod"

source = ARGV.join(" ").strip
raise "usage: crystal run examples/translator/main.cr -- 'This is the phrase to translate to Spanish.'" if source.empty?

browser = Rod::Browser.new.connect!
page = browser.page!("https://translate.google.com/?sl=auto&tl=es&op=translate")
el = page.element!("textarea[aria-label=\"Source text\"]")
wait = page.wait_request_idle(300.milliseconds, ["https://accounts.google.com"], [] of String, nil)
el.input!(source)
wait.call
result = page.element!("[role=region] span[lang]").text!
puts result
