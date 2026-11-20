require "./spec_helper"

# go-rod's `Element.SelectAllText` (`element.go:241-254`) focuses the element and
# evaluates `evalHelper(js.SelectAllText).ByUser()`, i.e. `function(){this.select()}`
# (`lib/js/helper.go:152-156`). `Element.SelectText` does the same with
# `js.SelectText`, which calls `this.setSelectionRange(...)`.
#
# A document range (`window.getSelection()` + `range.selectNodeContents`) cannot
# select `<input>`/`<textarea>` contents: those keep their selection in
# `selectionStart`/`selectionEnd`, so nothing is selected and the following
# `InsertText` prepends instead of replacing.
private def with_live_browser(&block : Rod::Browser ->)
  RodSpec.with_live_browser { |browser| block.call(browser) }
end

private def with_input_page(browser : Rod::Browser, html : String, &block : Rod::Page, Rod::Element ->)
  page = browser.must_page("about:blank")
  page.must_eval("() => { document.body.innerHTML = #{html.inspect} }")
  begin
    block.call(page, page.must_element("input"))
  ensure
    page.must_close
  end
end

describe "element select_all_text parity" do
  it "replaces a text field's value like go-rod's SelectAllText" do
    with_live_browser do |browser|
      with_input_page(browser, %(<form><input name="q" value="hi"></form>)) do |page, input|
        input.select_all_text
        input.input("hello there")

        page.must_eval("() => document.querySelector('input').value").as_s.should eq("hello there")
      end
    end
  end

  it "selects a textarea's value like go-rod's SelectAllText" do
    with_live_browser do |browser|
      page = browser.must_page("about:blank")
      page.must_eval("() => { document.body.innerHTML = '<textarea>old</textarea>' }")
      begin
        area = page.must_element("textarea")
        area.select_all_text
        area.input("new")

        page.must_eval("() => document.querySelector('textarea').value").as_s.should eq("new")
      ensure
        page.must_close
      end
    end
  end

  it "selects all text by using go's js.SelectAllText helper" do
    with_live_browser do |browser|
      with_input_page(browser, %(<input value="abc">)) do |page, input|
        # The helper is registered on the page and cached per JS context, so a
        # second call reuses it instead of re-sending the definition.
        input.select_all_text
        page.must_eval("() => document.querySelector('input').selectionEnd").as_i.should eq(3)
      end
    end
  end

  it "replaces the matched text like go-rod's SelectText" do
    with_live_browser do |browser|
      with_input_page(browser, %(<input value="hello world">)) do |page, input|
        input.select_text("world")
        input.input("there")

        page.must_eval("() => document.querySelector('input').value").as_s.should eq("hello there")
      end
    end
  end
end
