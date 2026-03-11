require "./spec_helper"

describe "cdp client format parity" do
  it "formats request/response/event strings like Go cdp TestFormat" do
    req = Rod::Lib::Cdp::Request.new(123, "test", JSON.parse("1"), "000000001234")
    req.to_s.should eq("=> #123 @00000000 test 1")

    res = Rod::Lib::Cdp::Response.new(0, JSON.parse("11"), nil)
    res.to_s.should eq("<= #0 11")

    err_res = Rod::Lib::Cdp::Response.new(0, nil, Rod::Lib::Cdp::Error.new(0, ""))
    err_res.to_s.should eq("<= #0 error: {\"code\":0,\"message\":\"\",\"data\":\"\"}")

    evt = Rod::Lib::Cdp::Event.new("event", JSON.parse("11"), nil)
    evt.to_s.should eq("<- @00000000 event 11")
  end
end
