require "../../src/rod"

# Opening pages with go-rod's `Target.createTarget` options, mirroring
# `Browser.Page(opts proto.TargetCreateTarget)`
# (`vendor/rod/browser.go:267-316`). The creation URL is always `about:blank`;
# a non-empty `url` is navigated afterwards.
#
# The plain `page`/`page(url)` form is the convenience overload.
browser = Rod::Browser.new.must_connect

begin
  # A new window instead of a tab.
  window = browser.page(
    Cdp::Target::CreateTarget.new(
      "data:text/html,<title>new window</title><h1>new window</h1>",
      new_window: true
    )
  )
  begin
    puts window.must_eval("() => document.title").as_s
  ensure
    window.must_close
  end

  # A background tab that loads while the current page keeps running.
  tab = browser.page(
    Cdp::Target::CreateTarget.new(
      "data:text/html,<title>background tab</title><h1>background tab</h1>",
      background: true
    )
  )
  begin
    tab.must_wait_load
    puts tab.must_eval("() => document.title").as_s
  ensure
    tab.must_close
  end
ensure
  browser.close
end
