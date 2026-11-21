require "spec"
require "../src/rod"

# go's `Page.SetExtraHeaders` is
# `return p.EnableDomain(&proto.NetworkEnable{}), proto.NetworkSetExtraHTTPHeaders{...}`
# (`page.go:139-147`), so it only enables Network when nobody else did and its
# cleanup only disables what it enabled. The port enabled and disabled
# unconditionally, which turned Network off for whoever had enabled it before.
private class HeaderDomainClient < Rod::Util::Cdp::Client
  getter calls = [] of String

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    @calls << method
    %({}).to_slice
  end
end

private def new_header_page(client : HeaderDomainClient) : Rod::Page
  browser = Rod::Browser.new.client(client)
  Rod::Page.new(browser, Rod::TargetID.new("target-id"))
end

describe "page domain enablement parity" do
  it "restores the Page domain through EnableDomain like go's HandleDialog" do
    client = HeaderDomainClient.new
    page = new_header_page(client)

    # Someone else enabled Page and still holds their restore func.
    page.browser.enable_domain(page.page_session_id, ::Cdp::Page::Enable.new(nil))
    client.calls.clear

    _wait, handle = page.handle_dialog
    handle.call(::Cdp::Page::HandleJavaScriptDialog.new(true, nil))

    client.calls.should contain("Page.handleJavaScriptDialog")
    client.calls.should_not contain("Page.enable")
    client.calls.should_not contain("Page.disable")
  end

  it "disables the Page domain only when HandleDialog enabled it" do
    client = HeaderDomainClient.new
    page = new_header_page(client)

    _wait, handle = page.handle_dialog
    handle.call(::Cdp::Page::HandleJavaScriptDialog.new(true, nil))

    client.calls.should contain("Page.enable")
    client.calls.should contain("Page.disable")
  end

  it "leaves the Network domain enabled when someone else already enabled it" do
    client = HeaderDomainClient.new
    page = new_header_page(client)

    # Someone else enabled Network and still holds their restore func.
    page.browser.enable_domain(page.page_session_id, ::Cdp::Network::Enable.new(nil, nil, nil, nil, nil))
    client.calls.clear

    cleanup = page.extra_headers(["X-Test", "1"])
    cleanup.call

    client.calls.should contain("Network.setExtraHTTPHeaders")
    client.calls.should_not contain("Network.enable")
    client.calls.should_not contain("Network.disable")
  end

  it "enables and restores the Network domain when nobody else had it" do
    client = HeaderDomainClient.new
    page = new_header_page(client)

    cleanup = page.extra_headers(["X-Test", "1"])
    cleanup.call

    client.calls.should contain("Network.enable")
    client.calls.should contain("Network.disable")
  end
end
