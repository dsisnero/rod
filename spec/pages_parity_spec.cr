require "spec"
require "../src/rod"

private class PagesStubPage < Rod::Page
  property eval_error : Exception?

  def initialize(@stub_url : String, @selectors : Array(String) = [] of String)
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def has_element?(selector : String) : Bool
    @selectors.includes?(selector)
  end

  def info : Cdp::Target::TargetInfo
    Cdp::Target::TargetInfo.from_json(
      {
        "targetId"        => "target-id",
        "type"            => "page",
        "title"           => "stub",
        "url"             => @stub_url,
        "attached"        => false,
        "canAccessOpener" => false,
      }.to_json
    )
  end

  def eval(js : String, args : Array(JSON::Any) = [] of JSON::Any) : Cdp::Runtime::RemoteObject
    if error = @eval_error
      raise error
    end

    Cdp::Runtime::RemoteObject.from_json(
      {
        "type"  => "string",
        "value" => @stub_url,
      }.to_json
    )
  end
end

describe Rod::Pages do
  it "supports first/last semantics for empty and non-empty lists" do
    list = Rod::Pages.new
    list.first.should be_nil
    list.last.should be_nil

    a = PagesStubPage.new("https://a.test")
    b = PagesStubPage.new("https://b.test")
    list << a << b

    list.first.should eq(a)
    list.last.should eq(b)
  end

  it "#find returns page containing selector and nil when no page matches" do
    a = PagesStubPage.new("https://a.test")
    b = PagesStubPage.new("https://b.test", ["button"])
    list = Rod::Pages.new([a.as(Rod::Page), b.as(Rod::Page)])

    list.find("button").should eq(b)
    list.find("missing").should be_nil
  end

  it "#find_by_url returns first matching page and nil when none match" do
    a = PagesStubPage.new("https://a.test/path")
    b = PagesStubPage.new("https://b.test/other")
    list = Rod::Pages.new([a.as(Rod::Page), b.as(Rod::Page)])

    list.find_by_url("a\\.test").should eq(a)
    list.find_by_url("c\\.test").should be_nil
  end

  it "must helpers return matching page and raise PageNotFoundError when absent" do
    a = PagesStubPage.new("https://a.test/path")
    b = PagesStubPage.new("https://b.test/other", ["button"])
    list = Rod::Pages.new([a.as(Rod::Page), b.as(Rod::Page)])

    list.must_find("button").should eq(b)
    list.must_find_by_url("a\\.test").should eq(a)

    expect_raises(Rod::PageNotFoundError) { list.must_find("missing") }
    expect_raises(Rod::PageNotFoundError) { list.must_find_by_url("c\\.test") }
  end

  it "#find_by_url propagates evaluation errors from pages" do
    a = PagesStubPage.new("https://a.test/path")
    b = PagesStubPage.new("https://b.test/other")
    b.eval_error = Exception.new("eval failed")
    list = Rod::Pages.new([a.as(Rod::Page), b.as(Rod::Page)])

    expect_raises(Exception, /eval failed/) { list.find_by_url("b\\.test") }
  end
end
