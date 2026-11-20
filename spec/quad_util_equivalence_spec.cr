require "./spec_helper"

# Quad geometry exists twice: `Rod::Util::Quad` (used by `Element#interactable`,
# `#hover`, `#move_mouse_out` and `#screenshot`) and the generated `Cdp::DOM`
# helpers, which are the port of go's `DOMQuad` patch methods
# (`lib/proto/a_patch.go:70-120`). Phase 30 had to fix both copies when one
# drifted, so this spec pins them against each other: the util module must keep
# answering exactly what the generated helpers answer.
private QUADS = [
  # whole-number coordinates, clockwise
  "[8,8,100,8,100,50,8,50]",
  # the same rectangle wound counter-clockwise (negative signed area)
  "[8,8,8,50,100,50,100,8]",
  # sub-pixel coordinates
  "[0.5,1.25,10.75,1.25,10.75,20.5,0.5,20.5]",
  # go's own fixture from `a_patch_test.go`
  "[336,382,361,382,361,421,336,412]",
  # degenerate: every vertex identical
  "[5,5,5,5,5,5,5,5]",
  # thin sliver with whole-number coordinates
  "[0,0,3,1,3,2,0,1]",
]

private def quads_json : Array(JSON::Any)
  QUADS.map { |raw| JSON.parse(raw) }
end

describe "Rod::Util::Quad" do
  it "agrees with the generated Cdp::DOM helpers" do
    quads_json.each do |quad|
      Rod::Util::Quad.len(quad).should eq(quad.as_a.size // 2)
      Rod::Util::Quad.area(quad).should eq(Cdp::DOM.area(quad))

      center = Rod::Util::Quad.center(quad)
      dom_center = Cdp::DOM.center(quad)
      center.x.should eq(dom_center.x)
      center.y.should eq(dom_center.y)
    end
  end

  it "agrees on the bounding box of a quad list" do
    quads = quads_json
    util_box = Rod::Util::Quad.box(quads)
    dom_box = Cdp::DOM::GetContentQuadsResult.new(quads).box

    util_box.should_not be_nil
    dom_box.should_not be_nil
    x, y, width, height = util_box.not_nil!
    box = dom_box.not_nil!
    x.should eq(box.x)
    y.should eq(box.y)
    width.should eq(box.width)
    height.should eq(box.height)

    Rod::Util::Quad.box([] of JSON::Any).should be_nil
    Cdp::DOM::GetContentQuadsResult.new([] of JSON::Any).box.should be_nil
  end

  it "agrees on the first quad with area >= 1" do
    quads = [
      JSON.parse("[1,1,2,1,2,1,1,1]"), # zero area: skipped
      JSON.parse("[1,1,2,1,2,2,1,2]"), # area 1: first usable quad
      JSON.parse("[4,4,8,4,8,8,4,8]"), # area 16: never reached
    ]

    util_point = Rod::Util::Quad.one_point_inside(quads)
    dom_point = Cdp::DOM::GetContentQuadsResult.new(quads).one_point_inside

    util_point.should_not be_nil
    dom_point.should_not be_nil
    util_point.not_nil!.x.should eq(dom_point.not_nil!.x)
    util_point.not_nil!.y.should eq(dom_point.not_nil!.y)
    util_point.not_nil!.x.should eq(1.5)

    # Only zero-area quads: neither helper can answer a point.
    degenerate = [JSON.parse("[1,1,2,1,2,1,1,1]")]
    Rod::Util::Quad.one_point_inside(degenerate).should be_nil
    Cdp::DOM::GetContentQuadsResult.new(degenerate).one_point_inside.should be_nil
  end

  it "walks vertices in order with their index" do
    quad = JSON.parse("[1,2,3,4,5,6,7,8]")
    collected = [] of Tuple(Float64, Float64, Int32)
    Rod::Util::Quad.each(quad) do |point, index|
      collected << {point.x, point.y, index}
    end

    collected.should eq([
      {1.0, 2.0, 0},
      {3.0, 4.0, 1},
      {5.0, 6.0, 2},
      {7.0, 8.0, 3},
    ])
  end
end
