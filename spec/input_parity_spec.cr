require "./spec_helper"

private class InputCdpStubPage < Rod::Page
  getter calls = [] of Tuple(String, JSON::Any)
  property fail_method : String? = nil
  property fail_on_call : Int32? = nil
  @method_counts = Hash(String, Int32).new(0)

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("input-target"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @method_counts[method] += 1
    if method == @fail_method && @method_counts[method] == @fail_on_call
      raise Exception.new("stubbed failure: #{method}")
    end

    @calls << {method, params}
    %({}).to_slice
  end

  def calls_for(method : String) : Array(JSON::Any)
    @calls.select { |(m, _)| m == method }.map(&.[1])
  end
end

private class TypeFailElement < Rod::Element
  property focus_error : Exception? = nil

  def focus : Nil
    if ex = @focus_error
      raise ex
    end
  end
end

describe "input parity" do
  it "keyboard key_actions balances queued key presses with trailing release" do
    page = InputCdpStubPage.new

    page.keyboard.key_actions
      .press(Rod::Input::CONTROL_LEFT)
      .type(Rod::Input::ENTER)
      .do

    events = page.calls_for("Input.dispatchKeyEvent")
    events.size.should eq(4)

    events[0]["type"].as_s.should eq("rawKeyDown")
    events[0]["key"].as_s.should eq("Control")

    events[1]["type"].as_s.should eq("keyDown")
    events[1]["key"].as_s.should eq("\r")

    events[2]["type"].as_s.should eq("keyUp")
    events[2]["key"].as_s.should eq("\r")

    events[3]["type"].as_s.should eq("keyUp")
    events[3]["key"].as_s.should eq("Control")
  end

  it "keyboard release on non-pressed key is a no-op" do
    page = InputCdpStubPage.new

    page.keyboard.release(Rod::Input::KEY_A)
    page.calls_for("Input.dispatchKeyEvent").should be_empty
  end

  it "mouse move_linear emits interpolated mouseMoved events" do
    page = InputCdpStubPage.new

    page.mouse.move_linear(Rod::Point.new(6, 6), 3)

    events = page.calls_for("Input.dispatchMouseEvent")
    events.size.should eq(3)

    events[0]["type"].as_s.should eq("mouseMoved")
    events[0]["x"].as_f.should eq(2.0)
    events[0]["y"].as_f.should eq(2.0)

    events[1]["x"].as_f.should eq(4.0)
    events[1]["y"].as_f.should eq(4.0)

    events[2]["x"].as_f.should eq(6.0)
    events[2]["y"].as_f.should eq(6.0)

    page.mouse.position.x.should eq(6.0)
    page.mouse.position.y.should eq(6.0)
  end

  it "mouse down/up tracks pressed buttons and sends correct flags" do
    page = InputCdpStubPage.new

    page.mouse.down("left")
    page.mouse.down("right")
    page.mouse.up("left")

    events = page.calls_for("Input.dispatchMouseEvent")
    events.size.should eq(3)

    events[0]["type"].as_s.should eq("mousePressed")
    events[0]["button"].as_s.should eq("left")
    events[0]["buttons"].as_i.should eq(1)

    events[1]["type"].as_s.should eq("mousePressed")
    events[1]["button"].as_s.should eq("right")
    events[1]["buttons"].as_i.should eq(3)

    events[2]["type"].as_s.should eq("mouseReleased")
    events[2]["button"].as_s.should eq("left")
    events[2]["buttons"].as_i.should eq(2)
  end

  it "mouse scroll clamps steps to 1 and emits wheel delta" do
    page = InputCdpStubPage.new

    page.mouse.scroll(10, 20, 0)

    events = page.calls_for("Input.dispatchMouseEvent")
    events.size.should eq(1)
    events[0]["type"].as_s.should eq("mouseWheel")
    events[0]["deltaX"].as_f.should eq(10.0)
    events[0]["deltaY"].as_f.should eq(20.0)
  end

  it "touch tap dispatches touchStart then touchEnd" do
    page = InputCdpStubPage.new

    page.touch.tap(10, 20)

    events = page.calls_for("Input.dispatchTouchEvent")
    events.size.should eq(2)

    events[0]["type"].as_s.should eq("touchStart")
    events[0]["touchPoints"].as_a.size.should eq(1)
    events[0]["touchPoints"][0]["x"].as_f.should eq(10.0)
    events[0]["touchPoints"][0]["y"].as_f.should eq(20.0)

    events[1]["type"].as_s.should eq("touchEnd")
    events[1]["touchPoints"].as_a.should be_empty
  end

  it "touch start/move/cancel emits expected event sequence" do
    page = InputCdpStubPage.new
    point = Cdp::Input::TouchPoint.new(
      x: 30.0,
      y: 40.0,
      radius_x: nil,
      radius_y: nil,
      rotation_angle: nil,
      force: nil,
      tangential_pressure: nil,
      tilt_x: nil,
      tilt_y: nil,
      twist: nil,
      id: nil
    )

    page.touch.start(point)
    moved = Cdp::Input::TouchPoint.new(
      x: 50.0,
      y: 60.0,
      radius_x: nil,
      radius_y: nil,
      rotation_angle: nil,
      force: nil,
      tangential_pressure: nil,
      tilt_x: nil,
      tilt_y: nil,
      twist: nil,
      id: nil
    )
    page.touch.move(moved)
    page.touch.cancel

    events = page.calls_for("Input.dispatchTouchEvent")
    events.size.should eq(3)
    events[0]["type"].as_s.should eq("touchStart")
    events[1]["type"].as_s.should eq("touchMove")
    events[2]["type"].as_s.should eq("touchCancel")
  end

  it "mouse move_linear propagates dispatch errors (Go TestMouseMoveErr parity)" do
    page = InputCdpStubPage.new
    page.fail_method = "Input.dispatchMouseEvent"
    page.fail_on_call = 2

    expect_raises(Exception, /stubbed failure/) do
      page.mouse.move_linear(Rod::Point.new(10, 10), 3)
    end
  end

  it "keyboard.type propagates keyDown dispatch errors" do
    page = InputCdpStubPage.new
    page.fail_method = "Input.dispatchKeyEvent"
    page.fail_on_call = 1

    expect_raises(Exception, /stubbed failure/) do
      page.keyboard.type(Rod::Input::KEY_A)
    end
  end

  it "keyboard.type propagates keyUp dispatch errors" do
    page = InputCdpStubPage.new
    page.fail_method = "Input.dispatchKeyEvent"
    page.fail_on_call = 2

    expect_raises(Exception, /stubbed failure/) do
      page.keyboard.type(Rod::Input::KEY_A)
    end
  end

  it "keyboard.key_actions press propagates dispatch errors" do
    page = InputCdpStubPage.new
    page.fail_method = "Input.dispatchKeyEvent"
    page.fail_on_call = 1

    expect_raises(Exception, /stubbed failure/) do
      page.keyboard.key_actions.press(Rod::Input::KEY_A).do
    end
  end

  it "mouse click propagates dispatch errors" do
    page = InputCdpStubPage.new
    page.fail_method = "Input.dispatchMouseEvent"
    page.fail_on_call = 1

    expect_raises(Exception, /stubbed failure/) do
      page.mouse.click("left")
    end
  end

  it "mouse click with click_count=2 emits double-click count on down/up" do
    page = InputCdpStubPage.new

    page.mouse.click("left", 2)

    events = page.calls_for("Input.dispatchMouseEvent")
    events.size.should eq(2)
    events[0]["type"].as_s.should eq("mousePressed")
    events[0]["clickCount"].as_i.should eq(2)
    events[1]["type"].as_s.should eq("mouseReleased")
    events[1]["clickCount"].as_i.should eq(2)
  end

  it "mouse scroll/down/up each propagate dispatch errors" do
    scroll_page = InputCdpStubPage.new
    scroll_page.fail_method = "Input.dispatchMouseEvent"
    scroll_page.fail_on_call = 1
    expect_raises(Exception, /stubbed failure/) { scroll_page.mouse.scroll(0, 10, 1) }

    down_page = InputCdpStubPage.new
    down_page.fail_method = "Input.dispatchMouseEvent"
    down_page.fail_on_call = 1
    expect_raises(Exception, /stubbed failure/) { down_page.mouse.down("left") }

    up_page = InputCdpStubPage.new
    up_page.mouse.down("left")
    up_page.fail_method = "Input.dispatchMouseEvent"
    up_page.fail_on_call = 2
    expect_raises(Exception, /stubbed failure/) { up_page.mouse.up("left") }
  end

  it "element.type propagates focus/evaluate errors" do
    page = InputCdpStubPage.new
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-type","description":"body"}))
    element = TypeFailElement.new(object, page)
    element.focus_error = Exception.new("focus failed")

    expect_raises(Exception, /focus failed/) { element.type(Rod::Input::KEY_A) }
  end

  it "touch tap propagates dispatch errors" do
    page = InputCdpStubPage.new
    page.fail_method = "Input.dispatchTouchEvent"
    page.fail_on_call = 1

    expect_raises(Exception, /stubbed failure/) do
      page.touch.tap(1, 2)
    end
  end
end
