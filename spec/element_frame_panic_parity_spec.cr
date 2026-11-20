require "./spec_helper"

# go's `Element.Frame` clones the page by struct assignment (`clone := *el.page`,
# `vendor/rod/element.go:458-471`), so the iframe page inherits the panic function
# (`e`) and only the frame id, JS context id, element and sleeper are replaced.
# Crystal builds a fresh `Page` instead, so the handler has to be carried over
# explicitly; without it `frame.must_*` raises without ever calling the handler
# the page installed (`page.go:1061-1069`, `must.go:34-40`).
private class FrameNodeElement < Rod::Element
  def initialize(page : Rod::Page, @reported_frame_id : String = "frame-1")
    object = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"frame-obj","description":"iframe"}))
    super(object, page)
  end

  def describe(depth : Int32 = 1, pierce : Bool = false) : ::Cdp::DOM::Node
    _ = depth
    _ = pierce
    ::Cdp::DOM::Node.from_json(
      %({"nodeId":1,"backendNodeId":1,"nodeType":1,"nodeName":"IFRAME","localName":"iframe","nodeValue":"","frameId":"#{@reported_frame_id}"})
    )
  end
end

describe "Element#frame panic handler parity" do
  it "carries the page's panic handler into the iframe page" do
    errors = [] of String
    page = Rod::Page.new(Rod::Browser.new, Rod::TargetID.new("frame-target"))
    page.set_panic_handler(->(ex : Exception) {
      errors << ex.message.to_s
      nil
    })

    frame = FrameNodeElement.new(page).frame

    frame.iframe?.should be_true
    frame.frame_id.should eq(Rod::FrameID.new("frame-1"))

    # The clone wraps the element's page, so a failing `must_*` on it must reach
    # that page's handler before the error is re-raised.
    expect_raises(Exception) { frame.must_element("#missing") }
    errors.size.should eq(1)
  end
end
