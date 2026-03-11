require "./spec_helper"

private CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

private def cdp_fixture_url(name : String) : String
  "file://#{File.expand_path("../vendor/rod/lib/cdp/fixtures/#{name}", __DIR__)}"
end

private class MockCdpWebSocket < Rod::Lib::Cdp::WebSocket
  getter sent = [] of String
  property send_error : Exception? = nil

  def initialize
    @reads = Channel(Bytes).new(64)
  end

  def enqueue_read(payload : String) : Nil
    @reads.send(payload.to_slice)
  end

  def close_reads : Nil
    @reads.close
  end

  def send(data : Bytes) : Nil
    if ex = @send_error
      raise ex
    end

    @sent << String.new(data)
  end

  def read : Bytes
    @reads.receive
  end
end

private class EchoCdpWebSocket < Rod::Lib::Cdp::WebSocket
  def initialize
    @responses = Channel(Bytes).new(2048)
  end

  def send(data : Bytes) : Nil
    req = JSON.parse(String.new(data))
    id = req["id"].as_i
    params = req["params"]?
    payload = if params
                %({"id":#{id},"result":#{params.to_json}})
              else
                %({"id":#{id},"result":null})
              end
    @responses.send(payload.to_slice)
  end

  def read : Bytes
    @responses.receive
  end
end

private class SlowSendCdpWebSocket < Rod::Lib::Cdp::WebSocket
  def initialize
    @responses = Channel(Bytes).new(1)
    @send_gate = Channel(Nil).new(1)
    @sent_once = Atomic(Bool).new(false)
  end

  def send(data : Bytes) : Nil
    return if @sent_once.swap(true)
    req = JSON.parse(String.new(data))
    id = req["id"].as_i
    @send_gate.send(nil)
    sleep 300.milliseconds
    @responses.send(%({"id":#{id},"result":1}).to_slice)
  end

  def read : Bytes
    @send_gate.receive
    @responses.receive
  end
end

private class BlockingCdpWebSocket < Rod::Lib::Cdp::WebSocket
  def send(data : Bytes) : Nil
  end

  def read : Bytes
    sleep 1.second
    raise IO::Error.new("closed")
  end
end

private class ScriptedCdpWebSocket < Rod::Lib::Cdp::WebSocket
  getter requests = [] of JSON::Any

  def initialize
    @responses = Channel(Bytes).new(64)
  end

  def send(data : Bytes) : Nil
    req = JSON.parse(String.new(data))
    @requests << req
    id = req["id"].as_i
    method = req["method"].as_s

    payload = case method
              when "Target.createTarget"
                %({"id":#{id},"result":{"targetId":"target-1"}})
              when "Target.attachToTarget"
                %({"id":#{id},"result":{"sessionId":"session-1"}})
              when "Page.enable"
                %({"id":#{id},"result":{}})
              when "Runtime.evaluate"
                %({"id":#{id},"result":{"result":{"type":"number","value":10}}})
              else
                %({"id":#{id},"error":{"code":-32601,"message":"method not found"}})
              end
    @responses.send(payload.to_slice)
  end

  def read : Bytes
    @responses.receive
  end
end

private class CrashyCdpWebSocket < Rod::Lib::Cdp::WebSocket
  def initialize
    @reads = Channel(Bytes).new(1)
  end

  def send(data : Bytes) : Nil
  end

  def read : Bytes
    sleep 50.milliseconds
    raise IO::Error.new("EOF")
  end
end

private class CancelLeakCdpWebSocket < Rod::Lib::Cdp::WebSocket
  def initialize
    @id = 0
    @wait = Channel(Nil).new(1)
  end

  def send(data : Bytes) : Nil
    _ = data
    @wait.send(nil)
    sleep 10.milliseconds
  end

  def read : Bytes
    if @id > 0
      raise IO::Error.new("EOF")
    end

    @id += 1
    @wait.receive
    %({"id":1,"result":1}).to_slice
  end
end

private def wait_until(timeout : Time::Span = 1.second, &block : -> Bool) : Nil
  deadline = Time.instant + timeout
  until block.call
    raise "timeout waiting" if Time.instant >= deadline
    sleep 1.millisecond
  end
end

describe "cdp client parity" do
  it "raises when call is used before start" do
    client = Rod::Lib::Cdp::Client.new
    expect_raises(Exception, /not started/) do
      client.call(nil, nil, "Test.method", JSON.parse(%({})))
    end
  end

  it "supports logger chaining like go client logger setter" do
    ws = MockCdpWebSocket.new
    logger = Log.for("cdp-parity")
    client = Rod::Lib::Cdp::Client.new.logger(logger).start(ws)
    client.should be_a(Rod::Lib::Cdp::Client)
    ws.close_reads
  end

  it "sends request and returns matching response payload" do
    ws = MockCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    done = Channel(String).new(1)
    spawn do
      begin
        res = client.call(nil, "sid-1", "Test.method", JSON.parse(%({"a":1})))
        done.send(String.new(res))
      rescue ex
        done.send("ERR:#{ex.message}")
      end
    end

    wait_until { !ws.sent.empty? }
    req = JSON.parse(ws.sent.first)
    id = req["id"].as_i

    ws.enqueue_read(%({"id":#{id},"result":{"ok":1}}))

    done.receive.should eq(%({"ok":1}))
    req["method"].as_s.should eq("Test.method")
    req["sessionId"].as_s.should eq("sid-1")
    ws.close_reads
  end

  it "routes incoming events to event channel" do
    ws = MockCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    ws.enqueue_read(%({"method":"Target.attachedToTarget","params":{"x":1},"sessionId":"sid-2"}))

    evt = client.event.receive
    evt.method.should eq("Target.attachedToTarget")
    evt.session_id.should eq("sid-2")
    evt.params.not_nil!["x"].as_i.should eq(1)
    ws.close_reads
  end

  it "raises protocol error responses from call" do
    ws = MockCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    done = Channel(String).new(1)
    spawn do
      begin
        client.call(nil, nil, "Test.method", JSON.parse(%({})))
        done.send("ok")
      rescue ex
        done.send(ex.message || "")
      end
    end

    wait_until { !ws.sent.empty? }
    id = JSON.parse(ws.sent.first)["id"].as_i
    ws.enqueue_read(%({"id":#{id},"error":{"code":10,"message":"err"}}))

    done.receive.should contain("{10 err")
    ws.close_reads
  end

  it "propagates send failures" do
    ws = MockCdpWebSocket.new
    ws.send_error = Exception.new("send failed")
    client = Rod::Lib::Cdp::Client.new.start(ws)

    expect_raises(Exception, /send failed/) do
      client.call(nil, nil, "Test.method", JSON.parse(%({})))
    end
    ws.close_reads
  end

  it "formats cdp error as go-style tuple string with data" do
    err = Rod::Lib::Cdp::Error.new(10, "err", JSON.parse(%("data")))
    err.to_s.should eq("{10 err data}")
    err.is?(err).should be_true
  end

  it "must_start_with_url raises on empty url" do
    expect_raises(Exception, /empty websocket url/) do
      Rod::Lib::Cdp.must_start_with_url("")
    end
  end

  it "matches go TestBasic behavior with real browser websocket" do
    launcher = Rod::Lib::Launcher.new
      .bin(CHROME_BIN)
      .headless(true)
      .no_sandbox(true)
      .leakless(false)
    client = Rod::Lib::Cdp::Client.new

    begin
      client.logger(Log.for("cdp-parity-live")).start(Rod::Lib::Cdp.must_connect_ws(launcher.launch))

      spawn do
        loop { client.event.receive }
      rescue Channel::ClosedError
      end

      create = JSON.parse(String.new(client.call(nil, nil, "Target.createTarget", JSON.parse(%({"url":"#{cdp_fixture_url("iframe.html")}"})))))
      target_id = create["targetId"].as_s

      attach = JSON.parse(String.new(client.call(nil, nil, "Target.attachToTarget", JSON.parse(%({"targetId":"#{target_id}","flatten":true})))))
      session_id = attach["sessionId"].as_s

      client.call(nil, session_id, "Page.enable", JSON.parse(%({})))

      expect_raises(Exception) do
        client.call(nil, nil, "Target.attachToTarget", JSON.parse(%({"targetId":"abc"})))
      end

      canceled = Rod::Context.new
      canceled.cancel
      expect_raises(Rod::ContextCanceledError) do
        client.call(canceled, session_id, "Runtime.evaluate", JSON.parse(%({"expression":"10"})))
      end

      iframe_eval = nil.as(JSON::Any?)
      wait_until(5.seconds) do
        begin
          res = JSON.parse(String.new(client.call(nil, session_id, "Runtime.evaluate", JSON.parse(%({"expression":"document.querySelector('iframe')"})))))
          subtype = res["result"]["subtype"]?.try(&.as_s?)
          ok = subtype != "null"
          iframe_eval = res if ok
          ok
        rescue
          false
        end
      end

      object_id = iframe_eval.not_nil!["result"]["objectId"].as_s
      describe = JSON.parse(String.new(client.call(nil, session_id, "DOM.describeNode", JSON.parse(%({"objectId":"#{object_id}"})))))
      frame_id = describe["node"]["frameId"].as_s

      h4_eval = nil.as(JSON::Any?)
      wait_until(5.seconds) do
        begin
          isolated = JSON.parse(String.new(client.call(nil, session_id, "Page.createIsolatedWorld", JSON.parse(%({"frameId":"#{frame_id}"})))))
          context_id = isolated["executionContextId"].as_i
          res = JSON.parse(String.new(client.call(nil, session_id, "Runtime.evaluate", JSON.parse(%({"contextId":#{context_id},"expression":"document.querySelector('h4')"})))))
          subtype = res["result"]["subtype"]?.try(&.as_s?)
          ok = subtype != "null"
          h4_eval = res if ok
          ok
        rescue
          false
        end
      end

      html = JSON.parse(String.new(client.call(nil, session_id, "DOM.getOuterHTML", JSON.parse(%({"objectId":"#{h4_eval.not_nil!["result"]["objectId"].as_s}"})))))
      html["outerHTML"].as_s.should eq("<h4>it works</h4>")
    ensure
      begin
        client.call(nil, nil, "Browser.close", JSON.parse(%({})))
      rescue
      end

      begin
        launcher.kill
      rescue
      end
    end
  end

  it "supports concurrent call/response routing by request id" do
    ws = EchoCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    total = 200
    done = Channel(Nil).new(total)
    failures = Atomic(Int32).new(0)

    total.times do |i|
      spawn do
        begin
          res = client.call(nil, "sid-1", "Test.concurrent", JSON.parse(%({"n":#{i}})))
          JSON.parse(String.new(res))["n"].as_i.should eq(i)
        rescue
          failures.add(1)
        ensure
          done.send(nil)
        end
      end
    end

    total.times { done.receive }
    failures.get.should eq(0)
  end

  it "handles slow send without losing response routing" do
    ws = SlowSendCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    res = client.call(nil, "sid-1", "Test.slow_send", JSON.parse("1"))
    JSON.parse(String.new(res)).as_i.should eq(1)
  end

  it "returns canceled error when rod context is already canceled" do
    ws = BlockingCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)
    ctx = Rod::Context.new
    ctx.cancel

    expect_raises(Rod::ContextCanceledError) do
      client.call(ctx, "sid-1", "Test.cancel", JSON.parse("1"))
    end
  end

  it "matches go TestCancelCallLeak canceled-call loop behavior" do
    30.times do
      ws = CancelLeakCdpWebSocket.new
      client = Rod::Lib::Cdp::Client.new.start(ws)
      ctx = Rod::Context.new
      ctx.cancel

      begin
        client.call(ctx, "1234567890", "method", JSON.parse("1"))
      rescue Rod::ContextCanceledError
        # Expected fast-path for canceled context.
      rescue
        # Go parity ignores returned error here; only validates no leak/hang.
      end
    end
  end

  it "supports basic multi-step session flow like go TestBasic core path" do
    ws = ScriptedCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    create = JSON.parse(String.new(client.call(nil, nil, "Target.createTarget", JSON.parse(%({"url":"file:///a"})))))
    create["targetId"].as_s.should eq("target-1")

    attach = JSON.parse(String.new(client.call(nil, nil, "Target.attachToTarget", JSON.parse(%({"targetId":"target-1","flatten":true})))))
    attach["sessionId"].as_s.should eq("session-1")

    client.call(nil, "session-1", "Page.enable", JSON.parse(%({})))

    eval = JSON.parse(String.new(client.call(nil, "session-1", "Runtime.evaluate", JSON.parse(%({"expression":"10"})))))
    eval["result"]["value"].as_i.should eq(10)

    page_enable_req = ws.requests.find { |req| req["method"].as_s == "Page.enable" }
    page_enable_req.should_not be_nil
    page_enable_req.not_nil!["sessionId"].as_s.should eq("session-1")
  end

  it "propagates read-side crash errors to pending calls" do
    ws = CrashyCdpWebSocket.new
    client = Rod::Lib::Cdp::Client.new.start(ws)

    expect_raises(Exception, /EOF/) do
      client.call(nil, "sid-1", "Runtime.evaluate", JSON.parse(%({"expression":"new Promise(() => {})"})))
    end
  end

  it "matches go TestCrash behavior with real browser websocket" do
    launcher = Rod::Lib::Launcher.new
      .bin(CHROME_BIN)
      .headless(true)
      .no_sandbox(true)
      .leakless(false)
    client = Rod::Lib::Cdp::Client.new

    begin
      client.start(Rod::Lib::Cdp.must_connect_ws(launcher.launch))

      spawn do
        loop { client.event.receive }
      rescue Channel::ClosedError
      end

      create = JSON.parse(String.new(client.call(nil, nil, "Target.createTarget", JSON.parse(%({"url":"#{cdp_fixture_url("iframe.html")}"})))))
      target_id = create["targetId"].as_s

      attach = JSON.parse(String.new(client.call(nil, nil, "Target.attachToTarget", JSON.parse(%({"targetId":"#{target_id}","flatten":true})))))
      session_id = attach["sessionId"].as_s

      client.call(nil, session_id, "Page.enable", JSON.parse(%({})))

      spawn do
        sleep 1.second
        begin
          client.call(nil, session_id, "Browser.crash", JSON.parse(%({})))
        rescue
        end
      end

      first = expect_raises(Exception) do
        client.call(nil, session_id, "Runtime.evaluate", JSON.parse(%({"expression":"new Promise(() => {})","awaitPromise":true})))
      end
      first_msg = first.message.to_s.downcase
      (first_msg.includes?("eof") || first_msg.includes?("closed")).should be_true

      second = expect_raises(Exception) do
        client.call(nil, session_id, "Runtime.evaluate", JSON.parse(%({"expression":"10"})))
      end
      second_msg = second.message.to_s.downcase
      (second_msg.includes?("closed") || second_msg.includes?("not connected")).should be_true
    ensure
      begin
        launcher.kill
      rescue
      end
    end
  end
end
