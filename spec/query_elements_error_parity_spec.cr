require "./spec_helper"

# go-rod's `Page.ElementsByJS` (`query.go:206-246`) reports a non-array result
# and a non-node array entry as `*ExpectElementsError`, carrying the offending
# remote object, so callers can match it with `errors.Is`. The port raised plain
# `Exception`s, which made `Rod.is?(err, Rod::ExpectElementsError)` impossible.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

describe "query elements error parity" do
  it "reports a non-array js result as go's ExpectElementsError" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")

      err = expect_raises(Rod::ExpectElementsError) do
        page.elements_by_js(Rod::EvalOptions.new(js: "() => 1"))
      end

      Rod.is?(err, Rod::ExpectElementsError).should be_true
      err.remote_object.not_nil!.type.should eq("number")

      page.must_close
    end
  end

  it "reports a non-node array entry as go's ExpectElementsError" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")

      err = expect_raises(Rod::ExpectElementsError) do
        page.elements_by_js(Rod::EvalOptions.new(js: "() => [document.body, 42]"))
      end

      Rod.is?(err, Rod::ExpectElementsError).should be_true
      err.remote_object.not_nil!.type.should eq("number")

      page.must_close
    end
  end

  it "returns the elements for an array of nodes" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<div id=a></div><div id=b></div>' }")

      elements = page.elements_by_js(Rod::EvalOptions.new(js: "() => [document.getElementById('a'), document.getElementById('b')]"))

      elements.size.should eq(2)
      elements.first.not_nil!.must_attribute("id").should eq("a")
      elements.last.not_nil!.must_attribute("id").should eq("b")

      page.must_close
    end
  end
end
