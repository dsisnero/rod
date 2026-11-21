require "./spec_helper"

# go builds the shadow root element through `el.page.Context(el.ctx).ElementFromObject`
# (`vendor/rod/element.go:437-456`), so the returned element carries the receiver's
# context and resolves its JS context the same way every other object-based element
# does. Building it with `Element.new(object, @page, @page.ctx, ...)` drops the
# element's context, so a clone's deadline or cancellation never reaches the
# shadow root.
#
# The same rule covers the element's own CDP requests: go passes the element as
# the client (`proto.DOMX{...}.Call(el)`) and `proto.call` takes the context from
# `Element.GetContext()` (`lib/proto/a_interface.go:50-57`, `context.go:104-106`),
# which is why `Describe`, `Shape`, `ScrollIntoView`, `SetFiles` and the
# `ShadowRoot` node resolution all honour an `Element#timeout`/`#context` clone.
private def shadow_root_fixture_url(name : String) : String
  "file://#{File.expand_path("vendor/rod/fixtures/#{name}", Dir.current)}"
end

private SHADOW_CONTEXT_QUERY = Rod::QueryOptions.new(timeout: 2.seconds, retry_interval: 10.milliseconds)

describe "Element#shadow_root parity" do
  it "binds the shadow root to the element's context like go's ElementFromObject" do
    RodSpec.with_live_browser do |browser|
      page = browser.must_page(shadow_root_fixture_url("shadow-dom.html"))
      begin
        page.must_wait_load

        host = page.element("#container", SHADOW_CONTEXT_QUERY)
        ctx, cancel = host.ctx.with_cancel
        shadow = host.context(ctx).shadow_root

        # The shadow root still works while the context is live.
        shadow.element("p").text.should eq("inside")

        # go hands the element's context to the shadow root, so cancelling it must
        # stop the next operation. Before the fix the clone answered with the
        # page's context and this call succeeded.
        cancel.call
        expect_raises(Rod::ContextCanceledError) { shadow.element("p") }
      ensure
        page.must_close
      end
    end
  end
end

describe "Element CDP requests parity" do
  it "runs describe/shape/set_files in the element's context like go's Element.Call" do
    RodSpec.with_live_browser do |browser|
      page = browser.must_page(shadow_root_fixture_url("click.html"))
      begin
        page.must_wait_load

        button = page.element("button", SHADOW_CONTEXT_QUERY)
        ctx, cancel = button.ctx.with_cancel
        timed = button.context(ctx)

        # Sanity check the same calls work with a live context.
        timed.describe(1, false).node_name.should eq("BUTTON")
        timed.shape.quads.should_not be_empty

        cancel.call

        # go's `Describe`/`Shape`/`SetFiles` call CDP with the element as the
        # client, so a cancelled element context stops them. Before the fix they
        # ran on the page's context and answered normally.
        expect_raises(Rod::ContextCanceledError) { timed.describe(1, false) }
        expect_raises(Rod::ContextCanceledError) { timed.shape }
        expect_raises(Rod::ContextCanceledError) { timed.set_files(["./temp/not-a-file.txt"]) }
      ensure
        page.must_close
      end
    end
  end
end
