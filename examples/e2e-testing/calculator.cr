require "./setup"

APP_URL = "https://go-rod.github.io/calculator/"

def test_add(ctx : E2EContext) : Bool
  page = ctx.page(APP_URL)
  page.must_element_r("button", "1").must_click
  page.must_element_r("button", "^\\+$").must_click
  page.must_element_r("button", "2").must_click
  page.must_element_r("button", "=").must_click
  page.must_element(".component-display").must_text == "3"
end

def test_multiple(ctx : E2EContext) : Bool
  page = ctx.page(APP_URL)
  ["2", "x", "3", "="].each { |regex| page.must_element_r("button", regex).must_click }
  page.must_element(".component-display").must_text == "6"
end

ctx = E2EContext.new
puts "TestAdd: #{test_add(ctx)}"
puts "TestMultiple: #{test_multiple(ctx)}"
