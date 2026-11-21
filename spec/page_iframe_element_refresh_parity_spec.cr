require "./spec_helper"

# When Chrome answers a stale-node error while the iframe page resolves its JS
# context, `refresh_iframe_element` re-finds the `<iframe>` node and becomes the
# page's backing element again (`page.cr:2224-2249`).
#
# go keeps that backing element on the *parent* page (`Element.Frame` does
# `clone.element = el` with the element's own page, `element.go:458-471`), and
# every object-based element goes through `ElementFromObject`, which resolves the
# object's JS context on the page that builds it (`page.go:928-954`). The refresh
# built the element with `Element.new(object, self, ...)` instead, so the iframe
# page (whose JS context is the content document) became the owner of an element
# that lives in the parent's document: helper injection then targets the wrong
# JS world.
private class IframeRefreshStubBrowser < Rod::Browser
  getter calls = [] of {String, JSON::Any}

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    @calls << {method, params}

    body = case method
           when "DOM.getDocument"
             %({"root":{"nodeId":1,"backendNodeId":2,"nodeType":9,"nodeName":"#document","localName":"","nodeValue":""}})
           when "DOM.querySelectorAll"
             %({"nodeIds":[4]})
           when "DOM.resolveNode"
             if params.as_h["nodeId"]?.try(&.as_i64?) == 4_i64
               %({"object":{"type":"object","objectId":"refreshed-iframe","description":"iframe"}})
             else
               %({"object":{"type":"object","objectId":"content-doc","description":"#document"}})
             end
           when "DOM.describeNode"
             # The cached iframe node belongs to the previous document.
             if params.as_h["objectId"]?.try(&.as_s?) == "iframe-el"
               raise Exception.new("{-32000 Node with given id does not belong to the document }")
             end
             %({"node":{"nodeId":6,"backendNodeId":8,"nodeType":1,"nodeName":"IFRAME","localName":"iframe","nodeValue":"","frameId":"frame-1","contentDocument":{"nodeId":7,"backendNodeId":5,"nodeType":9,"nodeName":"#document","localName":"","nodeValue":""}}})
           when "Runtime.evaluate"
             # Only the parent page resolves a window this way; the iframe branch
             # goes through `js_ctx_id_by_object_id`.
             %({"result":{"type":"object","objectId":"parent-window"}})
           when "Runtime.callFunctionOn"
             case params.as_h["objectId"]?.try(&.as_s?)
             when "content-doc"
               %({"result":{"type":"object","objectId":"iframe-window"}})
             when "iframe-window"
               %({"result":{"type":"boolean","value":true}})
             else
               # `() => window` on the refreshed iframe element: the element
               # lives in the parent document.
               %({"result":{"type":"object","objectId":"parent-window"}})
             end
           else
             %({})
           end

    body.to_slice
  end
end

describe "iframe element refresh parity" do
  it "rebuilds the iframe element on the parent page like go's ElementFromObject" do
    browser = IframeRefreshStubBrowser.new
    parent = Rod::Page.new(browser, Rod::TargetID.new("target-id"))
    iframe_object = Cdp::Runtime::RemoteObject.from_json(
      %({"type":"object","subtype":"node","objectId":"iframe-el","description":"iframe"})
    )
    iframe_element = Rod::Element.new(iframe_object, parent)
    page = Rod::Page.new(browser, Rod::TargetID.new("target-id"), nil, Rod::FrameID.new("frame-1"), Rod::Context.background, -> { Rod::Utils::Sleeper.new }, iframe_element)

    page.eval("() => 1").value.try(&.as_bool?).should be_true

    refreshed = page.element.not_nil!
    refreshed.object.object_id.should eq("refreshed-iframe")
    refreshed.page.should be(parent)
    browser.calls.any? { |(method, _)| method == "Runtime.evaluate" }.should be_true
  end
end
