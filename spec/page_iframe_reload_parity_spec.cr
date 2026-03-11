require "./spec_helper"

private def with_real_browser(&)
  launcher = Rod::Lib::Launcher.new
  browser = Rod::Browser.new

  begin
    ws_url = launcher.launch
    browser.connect(ws_url)
    yield browser
  ensure
    begin
      browser.close
    rescue
      nil
    end
    begin
      launcher.kill
    rescue
      nil
    end
    begin
      launcher.cleanup
    rescue
      nil
    end
  end
end

describe "page eval parity iframe reload" do
  it "matches go TestPageIframeReload behavior against fixture file" do
    next unless ENV["ROD_REAL_BROWSER"]? == "1"

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
