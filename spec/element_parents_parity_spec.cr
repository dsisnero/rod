require "./spec_helper"

# go's `Element.Parents` is `el.ElementsByJS(evalHelper(js.Parents, selector))`
# (`query.go:516-518`): the selector is required and `js.Parents` walks the
# *receiver's* ancestors (`lib/js/helper.go:46-52`), nearest first, keeping the
# ones that match.
#
# The port hand-wrote the script and ran it straight on the page without binding
# `this` to the element, so in real use `this` was the global object, the walk
# never started, and `parents` answered an empty list while the stubbed spec only
# checked the recorded options.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

private PARENTS_FIXTURE = <<-HTML
<!DOCTYPE html>
<html><body>
  <div id="outer" class="level">
    <div id="middle" class="level">
      <span id="leaf">leaf</span>
    </div>
  </div>
</body></html>
HTML

private def with_parents_leaf(&block : Rod::Element ->)
  with_live_browser do |browser|
    page = browser.page
    page.must_navigate("data:text/html,#{URI.encode_path(PARENTS_FIXTURE)}")
    block.call(page.must_element("#leaf"))
  end
end

private def ids(elements : Rod::Elements) : Array(String?)
  elements.map(&.attribute("id")).to_a
end

describe "Element#parents" do
  it "answers the matching ancestors of the receiver, nearest first" do
    with_parents_leaf do |leaf|
      ids(leaf.parents("div")).should eq(["middle", "outer"])
    end
  end

  it "filters the ancestors by the selector" do
    with_parents_leaf do |leaf|
      ids(leaf.parents("#outer")).should eq(["outer"])
      leaf.parents("section").size.should eq(0)
    end
  end

  it "does not report the receiver itself" do
    with_parents_leaf do |leaf|
      # Ancestors: #middle, #outer, body, html.
      leaf.parents("*").size.should eq(4)
      ids(leaf.parents("*")).should_not contain("leaf")
    end
  end
end
