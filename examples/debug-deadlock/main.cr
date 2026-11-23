require "../../src/rod"

# Crystal analogue of go-rod's `lib/examples/debug-deadlock` example: it shows
# where a blocked CDP call surfaces once the operation is unblocked.
def your_code_here
  page = Rod::Browser.new.connect!.page!("http://mdn.dev")
  spawn { page.element!("not-exists") }
end

def check_lock
  start = Time.instant
  -> do
    elapsed = Time.instant - start
    puts "Potential hang window elapsed: #{elapsed.total_seconds.round(2)}s"
  end
end

ensure_report = check_lock
your_code_here
sleep 3.seconds
ensure_report.call
