require "./spec_helper"

class WaitHarnessPage < Rod::Page
  getter load_called = 0
  getter dom_called = 0
  getter capture_calls = 0

  @snapshots : Array(Array(String))
  @error_on_capture_at : Int32?

  def initialize(@snapshots : Array(Array(String)), @error_on_capture_at : Int32? = nil)
    super(
      Rod::Browser.new,
      Rod::TargetID.new("target-1"),
      nil,
      nil,
      Rod::Context.new
    )
  end

  def wait_load : Nil
    @load_called += 1
  end

  def wait_dom_stable(d : Time::Span, diff : Float64) : Nil
    @dom_called += 1
    super
  end

  def capture_dom_snapshot : Cdp::DOMSnapshot::CaptureSnapshotResult
    @capture_calls += 1
    if @error_on_capture_at == @capture_calls
      raise "capture failed"
    end

    strings = if @snapshots.size > 1
                @snapshots.shift
              else
                @snapshots.first? || [] of String
              end

    Cdp::DOMSnapshot::CaptureSnapshotResult.new(
      [] of Cdp::DOMSnapshot::DocumentSnapshot,
      strings
    )
  end
end

class WaitNeverStablePage < Rod::Page
  @count = 0

  def initialize
    super(
      Rod::Browser.new,
      Rod::TargetID.new("target-never-stable"),
      nil,
      nil,
      Rod::Context.new
    )
  end

  def capture_dom_snapshot : Cdp::DOMSnapshot::CaptureSnapshotResult
    @count += 1
    Cdp::DOMSnapshot::CaptureSnapshotResult.new(
      [] of Cdp::DOMSnapshot::DocumentSnapshot,
      [@count.to_s]
    )
  end
end

class WaitStableLoadErrorPage < WaitHarnessPage
  def wait_load : Nil
    raise "wait_load failed"
  end
end

describe Rod::Page do
  it "wait_dom_stable exits when snapshots converge" do
    page = WaitHarnessPage.new([
      ["a", "b"],
      ["a", "b", "c"],
      ["a", "b", "c"],
    ])

    page.wait_dom_stable(0.seconds, 0.0)
  end

  it "wait_dom_stable propagates capture errors" do
    first = WaitHarnessPage.new([["a"]], 1)
    expect_raises(Exception, /capture failed/) { first.wait_dom_stable(0.seconds, 0.0) }

    second = WaitHarnessPage.new([["a"], ["b"]], 2)
    expect_raises(Exception, /capture failed/) { second.wait_dom_stable(0.seconds, 0.0) }
  end

  it "wait_dom_stable respects timeout context while dom keeps changing" do
    page = WaitNeverStablePage.new
    timed = page.timeout(20.milliseconds)

    expect_raises(Rod::ContextTimeoutError) { timed.wait_dom_stable(100.milliseconds, 0.0) }
  end

  it "wait_stable runs load and dom checks" do
    page = WaitHarnessPage.new([["a"], ["a"]])

    page.wait_stable(0.seconds)

    page.load_called.should eq(1)
    page.dom_called.should eq(1)
  end

  it "wait_stable propagates wait_load errors" do
    page = WaitStableLoadErrorPage.new([["a"], ["a"]])
    expect_raises(Exception, /wait_load failed/) { page.wait_stable(0.seconds) }
  end

  it "wait_stable propagates wait_dom_stable errors" do
    page = WaitHarnessPage.new([["a"]], 1)
    expect_raises(Exception, /capture failed/) { page.wait_stable(0.seconds) }
  end
end
