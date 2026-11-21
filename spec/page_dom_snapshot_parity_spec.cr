require "./spec_helper"

# go-rod's `TestPageCaptureDOMSnapshot` (`page_test.go:511-523`) is the only
# upstream test that reads the snapshot payload, and its assertion
# (`g.Is(domSnapshot.Strings, []string{})`) is a *kind* check, not a value check:
# `got.Assertions.Is` compares `reflect.Kind` only. Ported as a stub it also hid
# the include flags `CaptureDOMSnapshot` asks for (`page.go:600-614`), so this
# example drives a real page and checks the layout data go-rod requests.
private def dom_snapshot_fixture_url(name : String) : String
  "file://#{File.expand_path("vendor/rod/fixtures/#{name}", Dir.current)}"
end

describe "page capture_dom_snapshot parity" do
  it "returns the layout data go's CaptureDOMSnapshot requests" do
    RodSpec.with_live_browser do |browser|
      page = browser.must_page(dom_snapshot_fixture_url("click.html"))
      begin
        page.must_wait_load

        snapshot = page.must_capture_dom_snapshot

        # Go's `g.Is(domSnapshot.Strings, []string{})` only asserts the kind.
        snapshot.strings.should be_a(Array(String))
        snapshot.strings.should_not be_empty

        document = snapshot.documents.first
        layout = document.layout

        # `includeDOMRects: true` (`page.go:604`) fills the rect tables.
        layout.bounds.should_not be_empty
        layout.offset_rects.should_not be_nil
        layout.scroll_rects.should_not be_nil
        layout.client_rects.should_not be_nil

        # `includePaintOrder: true` (`page.go:603`) fills `paintOrders`.
        layout.paint_orders.not_nil!.size.should eq(layout.bounds.size)

        # `includeBlendedBackgroundColors` / `includeTextColorOpacities`
        # (`page.go:605-606`) fill their optional tables.
        layout.blended_background_colors.should_not be_nil
        layout.text_color_opacities.should_not be_nil
      ensure
        page.must_close
      end
    end
  end

  it "fails with the page timeout like go's TestPageCaptureDOMSnapshot" do
    RodSpec.with_live_browser do |browser|
      page = browser.must_page(dom_snapshot_fixture_url("click.html"))
      begin
        page.must_wait_load

        timed = page.timeout(1.second)
        sleep 1.second

        # Go asserts `err == context.DeadlineExceeded` and a nil snapshot; the
        # port raises from the cancelled context instead of returning nil.
        expect_raises(Rod::ContextTimeoutError) { timed.capture_dom_snapshot }
      ensure
        page.must_close
      end
    end
  end
end
