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

  it "restores a pre-existing fetch enable instead of disabling it" do
    browser = HandleAuthStubBrowser.new
    # A hijack router (or any other caller) had Fetch enabled before the wait.
    browser.set_state(nil, "Fetch.enable", JSON.parse(%({"patterns":[]})))
    browser.method_calls.clear

    browser.handle_auth("a", "b").call.should be_nil

    # go: `enable := b.DisableDomain("", &FetchEnable{})` tears it down and its
    # deferred restore puts it back (`hijack.go:415-455`), so the hijacker keeps
    # working after HandleAuth.
    browser.method_calls.last.should eq("Fetch.enable")
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

describe "browser handle_auth live parity" do
  it "answers a basic auth challenge like go-rod's TestHandleAuth" do
    server = HTTP::Server.new do |ctx|
      if ctx.request.path != "/a"
        # go-rod's fixture server answers everything else (e.g. the favicon
        # request) without a challenge, so the single-shot auth flow is not
        # consumed by it.
        ctx.response.print("")
      elsif userinfo = ctx.request.headers["Authorization"]?
        user, password = Base64.decode_string(userinfo.split(' ').last? || "").split(':', 2)
        ctx.response.content_type = "text/html; charset=utf-8"
        ctx.response.print("<p>#{user}:#{password}</p>")
      else
        ctx.response.headers["WWW-Authenticate"] = %(Basic realm="web")
        ctx.response.status_code = 401
      end
    end
    addr = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }

    begin
      RodSpec.with_live_browser do |browser|
        wait = browser.handle_auth("a", "b")
        done = Channel(Exception?).new(1)
        spawn { done.send(wait.call) }

        page = browser.must_page("http://127.0.0.1:#{addr.port}/a")
        page.must_element("p").must_text.should eq("a:b")

        # Wait for the fetch-auth cleanup to restore the domain before the
        # browser goes back to the pool, otherwise a later example inherits an
        # enabled Fetch domain and its navigations stall.
        done.receive.should be_nil
        page.must_close
      end
    ensure
      server.close
    end
  end
end
