require "./spec_helper"

private class CdpTimeBorderClient < Cdp::Client
  getter captured : JSON::Any?

  def initialize(@reply_json : String)
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @captured = params
    @reply_json.to_slice
  end
end

private struct TimeBorderReq
  include JSON::Serializable
  include Cdp::Request

  @[JSON::Field(key: "timestamp")]
  property timestamp : Time

  def initialize(@timestamp : Time)
  end

  def proto_req : String
    "Test.timeReq"
  end
end

private struct TimeBorderRes
  include JSON::Serializable

  @[JSON::Field(key: "timestamp")]
  property timestamp : Time
end

describe "cdp time border parity" do
  it "serializes Time fields to protocol numeric seconds on outgoing requests" do
    client = CdpTimeBorderClient.new(%({}))
    t = Time.unix_ms(1700000123123)
    Cdp.call("Test.timeReq", TimeBorderReq.new(t), nil, client)

    captured = client.captured
    captured.should_not be_nil
    ts = captured.not_nil!["timestamp"].as_f
    ts.should eq(1700000123.0)
  end

  it "deserializes protocol numeric seconds into Time on incoming responses" do
    client = CdpTimeBorderClient.new(%({"timestamp":1700000123.123}))
    req = TimeBorderReq.new(Time.utc)
    res = Cdp.call("Test.timeReq", req, TimeBorderRes, client)

    res.timestamp.to_unix_ms.should eq(1700000123123)
  end
end
