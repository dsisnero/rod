require "spec"
require "../src/rod"

private def fake_element(page : Rod::Page) : Rod::Element
  obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","subtype":"node","objectId":"obj-1"}))
  Rod::Element.new(obj, page)
end

private class SearchRacePage < Rod::Page
  property search_result : Rod::SearchResult?

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def search(query : String) : Rod::SearchResult
    @search_result || raise Rod::NotFoundError.new("missing search result")
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    %({}).to_slice
  end
end

describe Rod::RaceContext do
  it "#handle raises when no branch has been added" do
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
    race = Rod::RaceContext.new(page)

    expect_raises(Exception, /No branch to handle/) do
      race.handle { |_el| }
    end
  end

  it "#do returns first successful branch and runs handle callback for that branch" do
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
    target = fake_element(page)
    handled = [] of Rod::Element

    race = Rod::RaceContext.new(page)
    race.element_func { |_p| raise Rod::NotFoundError.new("first miss") }
    race.element_func { |_p| target }
    race.handle { |element| handled << element }

    result = race.do
    result.should eq(target)
    handled.should eq([target])
  end

  it "#do propagates non-not-found errors immediately" do
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
    race = Rod::RaceContext.new(page)
    race.element_func { |_p| raise Exception.new("boom") }

    expect_raises(Exception, /boom/) do
      race.do
    end
  end

  it "#do retries not-found branches until sleeper errors" do
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("target-id"))
    page.sleeper = -> { Rod::Lib::Utils.count_sleeper(1) }
    race = Rod::RaceContext.new(page)
    race.element_func { |_p| raise Rod::NotFoundError.new("missing") }

    expect_raises(Rod::Lib::Utils::MaxSleepCountError) do
      race.do
    end
  end

  it "#search branch releases search result and returns first element" do
    page = SearchRacePage.new
    target = fake_element(page)
    released = false

    result = Rod::SearchResult.new(Cdp::DOM::PerformSearchResult.new("sid", 1), page, -> { released = true })
    result.first = target
    page.search_result = result

    found = page.race.search("button").do
    found.should eq(target)
    released.should be_true
  end

  it "#search branch treats nil first element as not found" do
    page = SearchRacePage.new
    page.sleeper = -> { Rod::Lib::Utils.count_sleeper(1) }

    result = Rod::SearchResult.new(Cdp::DOM::PerformSearchResult.new("sid", 0), page, -> { })
    result.first = nil
    page.search_result = result

    expect_raises(Rod::Lib::Utils::MaxSleepCountError) do
      page.race.search("missing").do
    end
  end
end
