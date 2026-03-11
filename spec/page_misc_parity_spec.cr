require "./spec_helper"

private class PageHTMLStubPage < Rod::Page
  property html_value : String = "<html></html>"
  property html_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def element(selector : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    _ = selector
    _ = opts
    raise html_error.not_nil! if html_error

    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-html","description":"html"}))
    HtmlElement.new(obj, self, @html_value)
  end
end

private class HtmlElement < Rod::Element
  def initialize(object : Cdp::Runtime::RemoteObject, page : Rod::Page, @value : String)
    super(object, page)
  end

  def html : String
    @value
  end
end

private class WaitLoadErrorPage < Rod::Page
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    _ = opts
    if ex = @eval_error
      raise ex
    end
    Cdp::Runtime::RemoteObject.from_json(%({"type":"undefined"}))
  end
end

private class SessionErrorBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    raise Exception.new(Cdp::ErrSessionNotFound.message)
  end
end

describe "page misc parity" do
  it "html returns html element outer html and surfaces element errors" do
    page = PageHTMLStubPage.new
    page.html.should eq("<html></html>")

    page.html_error = Exception.new("html failed")
    expect_raises(Exception, /html failed/) { page.html }
  end

  it "wait_load propagates evaluate errors" do
    page = WaitLoadErrorPage.new
    page.eval_error = Exception.new("runtime call failed")

    expect_raises(Exception, /runtime call failed/) { page.wait_load }
  end

  it "page_from_session returns page that propagates session-not-found errors" do
    browser = SessionErrorBrowser.new
    page = browser.page_from_session(Rod::SessionID.new("not-exist"))

    expect_raises(Exception, /Session with given id not found/) do
      Cdp::Page::Close.new.call(page)
    end
  end
end
