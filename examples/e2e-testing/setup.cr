require "../../src/rod"

# Shared test context, ported from go-rod's
# `lib/examples/e2e-testing/setup_test.go`: one browser for the whole run and an
# incognito page per test case, so tests cannot see each other's cookies or
# storage.
class E2EContext
  getter browser : Rod::Browser

  def initialize
    @browser = Rod::Browser.new.must_connect
  end

  # `page` mirrors the Go helper `G.page`. Like Go's `g.Cleanup(page.MustClose)`,
  # callers must close the page they get back once the test case is done.
  def page(url : String) : Rod::Page
    @browser.must_incognito.must_page(url)
  end

  # Close the shared browser; this also drops the incognito contexts the pages
  # were using. go-rod's example relies on the test binary exiting, but a script
  # that runs the cases in one process should be explicit about it.
  def close : Nil
    @browser.close
  rescue
    # The browser may already be gone (for example when it crashed).
  end
end
