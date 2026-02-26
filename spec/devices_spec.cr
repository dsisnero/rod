require "./spec_helper"

describe Rod::Lib::Devices do
  it "ports utils_test.go behavior" do
    v = Rod::Lib::Devices::IPad.metrics_emulation
    touch = Rod::Lib::Devices::IPad.touch_emulation

    v.should_not be_nil
    v = v.not_nil!
    v.width.should eq(768_i64)
    v.height.should eq(1024_i64)
    v.device_scale_factor.should eq(2.0)
    v.screen_orientation.should_not be_nil
    v.screen_orientation.not_nil!.angle.should eq(0_i64)
    v.mobile?.should be_true
    touch.enabled?.should be_true

    v = Rod::Lib::Devices::LaptopWithMDPIScreen.landscape.metrics_emulation
    touch = Rod::Lib::Devices::LaptopWithMDPIScreen.touch_emulation

    v.should_not be_nil
    v = v.not_nil!
    v.width.should eq(1280_i64)
    v.screen_orientation.should_not be_nil
    v.screen_orientation.not_nil!.angle.should eq(90_i64)
    v.mobile?.should be_false
    touch.enabled?.should be_false

    u = Rod::Lib::Devices::IPad.user_agent_emulation
    u.should_not be_nil
    u.not_nil!.user_agent.should eq("Mozilla/5.0 (iPad; CPU OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1")

    Rod::Lib::Devices::Clear.metrics_emulation.should be_nil
    Rod::Lib::Devices::Clear.touch_emulation.enabled?.should be_false
    Rod::Lib::Devices::Clear.user_agent_emulation.should be_nil
  end
end
