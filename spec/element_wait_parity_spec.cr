require "./spec_helper"

# go-rod's `Element.Wait*` family (`vendor/rod/element.go:608-636`) is a thin
# wrapper over `Element#wait`, which delegates to `Page.Wait` and retries through
# `page.Sleeper` until the element context is done. The port used to poll with a
# private 5s deadline instead, so neither the page/element timeout nor a custom
# sleeper reached `wait_visible`, `wait_enabled`, `wait_writable` or
# `wait_invisible`.
private def fixture_url(name : String) : String
  "file://#{File.expand_path("vendor/rod/fixtures/#{name}", Dir.current)}"
end

private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

describe "element wait parity" do
  it "matches TestWaitInvisible with a real browser" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      h4 = page.must_element("h4")
      btn = page.must_element("button")

      h4.visible?.should be_true
      h4.must_wait_visible

      spawn do
        sleep 30.milliseconds
        h4.must_eval("() => this.remove()")
        sleep 30.milliseconds
        btn.must_eval("() => this.style.visibility = 'hidden'")
      end

      h4.must_wait_invisible
      btn.must_wait_invisible

      page.must_has("h4").should be_false
      page.must_close
    end
  end

  it "matches TestWaitEnabled and TestWaitWritable with a real browser" do
    with_live_browser do |browser|
      click_page = browser.must_page(fixture_url("click.html"))
      click_page.must_wait_load
      click_page.must_element("button").must_wait_enabled
      click_page.must_close

      input_page = browser.must_page(fixture_url("input.html"))
      input_page.must_wait_load
      input_page.must_element("input").must_wait_writable
      input_page.must_close
    end
  end

  it "matches go's js.Visible for opacity and zero-size elements" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval(<<-JS)
        () => {
          document.body.innerHTML = `
            <div id="faded" style="width:10px;height:10px;opacity:0">faded</div>
            <div id="zero" style="position:fixed;top:0;left:0;width:0;height:0"></div>
            <div id="hidden" style="visibility:hidden">hidden</div>
            <div id="none" style="display:none">none</div>
          `
        }
        JS

      # `js.Visible` only checks display, visibility and a non-empty client rect,
      # so `opacity:0` stays visible while a zero-size fixed box does not.
      page.must_element("#faded").visible?.should be_true
      page.must_element("#zero").visible?.should be_false
      page.must_element("#hidden").visible?.should be_false
      page.must_element("#none").visible?.should be_false

      page.must_close
    end
  end

  it "retries wait_visible through the element sleeper like go's Element.Wait" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      btn = page.must_element("button")
      btn.must_eval("() => this.style.visibility = 'hidden'")

      limited = btn.sleeper(-> { Rod::Util::Utils.count_sleeper(2) })
      expect_raises(Rod::Util::Utils::MaxSleepCountError) { limited.wait_visible }

      page.must_close
    end
  end

  it "surfaces the context deadline from wait_visible like go's Element.Wait" do
    with_live_browser do |browser|
      page = browser.must_page(fixture_url("click.html"))
      page.must_wait_load

      btn = page.must_element("button")
      btn.must_eval("() => this.style.visibility = 'hidden'")

      timed = btn.timeout(200.milliseconds)
      started = Time.instant
      ex = expect_raises(Rod::DeadlineExceededError) { timed.wait_visible }
      ex.message.to_s.should contain("context deadline exceeded")
      (Time.instant - started).should be < 3.seconds

      page.must_close
    end
  end
end
