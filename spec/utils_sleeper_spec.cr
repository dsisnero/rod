require "./spec_helper"

describe Rod::Lib::Utils do
  it "wakes backoff sleeper immediately when max interval is zero" do
    ctx = Rod::Context.new
    sleeper = Rod::Lib::Utils.backoff_sleeper(0.seconds, 0.seconds)

    sleeper.call(ctx).should be_nil
  end

  it "retries until fn signals stop" do
    ctx = Rod::Context.new
    count = 0
    sleeper = Rod::Lib::Utils.backoff_sleeper(1.millisecond, 5.milliseconds, ->(i : Time::Span) { i })

    err = Rod::Lib::Utils.retry(ctx, sleeper) do
      if count > 5
        {true, IO::Error.new("EOF")}
      else
        count += 1
        {false, nil}
      end
    end

    err.should be_a(IO::Error)
    err.to_s.should eq("EOF")
  end

  it "returns context cancel error while retrying" do
    ctx = Rod::Context.new
    spawn do
      sleep 5.milliseconds
      ctx.cancel
    end
    sleeper = Rod::Lib::Utils.backoff_sleeper(1.second, 1.second, ->(i : Time::Span) { i })

    err = Rod::Lib::Utils.retry(ctx, sleeper) do
      {false, nil}
    end

    err.should be_a(Rod::ContextCanceledError)
  end

  it "returns max sleep count error" do
    ctx = Rod::Context.new
    sleeper = Rod::Lib::Utils.count_sleeper(5)
    5.times { sleeper.call(ctx) }

    err = sleeper.call(ctx)
    err.should be_a(Rod::Lib::Utils::MaxSleepCountError)
  end

  it "returns context cancel error for count sleeper" do
    ctx = Rod::Context.new
    ctx.cancel

    err = Rod::Lib::Utils.count_sleeper(5).call(ctx)
    err.should be_a(Rod::ContextCanceledError)
  end

  it "supports each sleepers" do
    ctx = Rod::Context.new
    s1 = Rod::Lib::Utils.backoff_sleeper(1.millisecond, 5.milliseconds, ->(i : Time::Span) { i })
    s2 = Rod::Lib::Utils.count_sleeper(5)
    sleeper = Rod::Lib::Utils.each_sleepers(s1, s2)

    err = Rod::Lib::Utils.retry(ctx, sleeper) { {false, nil} }

    err.should be_a(Rod::Lib::Utils::MaxSleepCountError)
    err.to_s.should eq("max sleep count 5 exceeded")
  end

  it "supports race sleepers" do
    ctx = Rod::Context.new
    s1 = Rod::Lib::Utils.backoff_sleeper(1.millisecond, 5.milliseconds, ->(i : Time::Span) { i })
    s2 = Rod::Lib::Utils.count_sleeper(5)
    sleeper = Rod::Lib::Utils.race_sleepers(s1, s2)

    err = Rod::Lib::Utils.retry(ctx, sleeper) { {false, nil} }

    err.should be_a(Rod::Lib::Utils::MaxSleepCountError)
    err.to_s.should eq("max sleep count 5 exceeded")
  end

  it "waits for idle duration after jobs complete" do
    ctx = Rod::Context.new
    counter = Rod::Lib::Utils::IdleCounter.new(100.milliseconds)

    counter.add
    spawn do
      counter.add
      sleep 300.milliseconds
      counter.done
      counter.done
    end

    start = Time.monotonic
    counter.wait(ctx)
    elapsed = Time.monotonic - start
    elapsed.should be > 380.milliseconds
    elapsed.should be < 550.milliseconds

    expect_raises(Exception, "all jobs are already done") do
      counter.done
    end

    ctx.cancel
    start = Time.monotonic
    counter.wait(ctx)
    (Time.monotonic - start).should be < 20.milliseconds
  end

  it "waits from zero jobs state" do
    ctx = Rod::Context.new
    counter = Rod::Lib::Utils::IdleCounter.new(100.milliseconds)
    start = Time.monotonic
    counter.wait(ctx)
    (Time.monotonic - start).should be < 180.milliseconds
  end

  it "returns immediately for zero idle duration" do
    ctx = Rod::Context.new
    counter = Rod::Lib::Utils::IdleCounter.new(0.seconds)
    start = Time.monotonic
    counter.wait(ctx)
    (Time.monotonic - start).should be < 20.milliseconds
  end
end
