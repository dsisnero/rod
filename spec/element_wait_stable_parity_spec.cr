require "./spec_helper"

# go's `Element.WaitStable` waits for `WaitVisible()` first and only then defers
# the `stable` span (`element.go:519-550`), and its ticker races the element
# context, so a cancelled/deadlined element stops immediately (`select` on
# `t.C` / `el.ctx.Done()`). `WaitStableRAF` traces after `WaitVisible` the same
# way (`element.go:556-566`).
private class StableShapeStubElement < Rod::Element
  property wait_visible_error : Exception? = nil
  property shape_calls = 0

  def initialize(page : Rod::Page)
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-stable","description":"div"}))
    super(object, page)
  end

  # `wait_visible` delegates to `wait`, so its own span still runs before the
  # failure surfaces.
  def wait(opts : Rod::EvalOptions) : Nil
    _ = opts
    if ex = @wait_visible_error
      raise ex
    end
  end

  # A different quad on every call, so the loop never stabilizes.
  def shape : Cdp::DOM::GetContentQuadsResult
    @shape_calls += 1
    x = @shape_calls
    Cdp::DOM::GetContentQuadsResult.new(
      [JSON.parse("[#{x},0,#{x + 10},0,#{x + 10},10,#{x},10]")] of Cdp::DOM::Quad
    )
  end
end

describe "element wait_stable parity" do
  it "traces the stable span after wait_visible like go's Element.WaitStable" do
    lines = [] of String
    browser = Rod::Browser.new
    browser.logger(Rod::Util::Utils::Log.new { |vs| lines << vs.join(" ") })
    browser.trace(true)
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"))
    element = StableShapeStubElement.new(page)
    element.wait_visible_error = Rod::NotFoundError.new("no element")

    expect_raises(Rod::NotFoundError) { element.wait_stable(10.milliseconds) }

    # go returns from `WaitVisible` before the `stable` span is deferred.
    lines.any? { |l| l.includes?("visible") }.should be_true
    lines.any? { |l| l.includes?("stable") }.should be_false
  end

  it "stops the stable loop as soon as the element context is done" do
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
    element = StableShapeStubElement.new(page)
    ctx, cancel = element.ctx.with_cancel
    timed = element.context(ctx)

    spawn do
      sleep 50.milliseconds
      cancel.call
    end

    started = Time.instant
    expect_raises(Rod::ContextCanceledError) { timed.wait_stable(5.seconds) }
    (Time.instant - started).should be < 2.seconds
  end

  it "traces the stable RAF span after wait_visible like go's Element.WaitStableRAF" do
    lines = [] of String
    browser = Rod::Browser.new
    browser.logger(Rod::Util::Utils::Log.new { |vs| lines << vs.join(" ") })
    browser.trace(true)
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"))
    element = StableShapeStubElement.new(page)
    element.wait_visible_error = Rod::NotFoundError.new("no element")

    expect_raises(Rod::NotFoundError) { element.wait_stable_raf }

    lines.any? { |l| l.includes?("visible") }.should be_true
    lines.any? { |l| l.includes?("stable RAF") }.should be_false
  end
end
