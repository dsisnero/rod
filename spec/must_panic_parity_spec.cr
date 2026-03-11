require "./spec_helper"

private class PanicRaised < Exception
end

private class PanicTestBrowser < Rod::Browser
  property page_error : Exception? = nil
  property next_page : Rod::Page? = nil

  def page(url : String = "about:blank") : Rod::Page
    if ex = @page_error
      raise ex
    end

    @next_page || PanicTestPage.new(self)
  end
end

private class PanicTestPage < Rod::Page
  property element_error : Exception? = nil
  property next_element : Rod::Element? = nil

  def initialize(browser : Rod::Browser)
    super(browser, Rod::TargetID.new("panic-target"))
  end

  def element(selector : String) : Rod::Element
    if ex = @element_error
      raise ex
    end

    @next_element || raise Rod::NotFoundError.new
  end
end

private class PanicTestElement < Rod::Element
  property click_error : Exception? = nil

  def initialize(page : Rod::Page)
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"panic-obj","description":"div"}))
    super(obj, page)
  end

  def click(button : String = "left", click_count : Int32 = 1) : Nil
    if ex = @click_error
      raise ex
    end
  end
end

describe "must panic parity" do
  it "matches Browser.WithPanic behavior from Go must_test" do
    triggers = 0
    trigger = ->(ex : Exception) do
      triggers += 1
      raise PanicRaised.new(ex.message || ex.class.name)
    end

    browser = PanicTestBrowser.new.with_panic(trigger)

    browser.page_error = Exception.new("bad page")
    expect_raises(PanicRaised) { browser.must_page("____") }
    triggers.should eq(1)

    page = PanicTestPage.new(browser)
    browser.page_error = nil
    browser.next_page = page

    page.element_error = Rod::NotFoundError.new
    expect_raises(PanicRaised) { page.must_element("____") }
    triggers.should eq(2)

    element = PanicTestElement.new(page)
    page.element_error = nil
    page.next_element = element
    element.click_error = Exception.new("click failed")

    expect_raises(PanicRaised) { element.must_click }
    triggers.should eq(3)
  end

  it "matches Page.WithPanic behavior from Go must_test" do
    triggers = 0
    trigger = ->(ex : Exception) do
      triggers += 1
      raise PanicRaised.new(ex.message || ex.class.name)
    end

    browser = PanicTestBrowser.new

    browser.page_error = Exception.new("bad page")
    expect_raises(Exception) { browser.must_page("____") }
    triggers.should eq(0)

    page = PanicTestPage.new(browser).with_panic(trigger)
    browser.page_error = nil
    browser.next_page = page

    page.element_error = Rod::NotFoundError.new
    expect_raises(PanicRaised) { page.must_element("____") }
    triggers.should eq(1)

    element = PanicTestElement.new(page)
    page.element_error = nil
    page.next_element = element
    element.click_error = Exception.new("click failed")

    expect_raises(PanicRaised) { element.must_click }
    triggers.should eq(2)
  end

  it "matches Element.WithPanic behavior from Go must_test" do
    triggers = 0
    trigger = ->(ex : Exception) do
      triggers += 1
      raise PanicRaised.new(ex.message || ex.class.name)
    end

    browser = PanicTestBrowser.new

    browser.page_error = Exception.new("bad page")
    expect_raises(Exception) { browser.must_page("____") }
    triggers.should eq(0)

    page = PanicTestPage.new(browser)
    page.element_error = Rod::NotFoundError.new
    expect_raises(Rod::NotFoundError) { page.must_element("____") }
    triggers.should eq(0)

    element = PanicTestElement.new(page).with_panic(trigger)
    element.click_error = Exception.new("click failed")

    expect_raises(PanicRaised) { element.must_click }
    triggers.should eq(1)
  end
end
