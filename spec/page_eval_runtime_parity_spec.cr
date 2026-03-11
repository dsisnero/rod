require "./spec_helper"

private class EvalRuntimeStubPage < Rod::Page
  property eval_calls = [] of Rod::EvalOptions
  property eval_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def evaluate(opts : Rod::EvalOptions) : Cdp::Runtime::RemoteObject
    @eval_calls << opts
    if ex = @eval_error
      raise ex
    end

    if opts.js.includes?("setTimeout") && opts.js_args.size >= 2
      ms = case arg = opts.js_args[0]
           when JSON::Any
             arg.as_i
           when Int32
             arg
           when Int64
             arg.to_i
           else
             raise "unsupported delay arg type: #{arg.class}"
           end
      value = case arg = opts.js_args[1]
              when JSON::Any
                arg.as_i
              when Int32
                arg
              when Int64
                arg.to_i
              else
                raise "unsupported value arg type: #{arg.class}"
              end
      sleep(ms.milliseconds)
      return Cdp::Runtime::RemoteObject.from_json(%({"type":"number","value":#{value}}))
    end

    Cdp::Runtime::RemoteObject.from_json(%({"type":"number","value":3}))
  end
end

private class EvalRetryCallPage < Rod::Page
  property failures_left = 0
  property call_count = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params
    if method == "Runtime.evaluate"
      return %({"result":{"type":"object","objectId":"window-obj"}}).to_slice
    end

    if method == "Runtime.callFunctionOn"
      @call_count += 1
      if @failures_left > 0
        @failures_left -= 1
        raise Exception.new(Cdp::ErrCtxNotFound.message)
      end
      return %({"result":{"type":"number","value":1}}).to_slice
    end

    raise "unexpected method: #{method}"
  end
end

private class EnsureHelperErrorPage < Rod::Page
  property call_function_on_calls = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    case method
    when "Runtime.evaluate"
      %({"result":{"type":"object","objectId":"window-obj"}}).to_slice
    when "Runtime.callFunctionOn"
      @call_function_on_calls += 1
      raise Exception.new("helper setup failed")
    else
      raise "unexpected method: #{method}"
    end
  end
end

private class HelperRetryPage < Rod::Page
  property call_function_on_calls = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    case method
    when "Runtime.evaluate"
      %({"result":{"type":"object","objectId":"window-obj"}}).to_slice
    when "Runtime.callFunctionOn"
      @call_function_on_calls += 1
      case @call_function_on_calls
      when 1
        raise Exception.new(Cdp::ErrCtxNotFound.message)
      when 2
        %({"result":{"type":"object","objectId":"functions-obj"}}).to_slice
      when 3
        %({"result":{"type":"function","objectId":"selectable-fn"}}).to_slice
      when 4
        %({"result":{"type":"function","objectId":"elementx-fn"}}).to_slice
      else
        %({"result":{"type":"number","value":1}}).to_slice
      end
    else
      raise "unexpected method: #{method}"
    end
  end
end

private class UpdateCtxIdErrPage < Rod::Page
  property eval_calls = 0
  property call_function_calls = 0

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    case method
    when "Runtime.evaluate"
      @eval_calls += 1
      if @eval_calls == 1
        %({"result":{"type":"object","objectId":"window-obj"}}).to_slice
      else
        raise Exception.new("runtime evaluate failed")
      end
    when "Runtime.callFunctionOn"
      @call_function_calls += 1
      case @call_function_calls
      when 1
        %({"result":{"type":"object","objectId":"functions-obj"}}).to_slice
      when 2
        %({"result":{"type":"function","objectId":"selectable-fn"}}).to_slice
      when 3
        %({"result":{"type":"function","objectId":"elementx-fn"}}).to_slice
      when 4
        raise Exception.new(Cdp::ErrCtxNotFound.message)
      else
        raise "unexpected callFunctionOn call #{@call_function_calls}"
      end
    else
      raise "unexpected method: #{method}"
    end
  end
end

private class EvalCallErrorPage < Rod::Page
  property call_error : Exception? = nil

  def initialize
    super(Rod::Browser.new, Rod::TargetID.new("target-id"))
  end

  def call(context : HTTP::Client::Context?, session_id : String?, method : String, params : JSON::Any) : Bytes
    _ = context
    _ = session_id
    _ = params

    if method == "Runtime.evaluate"
      return %({"result":{"type":"object","objectId":"window-obj"}}).to_slice
    end

    if method == "Runtime.callFunctionOn"
      if ex = @call_error
        raise ex
      end
      return %({"result":{"type":"number","value":1}}).to_slice
    end

    raise "unexpected method: #{method}"
  end
end

describe "page eval runtime parity" do
  it "eval forwards await_promise/by_value options and args" do
    page = EvalRuntimeStubPage.new

    result = page.eval("(a, b) => a + b", [JSON.parse("1"), JSON.parse("2")])
    result.value.not_nil!.as_i.should eq(3)

    opts = page.eval_calls.last
    opts.await_promise?.should be_true
    opts.by_value?.should be_true
    opts.js.should eq("(a, b) => a + b")
    opts.js_args.should eq([JSON.parse("1"), JSON.parse("2")] of Rod::EvalOptions::JsArg)
  end

  it "eval propagates evaluate errors" do
    page = EvalRuntimeStubPage.new
    page.eval_error = Exception.new("eval js error: ReferenceError: notExist is not defined")

    expect_raises(Exception, /ReferenceError: notExist is not defined/) do
      page.eval("() => notExist()")
    end
  end

  it "supports concurrent eval calls without serializing slow promises" do
    page = EvalRuntimeStubPage.new
    results = Channel(Int32).new(2)

    started = Time.instant
    wait = Rod::Lib::Utils.all(
      -> do
        value = page.eval(
          "(ms, v) => new Promise(r => setTimeout(r, ms, v))",
          [JSON.parse("250"), JSON.parse("2")]
        )
        results.send(value.value.not_nil!.as_i)
      end,
      -> do
        value = page.eval(
          "(ms, v) => new Promise(r => setTimeout(r, ms, v))",
          [JSON.parse("150"), JSON.parse("1")]
        )
        results.send(value.value.not_nil!.as_i)
      end
    )
    wait.call
    elapsed = Time.instant - started

    vals = [results.receive, results.receive].sort
    vals.should eq([1, 2])
    elapsed.should be > 140.milliseconds
    elapsed.should be < 360.milliseconds
  end

  it "retries eval when runtime context is temporarily missing" do
    page = EvalRetryCallPage.new
    page.failures_left = 2

    result = page.eval("() => 1")
    result.value.not_nil!.as_i.should eq(1)
    page.call_count.should eq(3)
  end

  it "raises object-not-found for this-bound eval when context is missing" do
    page = EvalRetryCallPage.new
    page.failures_left = 1
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1","description":"obj"}))

    expect_raises(Rod::ObjectNotFoundError) do
      page.evaluate(Rod::EvalOptions.new(js: "() => 1").this(obj))
    end
  end

  it "propagates helper setup errors when js helper injection fails" do
    page = EnsureHelperErrorPage.new
    opts = Rod::EvalOptions.new(js: "() => 1", js_args: [Rod::JS::ELEMENT_X] of Rod::EvalOptions::JsArg)

    expect_raises(Exception, /helper setup failed/) do
      page.evaluate(opts)
    end
    page.call_function_on_calls.should eq(1)
  end

  it "retries helper setup when runtime context is transiently missing" do
    page = HelperRetryPage.new
    opts = Rod::EvalOptions.new(js: "() => 1", js_args: [Rod::JS::ELEMENT_X] of Rod::EvalOptions::JsArg)

    result = page.evaluate(opts)
    result.value.not_nil!.as_i.should eq(1)
    page.call_function_on_calls.should eq(5)
  end

  it "surfaces js context refresh failure after ctx-not-found during eval" do
    page = UpdateCtxIdErrPage.new
    opts = Rod::EvalOptions.new(js: "() => 1", js_args: [Rod::JS::ELEMENT_X] of Rod::EvalOptions::JsArg)

    expect_raises(Exception, /runtime evaluate failed/) do
      page.evaluate(opts)
    end
    page.call_function_calls.should eq(4)
    page.eval_calls.should eq(2)
  end

  it "surfaces context-destroyed errors for interrupted async evals" do
    page = EvalCallErrorPage.new
    page.call_error = Exception.new(Cdp::ErrCtxDestroyed.message)

    expect_raises(Exception, /#{Regex.escape(Cdp::ErrCtxDestroyed.message)}/) do
      page.eval("() => new Promise(r => setTimeout(() => r(1), 1000))")
    end
  end

  it "surfaces stale object-id errors when evaluating with leaked objects" do
    page = EvalCallErrorPage.new
    page.call_error = Exception.new("Could not find object with given id")
    stale_obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-stale"}))
    opts = Rod::EvalOptions.new(js: "a => a", js_args: [stale_obj] of Rod::EvalOptions::JsArg)

    expect_raises(Exception, /Could not find object with given id/) do
      page.evaluate(opts)
    end
  end

  it "surfaces object reference chain too long errors from runtime" do
    page = EvalCallErrorPage.new
    page.call_error = Exception.new("Object reference chain is too long")
    obj = Cdp::Runtime::RemoteObject.from_json(%({"type":"object","objectId":"obj-1"}))
    opts = Rod::EvalOptions.new(js: "a => a", js_args: [obj] of Rod::EvalOptions::JsArg)

    expect_raises(Exception, /Object reference chain is too long/) do
      page.evaluate(opts)
    end
  end
end
