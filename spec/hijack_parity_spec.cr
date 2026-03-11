require "spec"
require "../src/rod"

private def make_hijack_request(
  url : String = "https://example.com/a",
  method : String = "POST",
  body : String? = %({"k":"v"}),
  resource_type : Cdp::Network::ResourceType = Cdp::Network::ResourceTypeXHR,
) : Rod::HijackRequest
  net_req = Cdp::Network::Request.from_json(
    {
      "url"             => url,
      "method"          => method,
      "headers"         => {"Origin" => "https://example.com", "Content-Type" => "application/json"},
      "postData"        => body,
      "initialPriority" => Cdp::Network::ResourcePriorityHigh,
      "referrerPolicy"  => Cdp::Network::ReferrerPolicyStrictOriginWhenCrossOrigin,
    }.to_json
  )

  event = Cdp::Fetch::RequestPausedEvent.new(
    request_id: "req-1",
    request: net_req,
    frame_id: "frame-1",
    resource_type: resource_type,
    response_error_reason: nil,
    response_status_code: nil,
    response_status_text: nil,
    response_headers: nil,
    network_id: nil,
    redirected_request_id: nil
  )

  resource = URI.parse(url).request_target
  req = HTTP::Request.new(method, resource, HTTP::Headers.new, body || "")
  Rod::HijackRequest.new(event: event, req: req)
end

private def make_hijack_response : Rod::HijackResponse
  Rod::HijackResponse.new(
    payload: Cdp::Fetch::FulfillRequest.new(
      request_id: "req-1",
      response_code: 200,
      response_headers: [] of Cdp::Fetch::HeaderEntry,
      binary_response_headers: nil,
      body: nil,
      response_phrase: nil
    ),
    fail: Cdp::Fetch::FailRequest.new(
      request_id: "req-1",
      error_reason: ""
    )
  )
end

private def request_body_text(req : HTTP::Request) : String
  body = req.body
  return "" unless body

  case body
  when String
    body
  when Bytes
    String.new(body)
  else
    body.gets_to_end
  end
end

private def header_first_value(headers : HTTP::Headers, key : String) : String?
  value = headers.get(key)
  return value.first? if value.is_a?(Array)
  value
end

private class HijackErrorEventBrowser < Rod::Browser
  property fail_method : String? = nil
  property paused_url : String = "https://example.test/a"

  def context(ctx : Rod::Context) : Rod::Browser
    _ = ctx
    self
  end

  def each_event(session_id : Rod::SessionID?, callbacks : Hash(String, Rod::Browser::CallbackInfo)) : Proc(Nil)
    -> do
      callback = callbacks["Fetch.requestPaused"]?
      return unless callback

      event = Cdp::Fetch::RequestPausedEvent.from_json(
        {
          "requestId" => "req-1",
          "request"   => {
            "url"             => @paused_url,
            "method"          => "GET",
            "headers"         => {} of String => String,
            "initialPriority" => Cdp::Network::ResourcePriorityHigh,
            "referrerPolicy"  => Cdp::Network::ReferrerPolicyStrictOriginWhenCrossOrigin,
          },
          "frameId"      => "frame-1",
          "resourceType" => Cdp::Network::ResourceTypeDocument,
        }.to_json
      )

      callback.callback.call(event, session_id)
      sleep 5.milliseconds
    end
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    if fail_method = @fail_method
      if method == fail_method
        raise Exception.new("err")
      end
    end

    %({}).to_slice
  end
end

