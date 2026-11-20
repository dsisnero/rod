require "./spec_helper"

# go-rod runs element queries through the shared `lib/js` helpers, not ad-hoc
# scripts: `Element.ElementR` is `evalHelper(js.ElementR, selector, jsRegex)`
# (`query.go:492-494`), and `js.ElementR` parses the regex argument the way a
# JavaScript literal would (`vendor/rod/lib/js/helper.go:40-44`): a
# `/pattern/flags` argument becomes `new RegExp("pattern", "flags")`, anything
# else is passed to `new RegExp(argument)` unchanged.
#
# The port used to hand-write these scripts, and `element_r` fed the raw
# argument to `new RegExp(...)`, so `/hello/i` matched nothing. These specs pin
# the helper semantics through the public API.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

private ELEMENT_R_FIXTURE = <<-HTML
<!DOCTYPE html>
<html><body>
  <div id="host">
    <span id="lower">hello</span>
    <span id="upper">HELLO</span>
    <span id="other">goodbye</span>
  </div>
</body></html>
HTML

private def with_element_r_page(&block : Rod::Page ->)
  with_live_browser do |browser|
    page = browser.page
    page.must_navigate("data:text/html,#{URI.encode_path(ELEMENT_R_FIXTURE)}")
    block.call(page)
  end
end

describe "Element#element_r" do
  it "matches case-insensitively for a /pattern/flags argument" do
    with_element_r_page do |page|
      host = page.must_element("#host")

      host.element_r("span", "/hello/i").attribute("id").should eq("lower")
      # A lowercase-only text found through an uppercase regex proves the `i`
      # flag reached RegExp; the raw-string form would match nothing.
      host.element_r("span", "/GOODBYE/i").attribute("id").should eq("other")
    end
  end

  it "matches the plain pattern form without flags" do
    with_element_r_page do |page|
      host = page.must_element("#host")

      host.element_r("span", "goodbye").attribute("id").should eq("other")
      host.element_r("span", "HELLO").attribute("id").should eq("upper")
      # Without a flag the pattern stays case sensitive, like
      # `new RegExp("GOODBYE")` against "goodbye".
      expect_raises(Rod::ElementNotFoundError) { host.element_r("span", "GOODBYE") }
    end
  end

  it "scopes the search to the receiver" do
    with_element_r_page do |page|
      inner = page.must_element("#host").must_element("#lower")

      # `#lower` has no children, so the sibling that matches the text regex must
      # not leak into the result.
      expect_raises(Rod::ElementNotFoundError) { inner.element_r("span", "goodbye") }
    end
  end
end
