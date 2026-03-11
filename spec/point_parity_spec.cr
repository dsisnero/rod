require "./spec_helper"

describe Rod::Point do
  it "matches go proto point add/minus/scale behavior" do
    p = Rod::Point.new(1, 2)
      .add(Rod::Point.new(3, 4))
      .minus(Rod::Point.new(1, 1))
      .scale(2.0)

    p.x.should eq(6.0)
    p.y.should eq(10.0)
  end
end
