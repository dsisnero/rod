require "./spec_helper"

# Borrow the pooled live browser, like go-rod's `setup` does for every test
# (`vendor/rod/setup_test.go:41`).
private def with_real_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

describe "page eval parity iframe reload" do
  it "matches go TestPageIframeReload behavior against fixture file" do
    next unless RodSpec.chrome_available?

    fixture_path = File.expand_path("../vendor/rod/fixtures/click-iframe.html", __DIR__)
    fixture_url = "file://#{fixture_path}"

    with_real_browser do |browser|
      page = browser.must_page(fixture_url)
      frame = page.must_element("iframe").must_frame
      btn = frame.must_element("button")
      btn.must_text.should eq("click me")

      frame.must_reload
      btn = frame.must_element("button")
      btn.must_text.should eq("click me")

      src = page.must_element("iframe").must_attribute("src")
      src.should_not be_nil
      src.not_nil!.should contain("click.html")
    end
  end
end
