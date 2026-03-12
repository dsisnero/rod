require "./spec_helper"

describe Cdp do
  it "exposes protocol version constant" do
    Cdp::Version.should eq("v1.3")
  end

  it "parses method names into domain and command" do
    domain, name = Cdp.parse_method_name("Page.enable")
    domain.should eq("Page")
    name.should eq("enable")
  end

  it "maps known method names to request types" do
    Cdp.get_type("Page.enable").should eq(Cdp::Page::Enable)
    Cdp.get_type("Browser.getVersion").should eq(Cdp::Browser::GetVersion)
    Cdp.get_type("Target.getTargets").should eq(Cdp::Target::GetTargets)
    Cdp.get_type("Runtime.evaluate").should eq(Cdp::Runtime::Evaluate)
  end

  it "returns nil for unknown method names" do
    Cdp.get_type("Page.nope").should be_nil
  end

  it "converts wildcard patterns to regex like go proto utils" do
    Cdp.pattern_to_reg("").should eq("")
    Cdp.pattern_to_reg("*").should eq("\\A.*\\z")
    Cdp.pattern_to_reg("?").should eq("\\A.\\z")
    Cdp.pattern_to_reg("a").should eq("\\Aa\\z")
    Cdp.pattern_to_reg("a.com/*/test").should eq("\\Aa.com/.*/test\\z")
    Cdp.pattern_to_reg("\\?\\*").should eq("\\A\\?\\*\\z")
    Cdp.pattern_to_reg("a.com\\?a=10&b=\\*").should eq("\\Aa.com\\?a=10&b=\\*\\z")
  end

  it "converts cookies to cookie params with expires preserved" do
    cookie = Cdp::Network::Cookie.from_json({
      "name"               => "n",
      "value"              => "v",
      "domain"             => "example.com",
      "path"               => "/",
      "expires"            => 1234567890.0,
      "size"               => 1,
      "httpOnly"           => false,
      "secure"             => true,
      "session"            => false,
      "sameSite"           => Cdp::Network::CookieSameSiteLax,
      "priority"           => Cdp::Network::CookiePriorityMedium,
      "sourceScheme"       => Cdp::Network::CookieSourceSchemeSecure,
      "sourcePort"         => 443,
      "partitionKey"       => nil,
      "partitionKeyOpaque" => nil,
    }.to_json)

    params = Cdp::Network.cookies_to_params([cookie])
    params.size.should eq(1)
    params[0].name.should eq("n")
    params[0].value.should eq("v")
    params[0].expires.should_not be_nil
    params[0].expires.not_nil!.to_unix.should eq(1234567890)
  end

  it "moves touch point coordinates" do
    p = Cdp::Input::TouchPoint.new(0.0, 0.0)
    p.move_to(1.0, 2.0)
    p.x.should eq(1.0)
    p.y.should eq(2.0)
  end

  it "provides a_patch time helper equivalents for network time aliases" do
    Cdp::Network.time_since_epoch_time(-1.0).to_unix.should eq(0)
    Cdp::Network.time_since_epoch_time(1.5).to_unix.should eq(1)
    Cdp::Network.time_since_epoch_string(1.0).should contain("1970")

    Cdp::Network.monotonic_time_duration(1.25).total_milliseconds.should eq(1250)
    Cdp::Network.monotonic_time_string(1.0).should contain("00:00:01")
  end
end
