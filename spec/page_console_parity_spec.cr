require "./spec_helper"

private class ConsoleParityPage < Rod::Page
  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"), Rod::SessionID.new("session-1"), Rod::FrameID.new("frame-1"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    case method
    when "Runtime.callFunctionOn"
      %({"result":{"type":"object","value":{"b":["test"]}}}).to_slice
    else
      raise "unexpected method: #{method}"
    end
  end
end

describe "page console parity" do
  it "converts console arg remote objects via object_to_json / objects_to_json" do
    page = ConsoleParityPage.new

    arg1 = Cdp::Runtime::RemoteObject.from_json(%({"type":"number","value":1}))
    arg2 = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1"}))

    obj = page.must_object_to_json(arg2)
    obj["b"].as_a[0].as_s.should eq("test")

    all = page.must_objects_to_json([arg1, arg2]).as_a
    all[0].as_i.should eq(1)
    all[1]["b"].as_a[0].as_s.should eq("test")
  end
end
