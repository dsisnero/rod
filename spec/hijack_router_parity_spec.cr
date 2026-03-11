require "spec"
require "../src/rod"

private class HijackRouterStubClient < Cdp::Client
  getter calls = [] of String

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    @calls << method
    %({}).to_slice
  end
end

class Rod::HijackRouter
  def __handler_patterns : Array(String)
    @handlers.map(&.pattern)
  end

  def __handler_regexes : Array(String)
    @handlers.map(&.regex.source)
  end

  def __enable_patterns : Array(Cdp::Fetch::RequestPattern)?
    @enable.patterns
  end
end

describe Rod::HijackRouter do
  it "converts patterns to regex like Go PatternToReg cases" do
    browser = Rod::Browser.new
    client = HijackRouterStubClient.new
    router = Rod::HijackRouter.new(browser, client)

    patterns = {
      "*"                  => /\A.*\z/,
      "?"                  => /\A.\z/,
      "a"                  => /\Aa\z/,
      "a.com/*/test"       => /\Aa.com\/.*\/test\z/,
      "\\?\\*"             => /\A\?\*\z/,
      "a.com\\?a=10&b=\\*" => /\Aa.com\?a=10&b=\*\z/,
    }

    patterns.each do |pattern, expected|
      router.add(pattern, Cdp::Network::ResourceTypeXHR, ->(_ctx : Rod::Hijack) { })
      router.__handler_regexes.last.should eq(expected.source)
      router.remove(pattern)
    end
  end

  it "add/remove keeps fetch patterns and handler list in sync" do
    browser = Rod::Browser.new
    client = HijackRouterStubClient.new
    router = Rod::HijackRouter.new(browser, client)

    router.add("https://a.test/*", Cdp::Network::ResourceTypeXHR, ->(_ctx : Rod::Hijack) { })
    router.add("https://b.test/*", Cdp::Network::ResourceTypeDocument, ->(_ctx : Rod::Hijack) { })

    router.__handler_patterns.should eq(["https://a.test/*", "https://b.test/*"])
    router.__enable_patterns.not_nil!.map(&.url_pattern).should eq(["https://a.test/*", "https://b.test/*"])

    router.remove("https://a.test/*")
    router.__handler_patterns.should eq(["https://b.test/*"])
    router.__enable_patterns.not_nil!.map(&.url_pattern).should eq(["https://b.test/*"])

    # add + remove invoke Fetch.enable updates
    client.calls.should contain("Fetch.enable")
  end
end
