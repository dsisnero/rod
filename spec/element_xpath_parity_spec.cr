require "./spec_helper"

# go's `Element.GetXPath` evaluates the shared helper on the element itself:
# `el.Evaluate(evalHelper(js.GetXPath, optimized))` (`element.go:747-754`), and
# `Element.Evaluate` binds `this` to the element's remote object
# (`element.go:733-735`). The port ran the helper on the *page*
# (`@page.evaluate(opts)`), so `this` was the global object instead of the
# element; only a stubbed page covered it.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

private GET_XPATH_FIXTURE = <<-HTML
<!DOCTYPE html>
<html><body>
  <div id="box"><span id="leaf">leaf</span></div>
</body></html>
HTML

private def with_xpath_leaf(&block : Rod::Element ->)
  with_live_browser do |browser|
    page = browser.page
    page.must_navigate("data:text/html,#{URI.encode_path(GET_XPATH_FIXTURE)}")
    block.call(page.must_element("#leaf"))
  end
end

describe "Element#get_xpath" do
  it "builds the path from the element's ancestors" do
    with_xpath_leaf do |leaf|
      leaf.get_xpath.should eq("/html/body/div/span")
    end
  end

  it "uses the id form when optimized" do
    with_xpath_leaf do |leaf|
      leaf.get_xpath(true).should eq("//*[@id='leaf']")
    end
  end

  it "is scoped to the receiver, not the page" do
    with_xpath_leaf do |leaf|
      # A second element with the same tag must not make the path ambiguous.
      leaf.page.must_eval("() => { const s = document.createElement('span'); s.id = 'other'; document.body.appendChild(s) }")
      leaf.get_xpath.should eq("/html/body/div/span")
    end
  end
end
