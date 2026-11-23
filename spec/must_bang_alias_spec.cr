require "./spec_helper"

private class BangAliasElement < Rod::Element
  getter calls = [] of String

  def initialize(page : Rod::Page)
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","subtype":"node","description":"div"}))
    super(obj, page)
  end

  def must_click : Rod::Element
    @calls << "must_click"
    self
  end

  def must_text : String
    @calls << "must_text"
    "bang-text"
  end
end

private class BangAliasPage < Rod::Page
  getter calls = [] of String

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("alias-target"))
  end

  def must_element(selector : String) : Rod::Element
    @calls << "must_element:#{selector}"
    BangAliasElement.new(self)
  end

  def must_eval(js : String, params : Array(::JSON::Any) = [] of ::JSON::Any) : ::JSON::Any
    @calls << "must_eval:#{js}:#{params.size}"
    JSON.parse(%("ok"))
  end
end

private class BangAliasBrowser < Rod::Browser
  getter calls = [] of String

  def must_connect : Rod::Browser
    @calls << "must_connect"
    self
  end

  def must_page(url : String = "about:blank") : Rod::Page
    @calls << "must_page:#{url}"
    BangAliasPage.new
  end
end

private class BangAliasLauncher < Rod::Util::Launcher::Launcher
  getter calls = [] of String

  def must_client : Rod::Util::Cdp::Client
    @calls << "must_client"
    Rod::Util::Cdp::Client.new
  end
end

describe "must bang aliases" do
  it "routes browser bang methods to must_ methods" do
    browser = BangAliasBrowser.new
    browser.connect!
    page = browser.page!("https://example.com")

    browser.calls.should eq(["must_connect", "must_page:https://example.com"])
    page.should be_a(BangAliasPage)
  end

  it "routes page bang methods to must_ methods" do
    page = BangAliasPage.new
    element = page.element!("#main")
    result = page.eval!("() => 1")

    page.calls.should eq(["must_element:#main", "must_eval:() => 1:0"])
    element.should be_a(BangAliasElement)
    result.should eq(JSON.parse(%("ok")))
  end

  it "routes element bang methods to must_ methods" do
    page = BangAliasPage.new
    element = BangAliasElement.new(page)

    clicked = element.click!
    text = element.text!

    element.calls.should eq(["must_click", "must_text"])
    clicked.should be(element)
    text.should eq("bang-text")
  end

  it "routes launcher bang methods to must_ methods" do
    launcher = BangAliasLauncher.new
    client = launcher.client!

    launcher.calls.should eq(["must_client"])
    client.should be_a(Rod::Util::Cdp::Client)
  end

  it "routes pool bang methods to must_get and forwards the block" do
    pool = Rod::Pool(Int32).new(1)

    pool.get! { 7 }.should eq(7)

    # Once an element is returned, `get!` reuses it instead of calling the block.
    pool.put(3)
    pool.get! { 9 }.should eq(3)
  end
end
