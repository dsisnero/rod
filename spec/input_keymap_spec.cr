require "./spec_helper"

describe Rod::Input do
  it "returns key info and shifted keys" do
    info = Rod::Input.key_info('a'.ord.to_i32)
    info.key.should eq("a")
    info.code.should eq("KeyA")
    info.key_code.should eq(65)
    info.location.should eq(0)

    shifted_info = Rod::Input.key_info('A'.ord.to_i32)
    shifted_info.key.should eq("A")
    shifted_info.code.should eq("KeyA")
    Rod::Input.printable?('A'.ord.to_i32).should be_true

    enter = Rod::Input.key_info(Rod::Input::ENTER)
    enter.key.should eq("\r")
    enter.code.should eq("Enter")
    enter.key_code.should eq(13)

    sl = Rod::Input.key_info(Rod::Input::SHIFT_LEFT)
    sl.key.should eq("Shift")
    sl.location.should eq(1)
    Rod::Input.printable?(Rod::Input::SHIFT_LEFT).should be_false

    sr = Rod::Input.key_info(Rod::Input::SHIFT_RIGHT)
    sr.key.should eq("Shift")
    sr.location.should eq(2)

    shifted, has = Rod::Input.shifted(Rod::Input::DIGIT1)
    has.should be_true
    Rod::Input.key_info(shifted).key.should eq("!")

    _, has_enter = Rod::Input.shifted(Rod::Input::ENTER)
    has_enter.should be_false

    expect_raises(Exception) { Rod::Input.key_info('\n'.ord.to_i32) }
  end

  it "returns key modifiers" do
    Rod::Input.modifier(Rod::Input::KEY_A).should eq(0)
    Rod::Input.modifier(Rod::Input::ALT_LEFT).should eq(Rod::Input::MODIFIER_ALT)
    Rod::Input.modifier(Rod::Input::CONTROL_LEFT).should eq(Rod::Input::MODIFIER_CONTROL)
    Rod::Input.modifier(Rod::Input::META_LEFT).should eq(Rod::Input::MODIFIER_META)
    Rod::Input.modifier(Rod::Input::SHIFT_LEFT).should eq(Rod::Input::MODIFIER_SHIFT)
  end

  it "encodes mouse buttons" do
    button, flag = Rod::Input.encode_mouse_button([Rod::Input::MOUSE_BUTTON_LEFT])
    button.should eq(Rod::Input::MOUSE_BUTTON_LEFT)
    flag.should eq(1)
  end

  it "encodes key events like Go input.TestKeyEncode" do
    a_down = Rod::Input.encode('a'.ord.to_i32, Cdp::Input::KeyDown, 0)
    a_down.type.should eq(Cdp::Input::KeyDown)
    a_down.text.should eq("a")
    a_down.unmodified_text.should eq("a")
    a_down.code.should eq("KeyA")
    a_down.key.should eq("a")
    a_down.windows_virtual_key_code.should eq(65)
    a_down.location.should eq(0)

    a_up = Rod::Input.encode('a'.ord.to_i32, Cdp::Input::KeyUp, 0)
    a_up.type.should eq(Cdp::Input::KeyUp)
    a_up.text.should eq("a")
    a_up.unmodified_text.should eq("a")
    a_up.code.should eq("KeyA")
    a_up.key.should eq("a")
    a_up.windows_virtual_key_code.should eq(65)
    a_up.location.should eq(0)

    alt_down = Rod::Input.encode(Rod::Input::ALT_LEFT, Cdp::Input::KeyDown, 0)
    alt_down.type.should eq(Cdp::Input::KeyRawDown)
    alt_down.code.should eq("AltLeft")
    alt_down.key.should eq("Alt")
    alt_down.windows_virtual_key_code.should eq(18)
    alt_down.location.should eq(1)

    numpad_down = Rod::Input.encode(Rod::Input::NUMPAD1, Cdp::Input::KeyDown, 0)
    numpad_down.type.should eq(Cdp::Input::KeyDown)
    numpad_down.code.should eq("Numpad1")
    numpad_down.key.should eq("1")
    numpad_down.text.should eq("1")
    numpad_down.unmodified_text.should eq("1")
    numpad_down.windows_virtual_key_code.should eq(35)
    numpad_down.is_keypad?.should be_true
    numpad_down.location.should be_nil
  end

  it "defaults mac mode to the host OS like go's IsMac" do
    {% if flag?(:darwin) %}
      # go: `var IsMac = runtime.GOOS == "darwin"` (`mac_comands.go:5`).
      Rod::Input.mac?.should be_true
    {% else %}
      Rod::Input.mac?.should be_false
    {% end %}
  end

  it "emits go's mac commands for the keys its table can match" do
    old = Rod::Input.mac?
    begin
      Rod::Input.mac = true
      {
        Rod::Input::ARROW_UP    => ["moveUp"],
        Rod::Input::ARROW_DOWN  => ["moveDown"],
        Rod::Input::ARROW_LEFT  => ["moveLeft"],
        Rod::Input::ARROW_RIGHT => ["moveRight"],
        Rod::Input::ESCAPE      => ["cancelOperation"],
        Rod::Input::F5          => ["complete"],
        Rod::Input::DELETE      => ["deleteForward"],
        Rod::Input::HOME        => ["scrollToBeginningOfDocument"],
        Rod::Input::END         => ["scrollToEndOfDocument"],
        Rod::Input::PAGE_UP     => ["scrollPageUp"],
        Rod::Input::PAGE_DOWN   => ["scrollPageDown"],
      }.each do |key, expected|
        Rod::Input.encode(key, Cdp::Input::KeyDown, 0).commands.should eq(expected)
      end

      # go looks the table up by `Info().Key` alone (`keyboard.go:108-111`), so
      # keys whose `Key` is a character (Enter is "\r", KeyA is "a") can never
      # match the playwright-style "Meta+KeyA"/"Shift+Enter" entries.
      Rod::Input.encode(Rod::Input::ENTER, Cdp::Input::KeyDown, 0).commands.should be_nil
      Rod::Input.encode(Rod::Input::KEY_A, Cdp::Input::KeyDown, 0).commands.should be_nil
    ensure
      Rod::Input.mac = old
    end
  end

  it "emits mac command list for ArrowDown when mac mode is enabled" do
    old = Rod::Input.mac?
    begin
      Rod::Input.mac = true
      encoded = Rod::Input.encode(Rod::Input::ARROW_DOWN, Cdp::Input::KeyDown, 0)
      encoded.type.should eq(Cdp::Input::KeyRawDown)
      encoded.code.should eq("ArrowDown")
      encoded.key.should eq("ArrowDown")
      encoded.windows_virtual_key_code.should eq(40)
      encoded.auto_repeat?.should be_false
      encoded.is_keypad?.should be_false
      encoded.is_system_key?.should be_false
      encoded.location.should eq(0)
      encoded.commands.should eq(["moveDown"])
    ensure
      Rod::Input.mac = old
    end
  end
end
