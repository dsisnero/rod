require "./spec_helper"

describe "cdp dom quad parity" do
  it "computes center and area like go proto quad helpers" do
    quad = JSON.parse("[336,382,361,382,361,421,336,412]")
    center = Cdp::DOM.center(quad)
    center.x.should eq(348.5)
    center.y.should eq(399.25)

    Cdp::DOM.area(JSON.parse("[1,1,2,1,2,1,1,1]")).should eq(0.0)
    Cdp::DOM.area(JSON.parse("[1,1,2,1,2,2,1,2]")).should eq(1.0)
    Cdp::DOM.area(JSON.parse("[1,1,2,1,2,4,1,3]")).should eq(2.5)
  end

  it "computes one_point_inside and bounding box from quads result" do
    res = Cdp::DOM::GetContentQuadsResult.new([] of Cdp::DOM::Quad)
    res.one_point_inside.should be_nil
    res.box.should be_nil

    res = Cdp::DOM::GetContentQuadsResult.new([JSON.parse("[1,1,2,1,2,1,1,1]")])
    res.one_point_inside.should be_nil

    res = Cdp::DOM::GetContentQuadsResult.new([
      JSON.parse("[1,1,2,1,2,2,1,2]"),
      JSON.parse("[2,0,3,0,3,1,2,1]"),
      JSON.parse("[0,2,1,2,1,3,0,3]"),
    ])

    pt = res.one_point_inside
    pt.should_not be_nil
    pt.not_nil!.x.should eq(1.5)
    pt.not_nil!.y.should eq(1.5)

    box = res.box
    box.should_not be_nil
    box.not_nil!.x.should eq(0.0)
    box.not_nil!.y.should eq(0.0)
    box.not_nil!.width.should eq(3.0)
    box.not_nil!.height.should eq(3.0)
  end
end