describe "Hijack parity" do
  it "supports hijack request body parsing and mutation" do
    request = make_hijack_request

    request.method.should eq("POST")
    request.type.should eq(Cdp::Network::ResourceTypeXHR)
    request.navigation?.should be_false
    request.header("Origin").should eq("https://example.com")
    request.json_body["k"].as_s.should eq("v")

    request.set_body("test")
    request_body_text(request.req).should eq("test")

    request.set_body(JSON::Any.new({"x" => JSON::Any.new(1_i64)}))
    JSON.parse(request_body_text(request.req))["x"].as_i.should eq(1)

    request.set_body(123)
    request_body_text(request.req).should eq("123")

    request.set_body({"text" => "test"})
    request_body_text(request.req).should eq(%({"text":"test"}))
  end

  it "marks document resource requests as navigation" do
    request = make_hijack_request(resource_type: Cdp::Network::ResourceTypeDocument)
    request.navigation?.should be_true
  end

  it "supports response header and body override semantics" do
    response = make_hijack_response

    response.add_header("Set-Cookie", "key=val1")
    response.set_header("Set-Cookie", "key=val")
    response.set_header("Content-Type", "application/json")

    headers = response.headers
    header_first_value(headers, "Set-Cookie").should eq("key=val")
    header_first_value(headers, "Content-Type").should eq("application/json")

    response.set_body("test")
    response.body.should eq("test")

    response.set_body(JSON::Any.new({"text" => JSON::Any.new("test")}))
    response.body.should eq(%({"text":"test"}))

    response.set_body(123)
    response.body.should eq("123")

    response.set_body({"text" => "test"})
    response.body.should eq(%({"text":"test"}))
  end

  it "matches TestHijackMockWholeResponseEmptyBody payload semantics" do
    response = make_hijack_response

    response.set_body("")
    response.payload.body.should_not be_nil
    response.payload.body.should eq("")
    response.body.should eq("")
  end

  it "matches TestHijackMockWholeResponseNoBody default payload semantics" do
    response = make_hijack_response

    response.payload.body.should be_nil
    response.body.should eq("")
  end

  it "supports continue_request and skip flags" do
    hijack = Rod::Hijack.new(
      request: make_hijack_request,
      response: make_hijack_response,
      on_error: ->(_err : Exception) { },
      browser: Rod::Browser.new
    )

    hijack.skip.should be_false
    hijack.skip = true
    hijack.skip.should be_true

    cont = Cdp::Fetch::ContinueRequest.new(request_id: "", url: nil, method: nil, post_data: nil, headers: nil, intercept_response: nil)
    hijack.continue_request(cont)
    hijack.continue_request.should eq(cont)
  end

  it "supports fail request reason override semantics" do
    response = make_hijack_response
    response.fail(Cdp::Network::ErrorReasonAborted)

    response.fail.error_reason.should eq(Cdp::Network::ErrorReasonAborted)
  end

  it "load_response surfaces upstream client errors" do
    hijack = Rod::Hijack.new(
      request: make_hijack_request(url: "http://127.0.0.1:1/a"),
      response: make_hijack_response,
      on_error: ->(_err : Exception) { },
      browser: Rod::Browser.new
    )

    client = HTTP::Client.new("127.0.0.1", 1)
    expect_raises(Exception) do
      hijack.load_response(client, true)
    end
  ensure
    client.try(&.close)
  end

  it "forwards continue_request errors to hijack on_error callback" do
    browser = HijackErrorEventBrowser.new
    browser.fail_method = "Fetch.continueRequest"
    router = Rod::HijackRouter.new(browser, browser).init_events

    err_messages = Channel(String).new(1)
    router.add("https://example.test/a", Cdp::Network::ResourceTypeDocument, ->(ctx : Rod::Hijack) do
      ctx.on_error = ->(err : Exception) do
        err_messages.send(err.message.to_s)
        nil
      end
      ctx.continue_request(Cdp::Fetch::ContinueRequest.new("", nil, nil, nil, nil, nil))
    end)

    router.run
    select
    when msg = err_messages.receive
      msg.should eq("err")
    when timeout(1.second)
      raise "timed out waiting for hijack on_error callback"
    end
  ensure
    router.try { |r| r.stop rescue nil }
  end

  it "forwards fulfill_request errors to hijack on_error callback" do
    browser = HijackErrorEventBrowser.new
    browser.fail_method = "Fetch.fulfillRequest"
    router = Rod::HijackRouter.new(browser, browser).init_events

    err_messages = Channel(String).new(1)
    router.add("https://example.test/a", Cdp::Network::ResourceTypeDocument, ->(ctx : Rod::Hijack) do
      ctx.on_error = ->(err : Exception) do
        err_messages.send(err.message.to_s)
        nil
      end
      ctx.response.set_body("ok")
      nil
    end)

    router.run
    select
    when msg = err_messages.receive
      msg.should eq("err")
    when timeout(1.second)
      raise "timed out waiting for hijack on_error callback"
    end
  ensure
    router.try { |r| r.stop rescue nil }
  end
end
