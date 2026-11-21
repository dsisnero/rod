require "./spec_helper"

# go-rod's `TestSetDocumentContent` (`page_test.go:268-310`): replacing the
# document without a navigation must keep queries and the doctype intact. It is
# also the only upstream test that swaps the document in place, which is where a
# cached DOM document root goes stale.
private DOCTYPE_HTML4_STRICT = %(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">)
private DOCTYPE_HTML4_LOOSE  = %(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">)
private DOCTYPE_XHTML11      = %(<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">)
private DOCTYPE_HTML5        = %(<!DOCTYPE html>)
private DOCUMENT_BODY        = "<html><head></head><body><div>test</div></body></html>"

private QUICK_QUERY = Rod::QueryOptions.new(timeout: 500.milliseconds, retry_interval: 10.milliseconds)

describe "page set_document_content parity" do
  it "replaces the document and keeps queries working like go's TestSetDocumentContent" do
    RodSpec.with_live_browser do |browser|
      page = browser.must_page("about:blank")
      begin
        page.must_wait_load

        page.set_document_content("#{DOCTYPE_HTML4_STRICT}#{DOCUMENT_BODY}")
        page.element("div", QUICK_QUERY).text.should eq("test")
        page.element("html", QUICK_QUERY).html.should eq(DOCUMENT_BODY)
        page.element("head", QUICK_QUERY).text.should eq("")
        page.eval("() => new XMLSerializer().serializeToString(document)").value.to_s
          .should contain(%(<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"))

        page.set_document_content("#{DOCTYPE_HTML4_LOOSE}#{DOCUMENT_BODY}")
        page.element("div", QUICK_QUERY).text.should eq("test")

        page.set_document_content("#{DOCTYPE_XHTML11}#{DOCUMENT_BODY}")
        page.element("div", QUICK_QUERY).text.should eq("test")

        page.set_document_content("#{DOCTYPE_HTML5}#{DOCUMENT_BODY}")
        page.element("div", QUICK_QUERY).text.should eq("test")
        page.eval("() => new XMLSerializer().serializeToString(document)").value.to_s
          .should start_with("<!DOCTYPE html>")
      ensure
        page.must_close
      end
    end
  end
end
