require "spec"
require "../src/rod"

def create_test_page
  browser = Rod::Browser.new
  Rod::Page.new(
    browser: browser,
    target_id: Rod::TargetID.new("test-target"),
    session_id: nil,
    frame_id: nil,
    ctx: nil
  )
end

describe Rod::Keyboard do
  it "initializes" do
    page = create_test_page
    keyboard = page.keyboard
    keyboard.should be_a(Rod::Keyboard)
  end

  it "has modifiers" do
    page = create_test_page
    keyboard = page.keyboard
    keyboard.modifiers.should eq(0)
  end
end

describe Rod::Mouse do
  it "initializes" do
    page = create_test_page
    mouse = page.mouse
    mouse.should be_a(Rod::Mouse)
  end

  it "has position" do
    page = create_test_page
    mouse = page.mouse
    pos = mouse.position
    pos.should be_a(Rod::Point)
    pos.x.should eq(0)
    pos.y.should eq(0)
  end
end

describe Rod::Touch do
  it "initializes" do
    page = create_test_page
    touch = page.touch
    touch.should be_a(Rod::Touch)
  end
end

describe Rod::Point do
  it "creates point" do
    p = Rod::Point.new(1.5, 2.5)
    p.x.should eq(1.5)
    p.y.should eq(2.5)
  end

  it "adds points" do
    p1 = Rod::Point.new(1, 2)
    p2 = Rod::Point.new(3, 4)
    p3 = p1.add(p2)
    p3.x.should eq(4)
    p3.y.should eq(6)
  end

  it "subtracts points" do
    p1 = Rod::Point.new(5, 7)
    p2 = Rod::Point.new(2, 3)
    p3 = p1.minus(p2)
    p3.x.should eq(3)
    p3.y.should eq(4)
  end

  it "scales point" do
    p1 = Rod::Point.new(2, 3)
    p2 = p1.scale(2.5)
    p2.x.should eq(5)
    p2.y.should eq(7.5)
  end
end
