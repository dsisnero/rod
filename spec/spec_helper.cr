require "spec"
require "../src/rod"
require "./support/live_browser_pool"

# Poll `condition` until it is true or `timeout` elapses. Used by specs that
# assert on state a spawned fiber changes (event delivery, browser teardown).
def eventually(timeout : Time::Span = 1.second, &condition : -> Bool) : Bool
  deadline = Time.instant + timeout
  until condition.call
    return false if Time.instant >= deadline
    sleep 5.milliseconds
  end
  true
end

# go-rod's tests `defer launcher.Cleanup()`: wait for the browser process to
# exit and delete its `user-data-dir`. Every spec that launches a real browser
# has to do the same, otherwise `$TMPDIR/rod/user-data` keeps one directory per
# example (go-rod's `Launcher.Cleanup`, vendor/rod/lib/launcher/launcher.go:561).
def shutdown_launcher(launcher : Rod::Util::Launcher::Launcher) : Nil
  launcher.kill
rescue
  # go-rod ignores kill failures while shutting a test browser down.
ensure
  begin
    launcher.cleanup
  rescue
    # Cleanup is best-effort in specs too; never mask the example's failure.
  end
end
