require "./spec_helper"

# `src/cdp` is a curated snapshot of a pinned CDP vintage (see
# docs/generation.md). These specs pin the vintage's observable surface so a
# regeneration that silently keeps the old protocol, drops the wire keys, or
# stops decoding results through the typed API fails loudly.
describe "CDP protocol vintage parity" do
  it "generates the domain set of the pinned Chromium vintage" do
    domains = Dir.children("src/cdp")
      .select { |entry| File.directory?(File.join("src/cdp", entry)) }

    # Added by Chromium 160.0.8168.1.
    {"ads", "crashreportcontext", "digitalcredentials", "findinpage", "webmcp"}
      .each { |domain| domains.should contain(domain) }

    # Removed in Chromium 160.0.8168.1.
    {"console", "database", "schema"}
      .each { |domain| domains.should_not contain(domain) }
  end

  it "decodes the pinned vintage's remoteIPAddress wire key" do
    payload = <<-JSON
      {
        "url": "https://example.com/",
        "status": 200,
        "statusText": "OK",
        "headers": {},
        "mimeType": "text/html",
        "charset": "utf-8",
        "connectionReused": false,
        "connectionId": 7.0,
        "encodedDataLength": 128.0,
        "securityState": "secure",
        "remoteIPAddress": "10.0.0.1"
      }
      JSON

    response = Cdp::Network::Response.from_json(payload)

    response.remote_ip_address.should eq("10.0.0.1")
  end

  it "routes generated command results through typed decoding" do
    source = File.read("src/cdp/dom/dom.cr")

    source.should contain("def call(c : Cdp::Client) : GetDocumentResult")
    source.should contain("Cdp.call(proto_req, self, GetDocumentResult, c)")
  end

  it "serializes generated enums as wire integers" do
    # CDP enums are integers on the wire; Crystal's default enum `to_json`
    # emits the member name, which Chrome rejects.
    (Cdp::Input::Modifier::Alt | Cdp::Input::Modifier::Ctrl).to_json.should eq("3")
    Cdp::Input::Modifier.from_json("3").should eq(Cdp::Input::Modifier::Alt | Cdp::Input::Modifier::Ctrl)
  end
end
