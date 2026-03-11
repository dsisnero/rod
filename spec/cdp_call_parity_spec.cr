require "./spec_helper"

private class CdpCallCaptureClient < Cdp::Client
  include Cdp::Sessionable
  include Cdp::Contextable

  getter seen_context : HTTP::Client::Context?
  getter seen_session_id : String?
  getter seen_method : String?
  getter seen_params : JSON::Any?

  def initialize(@reply : String = %({}), @session_id : String? = "session-1", @context : HTTP::Client::Context? = HTTP::Client::Context.new, @raise_error : Exception? = nil)
  end

  def session_id : String?
    @session_id
  end

  def context : HTTP::Client::Context?
    @context
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @seen_context = context
    @seen_session_id = session_id
    @seen_method = method
    @seen_params = params
    raise @raise_error.not_nil! if @raise_error
    @reply.to_slice
  end
end

private struct CdpCallReq
  include JSON::Serializable
  include Cdp::Request

  @[JSON::Field(key: "value")]
  property value : String

  def initialize(@value : String)
  end

  def proto_req : String
    "Test.req"
  end
end

private struct CdpCallRes
  include JSON::Serializable
  @[JSON::Field(key: "ok")]
  property ok : Bool
end

describe "cdp call parity" do
  it "formats cdp core errors with go-style tuple string" do
    err = Cdp::Error.new(10, "err", JSON.parse(%("data")))
    err.to_s.should eq("{10 err data}")
    err.is?(err).should be_true
  end

  it "propagates context and session id from contextable/sessionable client" do
    client = CdpCallCaptureClient.new(reply: %({"ok":true}))
    req = CdpCallReq.new("x")

    res = Cdp.call("Test.req", req, CdpCallRes, client)
    res.ok.should be_true

    client.seen_context.should_not be_nil
    client.seen_session_id.should eq("session-1")
    client.seen_method.should eq("Test.req")
    client.seen_params.should_not be_nil
    client.seen_params.not_nil!["value"].as_s.should eq("x")
  end

  it "bubbles client call errors" do
    client = CdpCallCaptureClient.new(raise_error: Exception.new("err"))
    req = CdpCallReq.new("x")

    expect_raises(Exception, /err/) do
      Cdp.call("Test.req", req, nil, client)
    end
  end
end
