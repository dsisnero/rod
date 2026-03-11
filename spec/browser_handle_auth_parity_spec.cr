require "./spec_helper"

private class HandleAuthStubBrowser < Rod::Browser
  getter method_calls = [] of String
  property fail_continue_request = false

  def context(ctx : Rod::Context) : Rod::Browser
    self
  end

  def wait_event_typed(event_class : T.class, session_id : Rod::SessionID? = nil) : Proc(T) forall T
    _ = session_id
    -> do
      {% if T == Cdp::Fetch::RequestPausedEvent %}
        Cdp::Fetch::RequestPausedEvent.from_json(%({
          "requestId":"req-1",
          "request":{
            "url":"https://example.test/a",
            "method":"GET",
            "headers":{},
            "initialPriority":"VeryHigh",
            "referrerPolicy":"strict-origin-when-cross-origin"
          },
          "frameId":"frame-1",
          "resourceType":"Document"
        }))
      {% elsif T == Cdp::Fetch::AuthRequiredEvent %}
        Cdp::Fetch::AuthRequiredEvent.from_json(%({
          "requestId":"req-1",
          "request":{
            "url":"https://example.test/a",
            "method":"GET",
            "headers":{},
            "initialPriority":"VeryHigh",
            "referrerPolicy":"strict-origin-when-cross-origin"
          },
          "frameId":"frame-1",
          "resourceType":"Document",
          "authChallenge":{
            "source":"Server",
            "origin":"https://example.test",
            "scheme":"basic",
            "realm":"web"
          }
        }))
      {% else %}
        raise "unexpected event class #{event_class}"
      {% end %}
    end
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    @method_calls << method

    if method == "Fetch.continueRequest" && @fail_continue_request
      raise Exception.new("continue failed")
    end

    %({}).to_slice
  end
end

describe "browser handle_auth parity" do
  it "runs fetch auth flow and disables fetch after success" do
    browser = HandleAuthStubBrowser.new

    wait = browser.handle_auth("a", "b")
    err = wait.call

    err.should be_nil
    browser.method_calls.should contain("Fetch.disable")
    browser.method_calls.should contain("Fetch.enable")
    browser.method_calls.should contain("Fetch.continueRequest")
    browser.method_calls.should contain("Fetch.continueWithAuth")
    browser.method_calls.last.should eq("Fetch.disable")
  end

  it "returns error and still disables fetch on failure" do
    browser = HandleAuthStubBrowser.new
    browser.fail_continue_request = true

    wait = browser.handle_auth("a", "b")
    err = wait.call

    err.should be_a(Exception)
    err.not_nil!.message.to_s.should contain("continue failed")
    browser.method_calls.should contain("Fetch.disable")
    browser.method_calls.should contain("Fetch.enable")
  end
end
