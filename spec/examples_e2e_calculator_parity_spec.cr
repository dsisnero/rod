require "./spec_helper"

private CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
private APP_URL    = "https://go-rod.github.io/calculator/"

private def with_live_browser(& : Rod::Browser ->)
  launcher = Rod::Lib::Launcher::Launcher.new
    .bin(CHROME_BIN)
    .headless(true)
    .no_sandbox(true)
    .leakless(false)

  browser = Rod::Browser.new.control_url(launcher.launch)
  browser.connect

  begin
    yield browser
  ensure
    begin
      browser.close
    rescue
    end

    begin
      launcher.kill
    rescue
    end
  end
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
