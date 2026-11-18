require "./spec_helper"

private APP_URL = "https://go-rod.github.io/calculator/"

# Borrow the pooled live browser, like go-rod's `setup` does for its examples
# (`vendor/rod/setup_test.go:41`). Each example still works in its own incognito
# context; the pool disposes it before the next one runs.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

describe "examples e2e calculator parity" do
  it "matches TestAdd behavior" do
    with_live_browser do |browser|
      page = browser.must_incognito.must_page(APP_URL)
      begin
        page.must_element_r("button", "1").must_click
        page.must_element_r("button", "^\\+$").must_click
        page.must_element_r("button", "2").must_click
        page.must_element_r("button", "=").must_click

        page.must_element(".component-display").must_text.should eq("3")
      ensure
        begin
          page.must_close
        rescue
        end
      end
    end
  end

  it "matches TestMultiple behavior" do
    with_live_browser do |browser|
      page = browser.must_incognito.must_page(APP_URL)
      begin
        ["2", "x", "3", "="].each do |regex|
          page.must_element_r("button", regex).must_click
        end

        page.must_element(".component-display").must_text.should eq("6")
      ensure
        begin
          page.must_close
        rescue
        end
      end
    end
  end
end
