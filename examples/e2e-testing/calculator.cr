require "./setup"

APP_URL = "https://go-rod.github.io/calculator/"

# Ported from go-rod's `lib/examples/e2e-testing/calculator_test.go`.
# Every case works on its own incognito page and closes it, like the Go helper
# registers `g.Cleanup(page.MustClose)`.
def test_add(ctx : E2EContext) : Bool
  page = ctx.page(APP_URL)
  begin
    page.must_element_r("button", "1").must_click
    page.must_element_r("button", "^\\+$").must_click
    page.must_element_r("button", "2").must_click
    page.must_element_r("button", "=").must_click

    page.must_element(".component-display").must_text == "3"
  ensure
    page.must_close
  end
end

def test_multiple(ctx : E2EContext) : Bool
  page = ctx.page(APP_URL)
  begin
    ["2", "x", "3", "="].each { |regex| page.must_element_r("button", regex).must_click }

    page.must_element(".component-display").must_text == "6"
  ensure
    page.must_close
  end
end

ctx = E2EContext.new
begin
  puts "TestAdd: #{test_add(ctx)}"
  puts "TestMultiple: #{test_multiple(ctx)}"
ensure
  ctx.close
end
