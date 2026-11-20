require "./spec_helper"

class DummyReq
  include Cdp::Request

  @method : String

  def initialize(@method : String)
  end

  def proto_req : String
    @method
  end
end

describe Rod::Browser do
  it "tracks enabled domain state via set_state and load_state" do
    browser = Rod::Browser.new
    req = Cdp::Page::Enable.new(nil)

    browser.load_state(nil, req).should be_nil
    browser.set_state(nil, req.proto_req, JSON::Any.new(true))
    browser.load_state(nil, req).should_not be_nil
  end

  # go fills the caller's request through `reflect.Value.Set`
  # (`vendor/rod/states.go:43-52`); Crystal copies structs at call boundaries,
  # so the loaded request is returned instead of mutated in place.
  it "copies the stored params into the loaded request like go's LoadState" do
    browser = Rod::Browser.new
    method = "Emulation.setDeviceMetricsOverride"

    browser.set_state(nil, method, JSON.parse(%({"width":700,"height":500,"deviceScaleFactor":2.0,"mobile":true})))

    req = browser.load_state(nil, Cdp::Emulation::SetDeviceMetricsOverride.new(0_i64, 0_i64, 0.0, false))
    req.should_not be_nil
    req.not_nil!.width.should eq(700)
    req.not_nil!.height.should eq(500)
    req.not_nil!.device_scale_factor.should eq(2.0)
    req.not_nil!.mobile?.should be_true
  end

  it "keeps request defaults for params the stored state does not carry" do
    browser = Rod::Browser.new
    method = "Emulation.setDeviceMetricsOverride"

    browser.set_state(nil, method, JSON.parse(%({"width":700,"height":500,"deviceScaleFactor":1.0,"mobile":false})))

    req = browser.load_state(nil, Cdp::Emulation::SetDeviceMetricsOverride.new(
      0_i64, 0_i64, 0.0, false,
      scale: 1.5, screen_width: 1920_i64, viewport: nil
    ))
    req.should_not be_nil
    req.not_nil!.width.should eq(700)
    req.not_nil!.scale.should eq(1.5)
    req.not_nil!.screen_width.should eq(1920)
    req.not_nil!.screen_orientation.should be_nil
  end

  it "returns nil when no state is stored" do
    browser = Rod::Browser.new

    browser.load_state(
      nil,
      Cdp::Emulation::SetDeviceMetricsOverride.new(317_i64, 419_i64, 0.0, false)
    ).should be_nil
  end

  it "removes enable state when disable method is set" do
    browser = Rod::Browser.new
    enable = Cdp::Page::Enable.new(nil)

    browser.set_state(nil, enable.proto_req, JSON::Any.new(true))
    browser.load_state(nil, enable).should_not be_nil

    browser.set_state(nil, "Page.disable", JSON::Any.new(nil))
    browser.load_state(nil, enable).should be_nil
  end

  it "removes emulation set state when clear methods are set" do
    browser = Rod::Browser.new
    method = "Emulation.setDeviceMetricsOverride"

    browser.set_state(nil, method, JSON::Any.new(true))
    browser.load_state(nil, DummyReq.new(method)).should_not be_nil

    browser.set_state(nil, "Emulation.clearDeviceMetricsOverride", JSON::Any.new(nil))
    browser.load_state(nil, DummyReq.new(method)).should be_nil
  end

  it "removes geolocation emulation state when clear geolocation is set" do
    browser = Rod::Browser.new
    method = "Emulation.setGeolocationOverride"

    browser.set_state(nil, method, JSON::Any.new(true))
    browser.load_state(nil, DummyReq.new(method)).should_not be_nil

    browser.set_state(nil, "Emulation.clearGeolocationOverride", JSON::Any.new(nil))
    browser.load_state(nil, DummyReq.new(method)).should be_nil
  end

  it "does not call cdp when enable_domain is already enabled" do
    browser = Rod::Browser.new
    req = Cdp::Page::Enable.new(nil)
    browser.set_state(nil, req.proto_req, JSON::Any.new(true))

    restore = browser.enable_domain(nil, req)
    restore.call
  end

  it "does not call cdp when disable_domain is already disabled" do
    browser = Rod::Browser.new
    restore = browser.disable_domain(nil, Cdp::Page::Enable.new(nil))
    restore.call
  end

  it "remove_state deletes tracked state for a key" do
    browser = Rod::Browser.new
    req = Cdp::Page::Enable.new(nil)
    key = Rod::StateKey.new(nil, nil, req.proto_req)

    browser.set_state(nil, req.proto_req, JSON::Any.new(true))
    browser.load_state(nil, req).should_not be_nil

    browser.remove_state(key)
    browser.load_state(nil, req).should be_nil
  end
end
