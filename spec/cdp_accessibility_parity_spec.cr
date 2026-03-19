require "./spec_helper"

private class AccessibilityProtoClient < Cdp::Client
  getter calls = [] of String

  def initialize
    @responses = {} of String => String
  end

  def stub(method : String, payload : String) : Nil
    @responses[method] = payload
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    @calls << method
    (@responses[method]? || %({})).to_slice
  end
end

describe "accessibility proto parity" do
  it "loads the accessibility domain via require rod" do
    Cdp::Accessibility::Enable.new.proto_req.should eq("Accessibility.enable")
    Proto::Accessibility::Enable.new.proto_req.should eq("Accessibility.enable")
  end

  it "decodes Accessibility.getFullAXTree with typed result calls" do
    client = AccessibilityProtoClient.new
    client.stub("Accessibility.getFullAXTree", %({"nodes":[{"nodeId":"ax-root","ignored":false}]}))

    result = Cdp::Accessibility::GetFullAXTree.new(nil, nil).call(client)

    client.calls.should eq(["Accessibility.getFullAXTree"])
    result.nodes.size.should eq(1)
    result.nodes.first.node_id.should eq("ax-root")
    result.nodes.first.ignored?.should be_false
  end
end
