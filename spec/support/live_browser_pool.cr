require "../../src/rod"

# go-rod reuses a handful of browsers for its whole suite (`testerPool`,
# vendor/rod/setup_test.go:41): `newTester` launches one browser per slot and
# `setup` resets the pooled page with `MustNavigate("")` before each example.
# The Crystal live specs still launch and kill a browser per example (56
# launches for `spec/live_browser_parity_spec.cr`), which is the cost this pool
# removes one file at a time.
module RodSpec
  @@live_browser_pool : LiveBrowserPool? = nil

  # The Chrome binary the live specs drive (the same path the existing live spec
  # files hardcode, overridable for other machines).
  def self.chrome_bin : String
    ENV["ROD_CHROME_BIN"]? || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  end

  def self.chrome_available? : Bool
    File.exists?(chrome_bin)
  end

  # The browser every live spec borrows. go-rod launches browsers once per pool
  # slot (`newTester`) and closes them after the suite (`TestMain`); do the same,
  # including each browser's launcher so its profile is removed on exit.
  def self.live_browser_pool : LiveBrowserPool
    @@live_browser_pool ||= build_live_browser_pool
  end

  private def self.build_live_browser_pool : LiveBrowserPool
    launchers = {} of UInt64 => Rod::Util::Launcher::Launcher

    pool = LiveBrowserPool.new(disposer: ->(browser : Rod::Browser) {
      launcher = launchers.delete(browser.object_id)
      shutdown_launcher(launcher) if launcher
    }) do
      launcher = Rod::Util::Launcher::Launcher.new
        .bin(chrome_bin)
        .headless(true)
        .no_sandbox(true)
        .leakless(false)

      browser = Rod::Browser.new.control_url(launcher.launch)
      browser.connect
      launchers[browser.object_id] = launcher
      browser
    end

    at_exit do
      pool.close_all
      # Cheap observability for harness work: `ROD_POOL_STATS=1 crystal spec ...`
      # prints how many browsers the run launched.
      STDERR.puts "[rod pool] launches=#{pool.launches}" if ENV["ROD_POOL_STATS"]? == "1"
    end
    pool
  end

  # Borrow the pooled browser for one live example. `with_isolated_browser` is
  # for examples that change state the pool cannot reset: go-rod's tests do the
  # same by giving those tests their own browser (`newPage`, `tester.mc`).
  def self.with_live_browser(&block : Rod::Browser ->) : Nil
    live_browser_pool.with { |browser| block.call(browser) }
  end

  def self.with_isolated_browser(&block : Rod::Browser ->) : Nil
    live_browser_pool.with_isolated { |browser| block.call(browser) }
  end

  # Borrows a browser for the duration of a block and hands it back reset.
  # Grows by one browser per concurrent borrower, so a sequential suite reuses a
  # single browser exactly like go-rod's pool does.
  class LiveBrowserPool
    getter launches : Int32 = 0

    @free = [] of Rod::Browser
    @lock = Mutex.new
    @factory : -> Rod::Browser
    @disposer : Proc(Rod::Browser, Nil)?

    def initialize(@disposer : Proc(Rod::Browser, Nil)? = nil, &factory : -> Rod::Browser)
      @factory = factory
    end

    def with(&block : Rod::Browser ->) : Nil
      browser = acquire

      begin
        prepared = reset(browser)
      rescue ex
        # A browser that died between examples (crashed target, dropped socket)
        # must not poison the pool: drop it so the next borrower launches a
        # fresh one, and let the failure surface for this example.
        close_browser(browser)
        raise ex
      end

      begin
        block.call(prepared)
      ensure
        release(browser)
      end
    end

    # Launch a browser that is closed afterwards. go-rod's tests do the same for
    # examples that change state the pool cannot reset (killing the connection,
    # swapping the browser's client).
    def with_isolated(&block : Rod::Browser ->) : Nil
      browser = launch
      begin
        block.call(browser)
      ensure
        close_browser(browser)
      end
    end

    # Close every browser the pool still owns. Call it once the suite is done
    # (go-rod does it in `TestMain`, `setup_test.go:51`).
    def close_all : Nil
      browsers = @lock.synchronize do
        free = @free
        @free = [] of Rod::Browser
        free
      end
      browsers.each { |browser| close_browser(browser) }
    end

    # go-rod's `setup` (`setup_test.go:121-190`): blank the page the next example
    # inherits and close every other target the previous one left open. Browser
    # contexts are disposed too: live specs that work in an incognito context per
    # example (`examples_e2e_calculator_parity_spec.cr`) would otherwise leave
    # one behind on the shared browser.
    def reset(browser : Rod::Browser) : Rod::Browser
      pages = browser.pages.to_a
      pages.skip(1).each { |page| close_page(page) }
      pages.first?.try do |page|
        begin
          page.navigate("")
        rescue
          # go-rod's `MustNavigate` would panic here; the harness stays tolerant
          # and lets the next example surface its own navigation error.
        end
      end
      dispose_extra_contexts(browser)
      browser
    end

    private def acquire : Rod::Browser
      if browser = @lock.synchronize { @free.pop? }
        return browser
      end
      launch
    end

    private def release(browser : Rod::Browser) : Nil
      @lock.synchronize { @free.push(browser) }
    end

    private def launch : Rod::Browser
      @lock.synchronize { @launches += 1 }
      @factory.call
    end

    private def close_browser(browser : Rod::Browser) : Nil
      begin
        browser.close
      rescue
        # Shutdown is best effort, exactly like the launcher cleanup.
      end

      begin
        @disposer.try &.call(browser)
      rescue
        # Releasing the browser's launcher is best effort too.
      end
    end

    private def close_page(page : Rod::Page) : Nil
      page.close
    rescue
      # A page the previous example already closed is not an error.
    end

    # Drop every browser context the shared browser is not the owner of. The
    # default context is not listed by `Target.getBrowserContexts`, so anything
    # returned here was created by an example (an incognito context).
    private def dispose_extra_contexts(browser : Rod::Browser) : Nil
      own = browser.browser_context_id.try(&.value)
      Cdp::Target::GetBrowserContexts.new.call(browser).browser_context_ids.each do |id|
        next if id == own

        begin
          Cdp::Target::DisposeBrowserContext.new(id).call(browser)
        rescue
          # A context whose pages are already gone can fail to dispose.
        end
      end
    rescue
      # A browser that cannot list its contexts is the next example's problem.
    end
  end
end
