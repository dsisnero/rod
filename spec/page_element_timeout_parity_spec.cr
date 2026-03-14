require "./spec_helper"

private class ElementTimeoutStubBrowser < Rod::Browser
  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = method
    _ = params
    %({}).to_slice
  end
end

private class ElementTimeoutStubPage < Rod::Page
  def initialize
    super(ElementTimeoutStubBrowser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    case method
    when "DOM.getDocument"
      %({"root":{"nodeId":1,"backendNodeId":2,"nodeType":9,"nodeName":"#document","localName":"","nodeValue":""}}).to_slice
    when "DOM.querySelector"
      %({"nodeId":0}).to_slice
    else
      raise "unexpected method: #{method}"
    end
  end
end

describe "page element timeout parity" do
  it "respects context timeout while polling for missing elements" do
    page = ElementTimeoutStubPage.new
    timed = page.timeout(60.milliseconds)
    started = Time.instant

    ex = expect_raises(Rod::DeadlineExceededError) do
      timed.element("not-exists", Rod::QueryOptions.new(timeout: 5.seconds, retry_interval: 10.milliseconds))
    end
    ex.message.to_s.should contain("context deadline exceeded")

    elapsed = Time.instant - started
    elapsed.should be >= 50.milliseconds
  end

  it "surfaces MaxSleepCountError with count_sleeper (Go TestPageElementMaxRetry parity)" do
    page = ElementTimeoutStubPage.new
    limited = page.sleeper(-> { Rod::Util::Utils.count_sleeper(2) })

    expect_raises(Rod::Util::Utils::MaxSleepCountError) do
      limited.element("not-exists", Rod::QueryOptions.new(timeout: 30.milliseconds, retry_interval: 5.milliseconds))
    end
  end
end
