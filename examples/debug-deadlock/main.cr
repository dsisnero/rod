require "../../src/rod"

# Crystal analogue of the Go deadlock-debug example.
def your_code_here
  page = Rod::Browser.new.must_connect.must_page("http://mdn.dev")
  spawn { page.must_element("not-exists") }
end

def check_lock
  start = Time.monotonic
  -> do
    elapsed = Time.monotonic - start
    puts "Potential hang window elapsed: #{elapsed.total_seconds.round(2)}s"
  end
end

ensure_report = check_lock
your_code_here
sleep 3.seconds
ensure_report.call
