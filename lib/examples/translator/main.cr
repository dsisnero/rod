require "../../../src/rod"

source = ARGV.join(" ").strip
if source.empty?
  STDERR.puts("usage: crystal run lib/examples/translator/main.cr -- 'This is the phrase to translate to Spanish.'")
  exit(1)
end

browser = Rod::Browser.new
begin
  browser.must_connect
  page = browser.must_page("https://translate.google.com/?sl=auto&tl=es&op=translate")

  input = page.must_element(%(textarea[aria-label="Source text"]))
  wait = page.must_wait_request_idle(["https://accounts.google.com"])
  input.must_input(source)
  wait.call

  result = page.must_element("[role=region] span[lang]").must_text
  puts(result)
ensure
  begin
    browser.close
  rescue
  end
end
