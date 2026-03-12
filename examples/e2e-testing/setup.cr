require "../../src/rod"

class E2EContext
  getter browser : Rod::Browser

  def initialize
    @browser = Rod::Browser.new.must_connect
  end

  def page(url : String) : Rod::Page
    @browser.must_incognito.must_page(url)
  end
end
