require "./setup"

APP_URL = "https://go-rod.github.io/calculator/"

# Ported from go-rod's `lib/examples/e2e-testing/calculator_test.go`.
# Every case works on its own incognito page and closes it, like the Go helper
# registers `g.Cleanup(page.MustClose)`.
def test_add(ctx : E2EContext) : Bool
  page = ctx.page(APP_URL)
  begin
    page.element_r!("button", "1").click!
    page.element_r!("button", "^\\+$").click!
    page.element_r!("button", "2").click!
    page.element_r!("button", "=").click!

    page.element!(".component-display").text! == "3"
  ensure
    page.close!
  end
end

def test_multiple(ctx : E2EContext) : Bool
  page = ctx.page(APP_URL)
  begin
    ["2", "x", "3", "="].each { |regex| page.element_r!("button", regex).click! }

    page.element!(".component-display").text! == "6"
  ensure
    page.close!
  end
end

ctx = E2EContext.new
begin
  puts "TestAdd: #{test_add(ctx)}"
  puts "TestMultiple: #{test_multiple(ctx)}"
ensure
  ctx.close
end
