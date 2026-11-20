require "./spec_helper"

# Stubs for the pool contract: go-rod's `setup` resets the pooled page with
# `MustNavigate("")` and `page.MustClose`s the extra targets it created
# (vendor/rod/setup_test.go:121-190), so the pool has to blank the page it keeps
# and close the rest before handing the browser to the next example.
private class PoolStubPage < Rod::Page
  getter navigations = [] of String
  getter close_calls = 0
  getter name : String

  def initialize(browser : Rod::Browser, @name : String)
    super(browser, Rod::TargetID.new(@name), Rod::SessionID.new("sid-#{@name}"), Rod::FrameID.new(@name))
  end

  def navigate(url : String) : Nil
    @navigations << url
  end

  def close : Nil
    @close_calls += 1
    # A closed target disappears from `Browser#pages`, like a real browser.
    browser.as(PoolStubBrowser).remove_page(self)
  end
end

private class PoolStubBrowser < Rod::Browser
  getter created_pages = [] of PoolStubPage
  getter close_calls = 0

  # Lazily created so a page can hold a reference to its browser.
  def main_page : PoolStubPage
    created_pages << PoolStubPage.new(self, "main") if created_pages.empty?
    created_pages.first
  end

  def add_page(name : String) : PoolStubPage
    page = PoolStubPage.new(self, name)
    created_pages << page
    page
  end

  def remove_page(page : PoolStubPage) : Nil
    created_pages.delete(page)
  end

  def pages : Rod::Pages
    Rod::Pages.new(created_pages.map(&.as(Rod::Page)))
  end

  def close : Nil
    @close_calls += 1
  end
end

private def browser_contexts(browser : Rod::Browser) : Array(String)
  Cdp::Target::GetBrowserContexts.new.call(browser).browser_context_ids
end

private def pool_with_stub(&factory : -> Rod::Browser) : Tuple(RodSpec::LiveBrowserPool, Array(Rod::Browser))
  launched = [] of Rod::Browser
  pool = RodSpec::LiveBrowserPool.new do
    browser = factory.call
    launched << browser
    browser
  end
  {pool, launched}
end

describe "live browser pool" do
  it "reuses one browser across examples like go's testerPool" do
    pool, launched = pool_with_stub { PoolStubBrowser.new }

    first = nil.as(Rod::Browser?)
    second = nil.as(Rod::Browser?)
    pool.with { |browser| first = browser }
    pool.with { |browser| second = browser }

    launched.size.should eq(1)
    first.not_nil!.same?(second.not_nil!).should be_true
    pool.launches.should eq(1)
  end

  it "blanks the page it keeps and closes the extra pages" do
    pool, _launched = pool_with_stub { PoolStubBrowser.new }

    main = nil.as(PoolStubPage?)
    extra = nil.as(PoolStubPage?)
    pool.with do |browser|
      stub = browser.as(PoolStubBrowser)
      main = stub.main_page
      extra = stub.add_page("extra")
      main.not_nil!.navigate("https://example.com/left-behind")
    end

    pool.with do |browser|
      stub = browser.as(PoolStubBrowser)

      # go-rod resets the pooled page before the next example runs.
      main.not_nil!.navigations.last.should eq("")
      extra.not_nil!.close_calls.should eq(1)
      stub.created_pages.should eq([main.not_nil!])
    end
  end

  it "returns the browser to the pool when an example raises" do
    pool, launched = pool_with_stub { PoolStubBrowser.new }

    expect_raises(Exception, "boom") do
      pool.with { |_browser| raise "boom" }
    end

    pool.with { |_browser| nil }

    launched.size.should eq(1)
  end

  it "runs isolated examples in their own browser and closes it" do
    pool, launched = pool_with_stub { PoolStubBrowser.new }

    pooled = nil.as(Rod::Browser?)
    pool.with { |browser| pooled = browser }

    isolated = nil.as(Rod::Browser?)
    pool.with_isolated { |browser| isolated = browser }

    launched.size.should eq(2)
    isolated.not_nil!.same?(pooled.not_nil!).should be_false
    isolated.not_nil!.as(PoolStubBrowser).close_calls.should eq(1)

    # The isolated browser must not poison the pool.
    pool.with { |browser| browser.same?(pooled.not_nil!).should be_true }
  end

  it "closes every pooled browser on cleanup" do
    pool, launched = pool_with_stub { PoolStubBrowser.new }
    pool.with { |_browser| nil }

    pool.close_all

    launched.first.as(PoolStubBrowser).close_calls.should eq(1)
  end

  it "shares one browser between the live examples that use the harness" do
    next unless RodSpec.chrome_available?

    first : Rod::Browser? = nil
    second : Rod::Browser? = nil

    RodSpec.with_live_browser { |browser| first = browser }
    launches_after_first = RodSpec.live_browser_pool.launches
    RodSpec.with_live_browser { |browser| second = browser }

    # go-rod's `setup` hands every example the same pool slot, so a second
    # borrow must not launch another browser. Comparing against the launch count
    # right after the first borrow keeps the check independent of whether the
    # pool was already warm when the example started.
    RodSpec.live_browser_pool.launches.should eq(launches_after_first)
    first.not_nil!.same?(second.not_nil!).should be_true
  end

  it "disposes the incognito contexts an example created" do
    next unless RodSpec.chrome_available?

    launcher = Rod::Util::Launcher::Launcher.new
      .bin(RodSpec.chrome_bin)
      .headless(true)
      .no_sandbox(true)
      .leakless(false)

    pool = RodSpec::LiveBrowserPool.new do
      browser = Rod::Browser.new.control_url(launcher.launch)
      browser.connect
      browser
    end

    begin
      pool.with do |browser|
        # `spec/examples_e2e_calculator_parity_spec.cr` works in an incognito
        # context per example; a pooled browser must not accumulate them.
        browser.must_incognito.must_page("about:blank").must_close
        browser_contexts(browser).should_not be_empty
      end

      pool.with do |browser|
        browser_contexts(browser).should be_empty
      end
    ensure
      pool.close_all
      shutdown_launcher(launcher)
    end
  end

  it "reuses one real browser and resets its pages between examples" do
    next unless RodSpec.chrome_available?

    launcher = Rod::Util::Launcher::Launcher.new
      .bin(RodSpec.chrome_bin)
      .headless(true)
      .no_sandbox(true)
      .leakless(false)

    pool = RodSpec::LiveBrowserPool.new do
      browser = Rod::Browser.new.control_url(launcher.launch)
      browser.connect
      browser
    end

    fixture = "file://#{File.expand_path("../vendor/rod/fixtures/blank.html", __DIR__)}"
    first : Rod::Browser? = nil

    begin
      pool.with do |browser|
        browser.must_page(fixture).must_navigate(fixture)
        browser.must_page("about:blank")
        browser.pages.size.should be >= 2
        first = browser
      end

      pool.with do |browser|
        browser.same?(first.not_nil!).should be_true

        # The extra targets are closed and the kept page is blank, like go-rod's
        # `setup` before every example. `Target.closeTarget` settles
        # asynchronously, so poll instead of sampling once.
        eventually(5.seconds) { browser.pages.size == 1 }.should be_true
        browser.pages.first.not_nil!.info.url.should eq("about:blank")
      end
    ensure
      pool.close_all
      shutdown_launcher(launcher)
    end

    pool.launches.should eq(1)
  end
end
