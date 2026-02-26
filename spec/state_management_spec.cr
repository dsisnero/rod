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

    browser.load_state(nil, req).should be_false
    browser.set_state(nil, req.proto_req, JSON::Any.new(true))
    browser.load_state(nil, req).should be_true
  end

  it "removes enable state when disable method is set" do
    browser = Rod::Browser.new
    enable = Cdp::Page::Enable.new(nil)

    browser.set_state(nil, enable.proto_req, JSON::Any.new(true))
    browser.load_state(nil, enable).should be_true

    browser.set_state(nil, "Page.disable", JSON::Any.new(nil))
    browser.load_state(nil, enable).should be_false
  end

  it "removes emulation set state when clear methods are set" do
    browser = Rod::Browser.new
    method = "Emulation.setDeviceMetricsOverride"

    browser.set_state(nil, method, JSON::Any.new(true))
    browser.load_state(nil, DummyReq.new(method)).should be_true

    browser.set_state(nil, "Emulation.clearDeviceMetricsOverride", JSON::Any.new(nil))
    browser.load_state(nil, DummyReq.new(method)).should be_false
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
end
