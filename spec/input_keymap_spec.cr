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
end
