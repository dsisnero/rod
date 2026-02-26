require "./spec_helper"

describe Rod::Browser do
  it "returns cloned browser instances for context-derived helpers" do
    browser = Rod::Browser.new

    timed = browser.timeout(1.second)
    timed.object_id.should_not eq(browser.object_id)
    timed.get_context.should_not be(browser.get_context)

    restored = timed.cancel_timeout
    restored.object_id.should_not eq(timed.object_id)
    restored.get_context.should be(browser.get_context)
  end

  it "returns a cloned browser when applying sleeper" do
    browser = Rod::Browser.new
    cloned = browser.sleeper(-> { Rod::Utils::Sleeper.new(1.millisecond) })

    cloned.object_id.should_not eq(browser.object_id)
  end
end
