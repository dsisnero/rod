require "./spec_helper"

private class HasStubPage < Rod::Page
  property next_element : Rod::Element? = nil
  property element_error : Exception? = nil
  property element_x_error : Exception? = nil
  property element_r_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def element(selector : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    if ex = @element_error
      raise ex
    end
    @next_element || raise Rod::NotFoundError.new
  end

  def element_x(xpath : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    if ex = @element_x_error
      raise ex
    end
    @next_element || raise Rod::NotFoundError.new
  end

  def element_r(selector : String, regex : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    if ex = @element_r_error
      raise ex
    end
    @next_element || raise Rod::NotFoundError.new
  end
end

private class HasStubElement < Rod::Element
  property next_element : Rod::Element? = nil
  property element_error : Exception? = nil
  property element_x_error : Exception? = nil
  property element_r_error : Exception? = nil

  def initialize(page : Rod::Page)
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","description":"div"}))
    super(object, page)
  end

  def element(selector : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    if ex = @element_error
      raise ex
    end
    @next_element || raise Rod::NotFoundError.new
  end

  def element_x(xpath : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    if ex = @element_x_error
      raise ex
    end
    @next_element || raise Rod::NotFoundError.new
  end

  def element_r(selector : String, regex : String, opts : Rod::QueryOptions? = nil) : Rod::Element
    if ex = @element_r_error
      raise ex
    end
    @next_element || raise Rod::NotFoundError.new
  end
end

describe "Query has parity" do
  it "page has/has_x/has_r return false,nil on NotFound" do
    page = HasStubPage.new

    page.has("a").should eq({false, nil})
    page.has_x("//a").should eq({false, nil})
    page.has_r("a", "b").should eq({false, nil})
  end

  it "page has/has_x/has_r return true,element when found" do
    page = HasStubPage.new
    el = HasStubElement.new(page)
    page.next_element = el

    page.has("a").should eq({true, el.as(Rod::Element?)})
    page.has_x("//a").should eq({true, el.as(Rod::Element?)})
    page.has_r("a", "b").should eq({true, el.as(Rod::Element?)})
  end

  it "page has_x/has_r propagate non-NotFound errors" do
    page = HasStubPage.new
    page.element_x_error = Exception.new("xerr")
    page.element_r_error = Exception.new("rerr")

    expect_raises(Exception, "xerr") { page.has_x("//a") }
    expect_raises(Exception, "rerr") { page.has_r("a", "b") }
  end

  it "element has/has_x/has_r mirror page semantics" do
    page = HasStubPage.new
    parent = HasStubElement.new(page)
    child = HasStubElement.new(page)
    parent.next_element = child

    parent.has("a").should eq({true, child.as(Rod::Element?)})
    parent.has_x("//a").should eq({true, child.as(Rod::Element?)})
    parent.has_r("a", "b").should eq({true, child.as(Rod::Element?)})

    parent.next_element = nil
    parent.has("a").should eq({false, nil})
  end
end
