require "../../../src/rod"

res = Rod::Browser.new.must_connect
  .must_page("https://www.google.com/")
  .must_element("input")
  .must_eval("() => Object.keys(window)")

Log.info { "window object keys: #{res}" }
