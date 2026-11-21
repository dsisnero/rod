require "spec"
require "../src/rod"

# go-rod's `eachEvent` enables the event domains through `EnableDomain`
# (`browser.go:364-371` -> `states.go:60-73`): when the state registry says the
# domain is already enabled it sends no `*.enable`, and its restore is a no-op.
# The port called `*.enable`/`*.disable` directly, so a wait that ended disabled
# a domain someone else had enabled and still expected to deliver events.
private class DomainRecordingClient < Rod::Util::Cdp::Client
  getter calls = [] of String

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    @calls << method
    %({}).to_slice
  end
end

private def network_request_callback : Hash(String, Rod::Browser::CallbackInfo)
  {
    ::Cdp::Network::RequestWillBeSentEvent.proto_event => Rod::Browser::CallbackInfo.new(
      ::Cdp::Network::RequestWillBeSentEvent,
      ->(_event : Cdp::Event, _session_id : Rod::SessionID?) { nil }
    ),
  }
end

describe "each_event domain state parity" do
  it "leaves a domain that was already enabled alone, like go's EnableDomain" do
    client = DomainRecordingClient.new
    browser = Rod::Browser.new.client(client)

    # Someone else enabled Network and still holds their restore func.
    browser.enable_domain(nil, ::Cdp::Network::Enable.new(nil))
    client.calls.clear

    # A wait whose context is already cancelled finishes immediately, so its
    # restores run inside this example.
    ctx = Rod::Context.new
    ctx.cancel
    wait = browser.context(ctx).each_event(nil, network_request_callback)
    wait.call

    client.calls.should_not contain("Network.enable")
    client.calls.should_not contain("Network.disable")
  end

  it "enables and restores the domain when nobody else had it" do
    client = DomainRecordingClient.new
    browser = Rod::Browser.new.client(client)

    ctx = Rod::Context.new
    ctx.cancel
    wait = browser.context(ctx).each_event(nil, network_request_callback)
    wait.call

    client.calls.should contain("Network.enable")
    client.calls.should contain("Network.disable")
  end
end
