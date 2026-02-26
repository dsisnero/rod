require "./spec_helper"

class WaitHarnessPage < Rod::Page
  getter load_called = 0
  getter dom_called = 0

  @snapshots : Array(Array(String))

  def initialize(@snapshots : Array(Array(String)))
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

describe Rod::Page do
  it "wait_dom_stable exits when snapshots converge" do
    page = WaitHarnessPage.new([
      ["a", "b"],
      ["a", "b", "c"],
      ["a", "b", "c"],
    ])

    page.wait_dom_stable(0.seconds, 0.0)
  end

  it "wait_stable runs load and dom checks" do
    page = WaitHarnessPage.new([["a"], ["a"]])

    page.wait_stable(0.seconds)

    page.load_called.should eq(1)
    page.dom_called.should eq(1)
  end
end
