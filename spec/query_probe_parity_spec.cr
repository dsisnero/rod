require "./spec_helper"

# go-rod probes lookups through `NotFoundSleeper` so a miss fails on the first
# attempt instead of waiting out the page timeout:
#
# - `Page#Has` calls `p.Sleeper(NotFoundSleeper).Element(...)` and hands the
#   result `el.Sleeper(p.sleeper)` (`query.go:105-138`);
# - `Element#ElementByJS` calls
#   `el.page.Context(el.ctx).Sleeper(NotFoundSleeper).ElementByJS(...)` and hands
#   the result `e.Sleeper(el.sleeper)` (`query.go:501-508`);
# - `RaceContext#Do` gives every branch `rc.page.Sleeper(NotFoundSleeper)` and
#   the winner `rc.page.sleeper` (`query.go:438-457`);
# - every element inherits the page's `ctx` and `sleeper`
#   (`ElementFromObject`, `page.go:947-953`).

private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

# Runs `block` in a fiber so a lookup that never returns fails the example
# instead of hanging the suite.
private def within(limit : Time::Span, &block : -> T) : T forall T
  ch = Channel(T | Exception).new(1)
  spawn do
    ch.send(begin
      block.call
    rescue ex
      ex
    end)
  end

  select
  when value = ch.receive
    raise value if value.is_a?(Exception)
    value
  when timeout(limit)
    raise "lookup did not finish within #{limit}"
  end
end

private class ProbeStubPage < Rod::Page
  property next_element : Rod::Element? = nil
  property probe_sleeper_error : Exception? = nil
  property last_context : Rod::Context? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def context(ctx : Rod::Context) : Rod::Page
    @last_context = ctx
    self
  end

  def sleeper(sleeper : Proc(Rod::Utils::Sleeper)) : Rod::Page
    @sleeper = sleeper
    self
  end

  def element(selector : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    record_probe
    @next_element || raise Rod::NotFoundError.new
  end

  def element_by_js(opts : Rod::EvalOptions) : Rod::Element
    record_probe
    @next_element || raise Rod::NotFoundError.new
  end

  def elements_by_js(opts : Rod::EvalOptions) : Rod::Elements
    Rod::Elements.new([] of Rod::Element)
  end

  # The sleeper installed by the caller decides when a retry stops; a
  # `NotFoundSleeper` answers with `ElementNotFoundError` after one miss.
  private def record_probe : Nil
    @probe_sleeper_error = @sleeper.call.call(@last_context || Rod::Context.background)
  end
end

private class ProbeStubElement < Rod::Element
  def initialize(page : Rod::Page)
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"obj-1","description":"div"}))
    super(object, page)
  end
end

describe "query probe parity" do
  it "page has probes with go's NotFoundSleeper and hands back the page sleeper" do
    page = ProbeStubPage.new
    found = ProbeStubElement.new(page)
    page.next_element = found

    hit, element = page.has("a")

    hit.should be_true
    page.probe_sleeper_error.should be_a(Rod::ElementNotFoundError)
    element.not_nil!.object.should eq(found.object)
    element.not_nil!.sleeper.should eq(page.sleeper)
  end

  it "element element_by_js probes with go's NotFoundSleeper and hands back the element sleeper" do
    page = ProbeStubPage.new
    parent = ProbeStubElement.new(page)
    child = ProbeStubElement.new(page)
    page.next_element = child

    element = parent.element_by_js(Rod::EvalOptions.new(js: "() => this.querySelector('div')"))

    page.probe_sleeper_error.should be_a(Rod::ElementNotFoundError)
    element.object.should eq(child.object)
    element.sleeper.should eq(parent.sleeper)
  end

  it "element elements_by_js runs in the element context like go" do
    page = ProbeStubPage.new
    element = ProbeStubElement.new(page)
    element_ctx = Rod::Context.background
    scoped = element.context(element_ctx)

    scoped.elements_by_js(Rod::EvalOptions.new(js: "() => this.querySelectorAll('div')"))

    page.last_context.should be(element_ctx)
  end

  it "page has reports a miss on the first attempt like go's NotFoundSleeper" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<div id=box>hi</div>' }")

      started = Time.instant
      hit, element = page.has("#missing")
      elapsed = Time.instant - started

      hit.should be_false
      element.should be_nil
      elapsed.should be < 2.seconds

      page.must_close
    end
  end

  it "element has reports a miss on the first attempt like go's NotFoundSleeper" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<div id=box>hi</div>' }")

      timed = page.timeout(500.milliseconds)
      box = timed.must_element("#box")

      started = Time.instant
      hit, child = box.has("#missing")
      elapsed = Time.instant - started

      hit.should be_false
      child.should be_nil
      elapsed.should be < 400.milliseconds

      page.must_close
    end
  end

  it "element lookups honor the element context like go's Element.ElementByJS" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<div id=box>hi</div>' }")

      box = page.must_element("#box")
      timed = box.timeout(2.seconds)

      # go probes once, so the miss is an ElementNotFoundError, never a timeout.
      expect_raises(Rod::ElementNotFoundError) do
        within(10.seconds) { timed.element("#missing") }
      end

      page.must_close
    end
  end

  it "race probes each branch once like go's NotFoundSleeper" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<div id=box>hi</div>' }")

      started = Time.instant
      winner = page.race.element("#never").element("#box").do
      elapsed = Time.instant - started

      winner.must_text.should eq("hi")
      elapsed.should be < 2.seconds

      page.must_close
    end
  end

  it "elements inherit the page context and sleeper like go's ElementFromObject" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<div id=box>hi</div>' }")

      limited = page.sleeper(-> { Rod::Util::Utils.count_sleeper(4) })
      timed = limited.timeout(30.seconds)
      box = timed.must_element("#box")

      box.get_context.deadline.should eq(timed.get_context.deadline)
      box.sleeper.should eq(timed.sleeper)

      page.must_close
    end
  end
end
