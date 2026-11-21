require "spec"
require "../src/rod"

# go-rod's proto fields are plain `bool` with `json:",omitempty"`, so a `false`
# option never reaches the wire (Phase 54 fixed `fromSurface`; this is the same
# class for `Runtime.callFunctionOn`). `Cdp::Runtime::CallFunctionOn` models them
# as `Bool?` with `emit_null: false`, so the port has to pass nil for false.
private class EvalPayloadStubPage < Rod::Page
  getter payloads = {} of String => Array(JSON::Any)

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    (@payloads[method] ||= [] of JSON::Any) << params

    case method
    when "Runtime.evaluate"
      %({"result":{"type":"object","objectId":"window-obj"}}).to_slice
    when "Runtime.callFunctionOn"
      %({"result":{"type":"object","objectId":"result-obj"}}).to_slice
    else
      raise "missing stub for #{method}"
    end
  end
end

describe "eval request payload parity" do
  it "omits false callFunctionOn flags like go's omitempty" do
    page = EvalPayloadStubPage.new
    page.evaluate(Rod::EvalOptions.new(js: "() => 1"))

    payload = page.payloads["Runtime.callFunctionOn"].last
    payload["returnByValue"].as_bool.should be_true
    payload["awaitPromise"]?.should be_nil
    payload["userGesture"]?.should be_nil
  end

  it "sends the flags when they are true" do
    page = EvalPayloadStubPage.new
    page.evaluate(Rod::EvalOptions.new(js: "() => 1", by_value: false).by_promise.by_user)

    payload = page.payloads["Runtime.callFunctionOn"].last
    payload["returnByValue"]?.should be_nil
    payload["awaitPromise"].as_bool.should be_true
    payload["userGesture"].as_bool.should be_true
  end
end
