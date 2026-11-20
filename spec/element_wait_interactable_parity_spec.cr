require "./spec_helper"

# go-rod's `Element.WaitInteractable` (`element.go:587-606`) is
# `utils.Retry(el.ctx, el.sleeper(), ...)`: a `CoveredError` retries, any other
# error stops. The port capped the whole wait at a private 5 s deadline, so a
# slow overlay surfaced a `CoveredError` after five seconds even though the page
# (or the element) allowed more time.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

# A button under an overlay that jumps out of the way `delay` after load, so the
# retry loop has to keep going for that long without any cross-fiber CDP call.
private def overlay_page(browser : Rod::Browser, delay : Time::Span) : Rod::Page
  page = browser.must_page("about:blank")
  page.must_eval(<<-JS)
    () => {
      document.body.innerHTML = `
        <style>
          @keyframes uncover { from { transform: translateX(0) } to { transform: translateX(400px) } }
          #overlay {
            position: absolute; top: 0; left: 0; width: 200px; height: 200px;
            background: #0006; animation: uncover #{delay.total_seconds}s steps(1, end) forwards;
          }
        </style>
        <button id="btn" style="position:absolute;top:10px;left:10px;width:100px;height:40px">ok</button>
        <div id="overlay"></div>
      `
    }
    JS
  page
end

describe "element wait_interactable parity" do
  it "retries a covered element past five seconds like go's Retry(el.ctx, el.sleeper())" do
    with_live_browser do |browser|
      page = overlay_page(browser, 5.6.seconds)
      btn = page.must_element("#btn")

      started = Time.instant
      point = btn.wait_interactable
      elapsed = Time.instant - started

      # go only stops on the context, the sleeper or an element that can never
      # be interactable, so a 5.6 s overlay still resolves.
      elapsed.should be >= 5.5.seconds
      point.x.should be > 0
      point.y.should be > 0

      page.must_close
    end
  end

  it "returns as soon as the element stops being covered" do
    with_live_browser do |browser|
      page = overlay_page(browser, 400.milliseconds)
      btn = page.must_element("#btn")

      started = Time.instant
      point = btn.wait_interactable

      point.x.should be > 0
      (Time.instant - started).should be < 3.seconds

      page.must_close
    end
  end

  it "surfaces the element deadline while the element stays covered" do
    with_live_browser do |browser|
      page = overlay_page(browser, 30.seconds)
      btn = page.must_element("#btn").timeout(300.milliseconds)

      ex = expect_raises(Rod::DeadlineExceededError) { btn.wait_interactable }
      ex.message.to_s.should contain("context deadline exceeded")

      page.must_close
    end
  end

  it "surfaces the element sleeper error while the element stays covered" do
    with_live_browser do |browser|
      page = overlay_page(browser, 30.seconds)
      btn = page.must_element("#btn").sleeper(-> { Rod::Util::Utils.count_sleeper(1) })

      expect_raises(Rod::Util::Utils::MaxSleepCountError) { btn.wait_interactable }

      page.must_close
    end
  end
end
